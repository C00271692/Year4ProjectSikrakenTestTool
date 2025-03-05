%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%                                 Copyright 2024 SETU - Dr Christophe Meudec 
%%                                     <https://github.com/echancrure/Sikraken>
%% This file is part of Sikraken.
%% Sikraken is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by
%%   the Free Software Foundation.
%% Sikraken is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
%%   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
%% GNU Lesser General Public License v3.0 only
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% defines module se_main
% symbolic execution of parsed C code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- set_flag('debug_compile', 'on').   %does not really help 
:- get_flag(version, '7.1').            %check for valid ECLiPSe version: issue warning only if not 
%:- set_flag(after_event_timer, virtual). %causes out of range error when set to virtual (what you want) but ok for real: checked in tkeclipse and from CLI

mytrace.            %call this to start debugging
:- spy mytrace/0.
%%%
:- (is_predicate(prolog_c/2) -> abolish prolog_c/2 ; dynamic prolog_c/2).   %to ensure clean environment when using 'make' during development 

:- use_module(library('ic')).
:- use_module(library('lists')).
:- use_module(library('timeout')).

:- use_module("./../PTC-Solver/source/ptc_solver").

:- use_module(['se_globals', 'se_name_atts', 'se_seav_atts', 'se_sub_atts', 'se_typedef_atts']).

:- compile(['common_util', 'se_handle_declarations', 'se_symbolically_execute', 'se_symbolically_interpret', 'se_get_symbolic_lvalue_for_addressing']).
:- compile(['se_write_tests_testcomp']).
:- compile(['se_coverage']).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  
go(Restart, Tries) :- se_main(['/home/chris/Sikraken', '/home/chris/Sikraken/SampleCode','hardness_codestructure_dependencies_file-0', main, release, testcomp, '-m32', regression(Restart, Tries)]).
%go1 :- se_main(['/home/chris/Sikraken', '/home/chris/Sikraken/regression_tests','Problem03_label00', main, debug, testcomp, '-m32', budget(50)]).
go_dev :- se_main(['/home/chris/Sikraken', '/home/chris/Sikraken/SampleCode','atry_bitwise', main, debug, testcomp, '-m32', regression(1, 10)]).

