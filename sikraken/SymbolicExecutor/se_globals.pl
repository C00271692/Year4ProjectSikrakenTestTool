:- module('se_globals').

mytrace.            %call this to start debugging
:- spy mytrace/0.

:- export super_util__quick_dev_info/2.
:- export se_globals__set_globals/5, se_globals__get_val/2, se_globals__set_val/2, se_globals__get_ref/2, se_globals__set_ref/2.
:- export se_globals__update_ref/2.
:- export se_globals__push_scope_stack/0, se_globals__pop_scope_stack/0.

%declaring global references: undone on backtracking
:- local reference('current_path_bran', []).    %list of branches followed so far
:- local reference('call_stack_bran', []).      %list of functions entered so far
:- local reference('scope_stack', [scope(0, dummy)]).          %[scope(level_nb|Var)|Older] with Var only used for delaying and awakening, see SEAV module
:- local reference('verifier_inputs', []).      %for testcomp: the chronogical list of verifier variables created in the form [verif(Type, Input)|...] 

:- setval('debug_mode', 'debug').   %needed in case we need to write out an error message before gloabls are initiatilised... 
:- dynamic covered_bran/1, path_nb/1.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
super_util__quick_dev_info(Message, Arguments) :-
    se_globals__get_val('debug_mode', Debug_mode),
    (Debug_mode == 'debug' ->
        (printf('output', "Dev Info: ", []),    %todo could you combine 
         printf('output', Message, Arguments),
         printf('output', "\n", []),
         flush('output')        %systematically flushing ALL debug/development messages is important or they may get displayed in a wrong order when mixed with message from other streams and be out of sync with the ECLiPse tracer
        )
    ;
        true
    ).     
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%declaring global non-logical variables: not undone on backtracking
se_globals__set_globals(Install_dir, Target_source_file_name_no_ext, Debug_mode, Output_mode, Data_model) :-    
    setval('errorMessageNb', 0),	            %number of error messages generated: used to set trace_points in debug mode only
    setval('debug_info', 'pre_symbolic_execution'),    %used in debug mode only to hold the current processing position of the symbolic executor: a phase, file, or function being handled
    setval('phase', 'elaboration'),             %initially we are in the elaboration phase: used during cfg building and elaboration control
    setval('covered_bran', []),
    setval('path_nb', 0),
    setval('number_restarts', 0),
    seed(1970),                                 %set for repeatable random behaviour between runs, 1970 is the default seed
    %random(My_seed), seed(My_seed), super_util__quick_dev_info("Random Seed: %w", My_seed),
    setval('to_cover', []),                     %list of branches remaining to cover
    setval('test_driver_test_nb', 0),
    setval('abandoned_path_nb', 0),	            %counts the number of timed out and unsuccessful labeling tests
    setval('install_dir', Install_dir),         %the install dir of the generator executable
    setval('target_source_file_name_no_ext', Target_source_file_name_no_ext),   %the name of target source file without extension
    setval('testcomp_test_suite_folder', ""),
    setval('debug_mode', Debug_mode),           %'debug' or 'release'
    setval('output_mode', Output_mode),         %'testcomp' or something else 
    setval('data_model', Data_model),           %'-m32'|'m64'
    setval('message_mode', Debug_mode),         %debug or release todo: remove, just use debug_mode
    setval('already_printed', []),              %list of already printed error messages : used in release mode only
    !.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__get_val(Global, Value) :-
    getval(Global, Value).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__set_val(Global, Value) :-      
    setval(Global, Value). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__get_ref(Global, Value) :-
    getref(Global, Value).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__set_ref(Global, Value) :-
    setref(Global, Value).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Branch is branch(Id, 'false') or branch(Id, 'true')
se_globals__update_ref(Global, Branch) :-
    (Global == 'current_path_bran' ->
        (se_globals__get_ref('current_path_bran', Current_path),
         se_globals__set_ref('current_path_bran', [Branch|Current_path])
         /*
         %start heuristic: if a new branch is being covered, we try to label without generating a test vector
         ,se_globals__get_val('covered_bran', Already_covered),
         (memberchk(Branch, Already_covered) -> 
            true    %not a new branch, so we carry on
         ;     
            (mytrace,
             se_globals__get_ref('verifier_inputs', Verifier_inputs),
             (call(label_testcomp(Verifier_inputs, _Labeled_inputs)) @ eclipse ->  % we try to label what we have so far
                (%labeling suceeded, but no test vector was generated
                 %super_util__quick_dev_info("Following new branch: %w", [Branch])
                 true
                )
             ;   
                %labeling failed...no test input vector was generated, we abandon this path
                fail
             )
            )

         )
         */
        )
    ;        
        setref(Global, Branch)
    ). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__push_scope_stack :-
    getref('scope_stack', [scope(Current_level, Current_var_scope)|Rest_stack]),
    Next_level is Current_level + 1,
    setref('scope_stack', [scope(Next_level, _Next_var_scope), scope(Current_level, Current_var_scope)|Rest_stack]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_globals__pop_scope_stack :-
    getref('scope_stack', [scope(Exit_level, Exist_var_scope)|Exit_stack]),
    Exist_var_scope = Exit_level,      %will trigger awakening of variables for that level: pops their own variable-level stack
    setref('scope_stack', Exit_stack).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%