se_main(ArgsL) :-
    %set_flag('gc_policy', 'fixed'),
    (ArgsL = [Install_dir, Source_dir, Target_source_file_name_no_ext, Target_raw_subprogram_name, Debug_mode, Output_mode, Data_model, Search_algo] ->
        true
    ;
        common_util__error(10, "Calling se_main/? with invalid argument list", "Review calling syntax of se_main/?", [], '10_240824_1', 'se_main', 'se_main', no_localisation, no_extra_info)
    ),
    %frandom(F), %before seed is set in se_globals__set_globals
    Increase_duration_multiplier is 1.05,
    printf('output', "Dev Info: Increase_duration_multiplier has been set at %.2f\n", [Increase_duration_multiplier]),
    setval('increase_duration_multiplier', Increase_duration_multiplier),
    se_globals__set_globals(Install_dir, Target_source_file_name_no_ext, Debug_mode, Output_mode, Data_model),
    (Search_algo = regression(Restarts, Tries) ->   %for more stable results during regression testing and to evaluate changes
        (setval('algo', 'regression'),
         setval('nb_restarts', Restarts),
         setval('nb_tries', Tries),
         (Debug_mode = 'debug' ->
            Budget = 1e99        %to work without timeouts at tkeclipse level during developement for example 
         ;   
            Budget = 65          %we put a limit for some regression tests which may not complete a full restart
         ),
         First_single_test_time_out is Budget - 5.0,  %ensure not triggered at the same time as overall timeout
         printf('output', "Dev Info: Analysing %w with %w restarts and %w tries\n", [Target_source_file_name_no_ext, Restarts, Tries])
        )
    ;
     Search_algo = budget(Raw_budget) ->    %for blind, testcomp, testing
        (setval('algo', 'time_budget'),
         setval('nb_restarts', 1e99),   %infinite restarts and tries allowed
         setval('nb_tries', 1e99),
         (Raw_budget == 900 ->  %we are in testcomp mode
            Budget = Raw_budget %1000       %be generous because we can only measure wall time, not CPU time and we are single threaded at the moment %was 890 to allow for initial script, interrupts (system calls, stream)
         ;
            Budget = Raw_budget %it's just used as an indication
         ),
         First_single_test_time_out is 0.2, %can be much too sort for program involving loops which take longer than this: not a problem itself as the budget will increase (but only slowly if the Increase_duration_multiplier is small)
         printf('output', "Dev Info: Analysing %w with a time budget of %w seconds.\n", [Target_source_file_name_no_ext, Budget])
        )
    ;
        common_util__error(10, "Calling se_main/? with invalid search algo configuration", "Review search algo argument syntax", [('Search_algo', Search_algo)], '10_240926_1', 'se_main', 'se_main', no_localisation, no_extra_info)
    ),         
    se_globals__set_val('single_test_time_out', First_single_test_time_out),    %i.e. 10 restart minimum is case of no test generated at all
    set_event_handler('overall_generation_time_out', handle_overall_time_out_event/0),
    event_after('overall_generation_time_out', Budget),
    print_test_run_log__preamble(ArgsL),
    initialise_ptc_solver,
    capitalize_first_letter(Target_raw_subprogram_name, Target_subprogram_name),
    read_parsed_file(Install_dir, Target_source_file_name_no_ext, Target_subprogram_name, prolog_c(Parsed_prolog_code), Main, Target_subprogram_var),      %may fail if badly formed due to parsing errors
    %%%pre-symbolic execution
    %mytrace,
    setval('execution_mode', 'global'),   %i.e. C compile time (as opposed to runtime), tackling globals when implicit initialisation to 0 occurs 
    (symbolic_execute(Parsed_prolog_code, _) ->   %always symbolically execute all global declarations for now: initialisations could be ignored via a switch if desired
        true
    ;
        common_util__error(10, "Sikraken failed to execute the declarations: cannot recover from this", "Should never happen: code needs to be traced", [], '10_021224_3', 'se_main', 'search_CFG_inner', no_localisation, no_extra_info)
    ),
    setval('execution_mode', 'local'),    %i.e. C run time (as opposed to compile time), tackling locals when implicit initialisation to 0 does not occur
    %%%
    print_preamble_testcomp(Install_dir, Source_dir, Target_source_file_name_no_ext),
    statistics(event_time, Session_time),
    setval('start_session_time', Session_time),
    %%% where it all happens
    catch(search_CFG(Debug_mode, Output_mode, Main, Target_subprogram_var, Parsed_prolog_code), Any_exception, search_CFG_exception_handler(Any_exception)),
    %%%
    log_and_terminate.   %only run once 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handle_overall_time_out_event :-
        cancel_after_event('single_test_time_out_exception', _), %to ensure none are left and be triggered later on especially in development mode
        throw('outatime').
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    search_CFG_exception_handler(Exception) :-
        (Exception == 'outatime' ->
            easter_egg
        ;
            (Exception == 'global_trail_overflow' ->
                (get_flag('max_global_trail', Max),
                 MB is (Max div 1024) div 1024,
                 common_util__error(10, "!!!Global/Trail stack overflow during search caught", "Review symbolic execution and/or increase initial ECLiPSe stack using -g", [('Curent Max global/trail stack in MB is', MB)], '10_260924_1', 'se_main', 'se_main', no_localisation, no_extra_info)
                )
            ;
             Exception == 'local_control_overflow ' ->
                (get_flag('max_local_control', Max),
                 MB is (Max div 1024) div 1024,
                 common_util__error(10, "!!!Local/Control stack overflow during search caught", "Review symbolic execution and/or increase initial ECLiPSe stack using -l", [('Curent Max local/control stack in MB is', MB)], '10_051024_1', 'se_main', 'se_main', no_localisation, no_extra_info)
                )
            ;
             Exception == 'abort' ->
                (log_and_terminate,
                 throw('abort')
                )
            ; 
                common_util__error(10, "Unknown exception caught", "Review, investigate and catch it better next time", [('Exception', Exception)], '10_260924_2', 'se_main', 'se_main', no_localisation, no_extra_info)
            )
        ).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    log_and_terminate :-
        %cancel_after_event('single_test_time_out_exception', _), %to ensure none are left and be triggered later on especially in development mode
        %cancel_after_event('overall_generation_time_out', _),    %to ensure none is left and be triggered later on especially in development mode            
        statistics(event_time, Current_session_time),
        printf('output', "Dev Info: Session time is %.2f seconds\n", [Current_session_time]),
        print_test_run_log__terminate.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
search_CFG(Debug_mode, Output_mode, Main, Target_subprogram_var, Parsed_prolog_code) :-
    set_event_handler('single_test_time_out_event', handle_single_test_time_out_event/0),
    getval('nb_restarts', Restarts),
    (for(Restart_counter, 1, Restarts), loop_name('restart'), param(Debug_mode, Output_mode, Main, Target_subprogram_var, Parsed_prolog_code)
        do (
            printf('output', "\nDev Info: Restart number %w\n", [Restart_counter]),
            search_CFG_inner(Debug_mode, Output_mode, Main, Target_subprogram_var, Parsed_prolog_code)
        )
    ).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    search_CFG_inner(_Debug_mode, Output_mode, Main, Target_subprogram_var, Parsed_prolog_code) :-
        se_globals__get_val('single_test_time_out', Current_single_test_time_out),
        printf('output', "Dev Info: Time budget for a single test is %.2f seconds\n", [Current_single_test_time_out]),
        se_globals__get_val('path_nb', Initial_try_solution_number),
        setval(nb_try_solution, Initial_try_solution_number),
        not(
            (catch(try_nb_path_budget(param(Output_mode, Main, Target_subprogram_var, Parsed_prolog_code)), 'single_test_time_out_exception', handle_single_test_time_out_exception) -> 
                (%should logically never happen
                 common_util__error(10, "try_nb_path_budget SUCCESS: something is seriously wrong", "Big bug", [], '10_240924_1', 'se_main', 'search_CFG_inner', no_localisation, no_extra_info), 
                 fail
                )
            ;
                (cancel_after_event('single_test_time_out_event', _CancelledEvents),    %to ensure none are left and be triggered later on
                 fail   %to make sure the not succeeds...
                )
            )
        ),
        se_globals__get_val('path_nb', Post_try_solution_number),
        getval(nb_try_solution, Pre_try_solution_number),
        Number_of_new_solutions is Post_try_solution_number - Pre_try_solution_number,
        (Number_of_new_solutions == 0 ->    %we tried a path for Current_single_test_time_out amount of time and no tests were generated
            (getval('algo', 'time_budget') ->
                (Maximum = 100,
                 getval('increase_duration_multiplier', Increase_duration_multiplier),
                 %we should retrieve se_globals__get_val('single_test_time_out', Current_single_test_time_out), because it may have changed within try_nb_path_budget
                 New_single_test_time_out is min(Current_single_test_time_out*Increase_duration_multiplier, Maximum), %but there is a maximum 
                 se_globals__set_val('single_test_time_out', New_single_test_time_out),   %todo should depend on global budget remaining
                 statistics(event_time, Current_session_time),
                 printf('output', "Dev Info: Restart single test budget changed to: %.2f seconds; overall elapsed time is %.2f seconds\n", [New_single_test_time_out, Current_session_time])
                )
            ;
                true
            )
        ;
            (%the last inner try did generate solutions
             setval(nb_try_solution, Post_try_solution_number)
            )
        ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tries to generate at most nb_tries of test input vectors using backtracking
%always fails by design
try_nb_path_budget(param(Output_mode, Main, Target_subprogram_var, Parsed_prolog_code)):-
    getval('nb_tries', Nb_tries),
    setval(try_counter, 0),
    se_globals__get_val('path_nb', Initial_test_number),
    setval(nbSolution, Initial_test_number),
    se_globals__get_val('single_test_time_out', Single_test_time_out),
    event_after('single_test_time_out_event', Single_test_time_out),
    statistics(event_time, Start_time),
    setval(start_time, Start_time),
    %%%where it all happens
    catch(find_one_path(Output_mode, Main, Target_subprogram_var, Parsed_prolog_code), Any_exception, find_one_path_exception_handler(Any_exception)),
    %%%
    getval(try_counter, I),
    I1 is I + 1,
    setval(try_counter, I1),
    (I1 == Nb_tries ->
        true    %target number of test inputs generated 
    ;
        fail    %will generate more solutions by backtracking through find_one_path (and eventually symbolic_execution)
    ),
    !,  
    fail.       %I know this is ugly: but this will only be reached during regression testing when the number of tries has been reached
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handle_single_test_time_out_event :-
        %mytrace,
        printf('output', "Dev Info: Time out triggered.\n", []),
        throw('single_test_time_out_exception').
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    handle_single_test_time_out_exception :-
        fail. %to make sure the not succeeds...
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    find_one_path_exception_handler(Exception) :-
        (Exception == 'abort' ->    %covers ECLiPSe exceptions: language/constraints violations?
            ((get_stream(error, X), get_stream(null, X)) -> %error stream has already been set to null
                true
            ;   
                (common_util__error(9, "ECLiPSe language violation", "", [], '9_281024_1', 'se_main', 'se_main', no_localisation, no_extra_info)
                 %,set_stream(error, null)   %to avoid thousands additional identical error messages from ECLiPSe
                 %find_one_path will succeed and count as a try, and hopefully backtrack out of the error and find another subpath, if not it will eventually reach the max number of tries or timeout
                )
            )
        ;
            throw(Exception)    %rethrow...
        ).    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
find_one_path(Output_mode, Main, Target_subprogram_var, Parsed_prolog_code) :-
    (Output_mode == 'testcomp' ->   %in the spirit of C we do not check Main: we accept any version (including argc/argv) 
        (se_sub_atts__get(Main, 'body', Main_compound_statement),   
         se_globals__update_ref('current_path_bran', start('Target_raw_subprogram_name', true)),
         symbolic_execute(Main_compound_statement, _Flow)
        )
    ;
        (%ignore this alternative for now: not testcomp
         %always symbolically execute void main(void) for now: should be a switch allowing the main to be ignored via a switch if desired
         se_sub_atts__get(Main, 'parameters', [param_no_decl([void], [])]),  %only handling main with no parameters for now
         se_sub_atts__get(Main, 'return_type', void),                        %only handling main with void return type for now
         se_sub_atts__get(Main, 'body', Main_compound_statement),
         symbolic_execute(Main_compound_statement, _Flow),         %symbolically execute the target C function: for now only inputs are its arguments (expand to globals that get overwritten with a switch)
         se_sub_atts__get(Target_subprogram_var, 'return_type', _Return_type),
         se_sub_atts__get(Target_subprogram_var, 'parameters', Params),
         se_globals__push_scope_stack,       %create function parameter scope
         declare_params(Params, SEAV_Inputs),
         se_sub_atts__get(Target_subprogram_var, 'body', Compound_statement),
         symbolic_execute(Compound_statement, _Flow)
        )
    ),
    end_of_path_predicate(SEAV_Inputs, Parsed_prolog_code).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    capitalize_first_letter(Input, Output) :-
        atom_string(Input, Input_string),
        string_chars(Input_string, [FirstChar|RestChars]),
        char_code(FirstChar, FirstCharCode),
        ((FirstCharCode >= 97, FirstCharCode =< 122) -> %a lowercase letter (ASCII a-z)
            (UpperFirstCharCode is FirstCharCode - 32,
             char_code(UpperFirstChar, UpperFirstCharCode)
            )
        ; 
            UpperFirstChar = FirstChar
        ),
        string_chars(Output_string, [UpperFirstChar|RestChars]),
        atom_string(Output, Output_string).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    end_of_path_predicate(SEAV_Inputs, Parsed_prolog_code) :-
        se_coverage__bran_newly_covered(Newly_covered),
        (Newly_covered == [] -> %no need to label: saves labelling run and test execution time
            true %common_util__error(1, "End of path: no new branches", 'no_error_consequences', [], '0_210824_1', 'se_main', 'end_of_path_predicate', no_localisation, no_extra_info)
        ;
            (se_globals__get_val('output_mode', Output_mode),
             (Output_mode = 'testcomp' ->
                (se_globals__get_ref('verifier_inputs', Verifier_inputs),
                 %mytrace,
                 (label_testcomp(Verifier_inputs, Labeled_inputs) ->
                  %label_all ->
                    (%%%
                     cancel_after_event('single_test_time_out_event', _CancelledEvents), 
                     statistics(event_time, Current_session_time),
                     getval(start_time, Current_start_time),
                     Last_test_duration is Current_session_time - Current_start_time,
                     printf('output', "Dev Info: Test generated in %.2f seconds; overall elapsed time is %.2f seconds\n", [Last_test_duration, Current_session_time]),
                     Margin = 10,       %multiplier: one order of magnitude
                     Minimum = 0.5,     %seconds whatever is close but above the overheads
                     (getval('algo', 'time_budget') ->
                        (se_globals__get_val('single_test_time_out', Current_single_test_time_out),
                         (Current_single_test_time_out > Minimum, Current_single_test_time_out > Margin * Last_test_duration ->  %last test generation was faster by a wide margin: allocated budget is reduced
                           (New_single_test_time_out is max(Margin * Last_test_duration, Minimum), %but there is a minimum to reduce overheads
                            se_globals__set_val('single_test_time_out', New_single_test_time_out),
                            printf('output', "Dev Info: Single test budget changed to: %.2f seconds; overall elapsed time is %.2f seconds\n", [New_single_test_time_out, Current_session_time])
                           )
                         ;
                           New_single_test_time_out = Current_single_test_time_out
                         ),    
                         event_after('single_test_time_out_event', New_single_test_time_out)
                        )
                     ;
                        true
                     ),
                     statistics(event_time, New_start_time),
                     setval(start_time, New_start_time),
                     %%% %%%
                     se_globals__get_val('path_nb', Test_nb),
                     Inc_test_nb is Test_nb + 1,
                     %(Inc_test_nb == 9 -> mytrace ; true),
                     se_globals__set_val('path_nb', Inc_test_nb),
                     se_globals__get_ref('current_path_bran', Current_path),
                     prune_instances(Current_path, Current_path_no_duplicates),
                     se_globals__get_val('covered_bran', Already_covered),
                     union(Already_covered, Current_path_no_duplicates, Covered),
                     se_globals__set_val('covered_bran', Covered),
                     %common_util__error(1, "End of path", 'no_error_consequences', [('Path Nb', Inc_test_nb), ('Newly_covered', Newly_covered), ('Current_path', Current_path)], '0_190824_1', 'se_main', 'end_of_path_predicate', no_localisation, no_extra_info),
                     (Output_mode == 'testcomp' ->
                        print_test_inputs_testcomp(Labeled_inputs)   %but don't print expected outputs
                     ;
                        (print_test_inputs(SEAV_Inputs),
                         se_globals__pop_scope_stack,    %only after labeling and printed to preserve parameters
                         term_variables(Parsed_prolog_code, All_Ids),
                         get_all_outputs(All_Ids, All_seavs),
                         print_test_outputs(All_seavs),    
                         flush(user_output)
                        )
                     )
                    )
                 ;
                    true    %labeling failed (perhaps floating points could not be labeled or there was no solution to integer non-linear constraints, who knows), we succeed to count it as a valid attempt
                 )
                )
             ;
                common_util__error(10, "Unexpected output mode", "Only testcomp format is supported for now", [('Output_mode', Output_mode)], '10_100924_1', 'se_main', 'end_of_path_predicate', no_localisation, no_extra_info)
             )
            )
        ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
initialise_ptc_solver :-
    ptc_solver__clean_up,
    se_globals__get_val('data_model', Data_model),
    ptc_solver__default_declarations(Data_model, 'ignore').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
read_parsed_file(Install_dir, Target_source_file_name_no_ext, Target_raw_subprogram_name, CProlog, Main, Target_subprogram_var) :-
    concat_atom([Install_dir, '/sikraken_output/', Target_source_file_name_no_ext, '/', Target_source_file_name_no_ext, '.pl'], Parsed_filename),
    (exists(Parsed_filename) ->
        (open(Parsed_filename, read, Stream),
         read_term(Stream, CProlog, [variable_names(VarsNames)]) -> %Varnames is list of Atom = Var (e.g. 'X' = X)
            (close(Stream),
             se_name_atts__initL(VarsNames),     %initialise all C vars with their Names
             (memberchk(Target_raw_subprogram_name = Target_subprogram_var, VarsNames) ->
                (memberchk('Main' = Main, VarsNames) ->
                    true
                ;
                    Main = null
                )
             ;
                common_util__error(10, "Could not find the target function", "Cannot process parsed C code", [('Parsed_filename', Parsed_filename), ('Target_raw_subprogram_name', Target_raw_subprogram_name)], '10_080824_1', 'se_main', 'read_parsed_file', no_localisation, "make sure the function name starts with an uppercase")
             )
            )
        ;
            common_util__error(10, "Reading parsed file failed", "Cannot process parsed C code", [('Parsed_filename', Parsed_filename)], '10_260724_1', 'se_main', 'read_parsed_file', no_localisation, "the parser probably produced bad Prolog code")
        )
    ;
        common_util__error(10, "Parsed file does not exist", "Cannot process parsed C code", [('Parsed_filename', Parsed_filename)], '10_260724', 'se_main', 'read_parsed_file', no_localisation, no_extra_info)
    ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
label(SEAV_Inputs) :-
    get_all_inputs(SEAV_Inputs, InputsL),
    ptc_solver__label_integers(InputsL),
    !.
    %%% 
    get_all_inputs([], []).
    get_all_inputs([Seav|R_seavs], [Input|R_inputs]) :-
        seav__get(Seav, 'input', Input),
        get_all_inputs(R_seavs, R_inputs).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%alternative labelling strategy: label all delayed vars not just the inputs
%not used for now
label_all :-
    delayed_goals(GoalList),
    term_variables(GoalList, All_delayed_vars),
    partition_delayed_vars(All_delayed_vars, Integers, Reals),
    (ptc_solver__label_integers(Integers) ->
        (ptc_solver__label_reals(Reals) ->    %integers and floats labeling kept separate for now
            true
        ;
            (common_util__error(1, "Floating point numbers labeling failed", "Perhaps worth investigating", [], '0_100924', 'se_main', 'label_all', no_localisation, no_extra_info),
             fail
            )
        )
    ),
    !.
    %%%
    partition_delayed_vars([], [], []).
    partition_delayed_vars([Var|Rest], Integers, Reals) :-
        (get_solver_type(Var, integer) ->
            (Integers = [Var|R_Integers],
             partition_delayed_vars(Rest, R_Integers, Reals)
            )
        ;
            (Reals = [Var|R_Reals],
             partition_delayed_vars(Rest, Integers, R_Reals)
            )
        ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Verifier_inputs is of the form [verif(Type, Input)|...] 
label_testcomp(Verifier_inputs, Labeled_inputs) :- 
    %mytrace,
    partition(Verifier_inputs, Integers, Floats, Grounded_floats, Labeled_inputs),
    (ptc_solver__label_integers(Integers) ->
        (ptc_solver__label_reals(Floats, Grounded_floats) ->    %integers and floats labeling kept separate for now
            true
        ;
            (common_util__error(1, "Floating point numbers labeling failed", "Perhaps worth investigating", [], '0_100924', 'se_main', 'label_testcomp', no_localisation, no_extra_info),
             fail
            )
        )
    ;
        (common_util__error(1, "Integer labeling failed", "Should be rare: e.g. non-linear, out of bounds", [], '0_200824', 'se_main', 'label_testcomp', no_localisation, no_extra_info),
         fail
        )
    ),
    !.
    %%%
    partition([], [], [], [], []).
    partition([verif(Type, Input)|R], Integers_out, Floats_out, Grounded_floats, [Labeled_input|R_Labeled]) :-
        ((Type == float ; Type == double ; Type == long_double) ->
            (Floats_out = [Input|R_Floats],
             Grounded_floats = [Ground_float|R_Grounded_floats],    %a list of vars grounded to floating point numbers during labeling
             Labeled_input = Ground_float,
             partition(R, Integers_out, R_Floats, R_Grounded_floats, R_Labeled)
            )
        ;
            (Integers_out = [verif(Type, Input)|R_Integers],
             Labeled_input = Input,
             partition(R, R_Integers, Floats_out, Grounded_floats, R_Labeled)
            )
        ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_all_outputs([], []).
get_all_outputs([Id|R_ids], All_outputs) :-
    (seav__seav_is_in_scope(Id) ->
         All_outputs = [Id|R_outputs]
    ;
        All_outputs = R_outputs
    ),
    get_all_outputs(R_ids, R_outputs).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_test_inputs([]).
print_test_inputs([SEAV|R]) :-
    se_name_atts__get(SEAV, 'name', Name),
    seav__get(SEAV, 'input', Input_value),
    printf(user_output, "\nInput %w = %w", [Name, Input_value]),
    print_test_inputs(R).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_test_outputs([]).
print_test_outputs([SEAV|R]) :-
    se_name_atts__get(SEAV, 'name', Name),
    seav__get(SEAV, 'output', Output_value),
    printf(user_output, "\nOutput %w = %w", [Name, Output_value]),
    print_test_outputs(R).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_test_run_log__preamble(ArgsL) :-
    ArgsL = [Install_dir, Source_dir, Target_source_file_name_no_ext, Target_raw_subprogram_name, Debug_mode, Output_mode, Data_model, Budget],
    get_flag('unix_time', Time), 
    local_time_string(Time, "%Y_%m_%d_%H_%M_%S", Timestamp),
    concat_string([Install_dir, '/sikraken_output/', Target_source_file_name_no_ext, "/test_run_", Target_source_file_name_no_ext, ".log"], Test_run_filename),
    setval('test_run_filename', Test_run_filename), 
    open(Test_run_filename, 'write', 'test_run_stream'),    %the directory must exist otherwise open/3 aborts
    printf('test_run_stream', "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n", []),
    printf('test_run_stream', "Sikraken Test Inputs Generation Run Log\n", []),
    printf('test_run_stream', "Raw Arguments:\t%w\n", [ArgsL]),
    printf('test_run_stream', "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n", []),
    printf('test_run_stream', "Relevant ECLiPSe Configurations:\n", []),
    get_flag('debug_compile', Debug_compile),
    get_flag('debugging', Debugging),
    get_flag('max_local_control', Max_local_control), 
    Max_local_control_in_MB is (Max_local_control div 1024) div 1024,
    get_flag('max_global_trail', Max_global_trail), 
    Max_global_trail_in_MB is (Max_global_trail div 1024) div 1024,
    get_flag('version', Version), 
    printf('test_run_stream', "\tECLiPSe version:\t%w\n", [Version]),
    printf('test_run_stream', "\tdebug_compile:\t\t%w\n", [Debug_compile]),
    printf('test_run_stream', "\tdebugging:\t\t\t%w\n", [Debugging]),
    printf('test_run_stream', "\tMaximum allowed local/control user stack (-l option):\t%wMB\n", [Max_local_control_in_MB]),
    printf('test_run_stream', "\tMaximum allowed global/trail user stack (-g option):\t%wMB\n", [Max_global_trail_in_MB]),
    printf('test_run_stream', "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n", []),
    printf('test_run_stream', "Sikraken Session Configurations at: %w\n", [Timestamp]),
    printf('test_run_stream', "\tRun mode:\t%w\n", [Debug_mode]),
    printf('test_run_stream', "\tTests inputs target format:\t%w\n", [Output_mode]),
    printf('test_run_stream', "\tTarget data model:\t%w\n", [Data_model]),
    printf('test_run_stream', "\tTarget function:\t%w\n", [Target_raw_subprogram_name]),   
    printf('test_run_stream', "\tTarget C file:\t%w (in folder:%w)\n", [Target_source_file_name_no_ext, Source_dir]),
    printf('test_run_stream', "\tTime budget:\t\t%w\n", [Budget]),
    close('test_run_stream').
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_test_run_log__terminate :-
    getval('test_run_filename', Test_run_filename),
    open(Test_run_filename, 'append', Test_run_stream),
    printf(Test_run_stream, "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n", []),
    printf(Test_run_stream, "Sikraken Session Results:\n", []),
    statistics('cputime', Cputime),
    Cputime_seconds is fix(Cputime),
    se_globals__get_val('path_nb', Test_nb),
    printf(Test_run_stream, "\tECLiPSe CPU time: \t%w seconds\n", [Cputime_seconds]),
    printf(Test_run_stream, "\tGenerated: \t\t\t%w tests\n", [Test_nb]),
    printf(Test_run_stream, "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n", []),
    printf(Test_run_stream, "ECLiPSe Statistics Dump:\n", []), 
    get_stream('log_output', Log_output_stream),
    set_stream('log_output', Test_run_stream),
    statistics,     %printing out ECLiPSe internal statistics into redirected stream
    set_stream('log_output', Log_output_stream),
    printf(Test_run_stream, "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%", []),
    close(Test_run_stream).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
easter_egg :-
    printf('output', "                                                                                                       .         .                          \n", []),
    printf('output', "        ,o888888o.     8 8888      88 8888888 8888888888   .8.    8888888 8888888888  8 8888          ,8.       ,8.          8 8888888888   \n", []),
    printf('output', "     . 8888     `88.   8 8888      88       8 8888        .888.         8 8888        8 8888         ,888.     ,888.         8 8888         \n", []),
    printf('output', "    ,8 8888       `8b  8 8888      88       8 8888       :88888.        8 8888        8 8888        .`8888.   .`8888.        8 8888         \n", []),
    printf('output', "    88 8888        `8b 8 8888      88       8 8888      . `88888.       8 8888        8 8888       ,8.`8888. ,8.`8888.       8 8888         \n", []),
    printf('output', "    88 8888         88 8 8888      88       8 8888     .8. `88888.      8 8888        8 8888      ,8'8.`8888,8^8.`8888.      8 888888888888 \n", []),
    printf('output', "    88 8888         88 8 8888      88       8 8888    .8`8. `88888.     8 8888        8 8888     ,8' `8.`8888' `8.`8888.     8 8888         \n", []),
    printf('output', "    88 8888        ,8P 8 8888      88       8 8888   .8' `8. `88888.    8 8888        8 8888    ,8'   `8.`88'   `8.`8888.    8 8888         \n", []),
    printf('output', "    `8 8888       ,8P  ` 8888     ,8P       8 8888  .8'   `8. `88888.   8 8888        8 8888   ,8'     `8.`'     `8.`8888.   8 8888         \n", []),
    printf('output', "     ` 8888     ,88'     8888   ,d8P        8 8888 .888888888. `88888.  8 8888        8 8888  ,8'       `8        `8.`8888.  8 8888         \n", []),
    printf('output', "        `8888888P'        `Y88888P'         8 8888.8'       `8. `88888. 8 8888        8 8888 ,8'         `         `8.`8888. 8 888888888888 \n\n", []).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%