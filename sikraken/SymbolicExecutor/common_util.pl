:- use_module('se_globals').

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%The idea behind this complex error message predicate is to allow filtering of warning messages according to severity and allow fine control over the information displayed (e.g. different details for developpers and users)
%any optional argument can be ommitted by appending 'no_' in front of the corresponding parameter name
%e.g. common_util__error(7, "Generic package instantiation to be implemented", "The package is unhandled", [("package's name", Name)], 709, se_symbolic, exec, exec(generic_package_instantiation(...)), "scheduled to be fixed in version 2.4")
%e.g. common_util__error(7, "Generic package instantiation to be implemented", no_error_consequences, no_arguments, 709, se_symbolic, exec, no_localisation, no_extra_info)
%TEMPLATE : common_util__error(Error_severity, Error_message, no_error_consequences, no_arguments, Error_code, From_module, From_predicate, no_localisation, no_extra_info)

%Error_severity between 0 to 10 : 10 is the highest error level and denotes a fatal error (cannot proceed any further : abort),
%                                      the arguments are always printed out at level 10
%                                    at level 0 is for debug only : e.g. Path info messages that indicate the path that is being followed
%                                    at level 4 and above soundness may be affected or efficiency impeded
%                                       from level 1 to 9 the arguments are only printed in release mode if surrounded by 'print'
%                                    1 is the lowest warning level with no consequences at all
%Error_message : a string to explain to developers and users what the error is and why it was raised
%Error_consequences : optional, a string to explain potential consequences
%ArgumentsL : optional, a list of pairs (Description, Item)
%Error_code : an integer code starting with the Error_severity, followed by date of creation and if necessary another digit that is unique per call to common_util__error (to be used in 'find in files') e.g 10260724
%From_module : an atom denoting the originating module
%From_predicate : an atom denoting the originating predicate
%Localisation : optional, an atom or a compound term providing further localisation information
%Extra_info : optional, a string of anything you want
common_util__error(Error_severity, Error_message, Error_consequences, ArgumentsL, Error_code, From_module, From_predicate, Localisation, Extra_info) :-
       se_globals__get_val('already_printed', Already_printed),
       (memberchk(error(Error_code, Previous_occurrences), Already_printed)  ->
              (Previous_occurrences == 9 ->
                     Occurences = 9
              ;
                     (append(Start, [error(Error_code, _)|Rest], Already_printed), %todo there must be a better way of doing this: don't use a list?
                      !,    
                      Occurences is Previous_occurrences + 1,
                      append(Start, [error(Error_code, Occurences)|Rest], New_already_printed),
                      se_globals__set_val('already_printed', New_already_printed)
                     )
              )
       ;
              (Occurences = 1,
               se_globals__set_val('already_printed', [error(Error_code, Occurences)|Already_printed])
              )
       ),
       (Occurences == 9 -> %only print the same warning message a fixed number of times to avoid overwhelming the logs
              true
       ;
              (se_globals__get_val('errorMessageNb', ErrorNb),
               ErrorNb1 is ErrorNb + 1,
               %(ErrorNb1 == 34 -> mytrace ; true),
               printf(output, "Error Nb: %w: ", [ErrorNb1]),
               se_globals__set_val('errorMessageNb', ErrorNb1),
               se_globals__get_val('message_mode', Message_mode),
               common_util__error2(Error_severity, Error_message, Error_consequences, ArgumentsL, Error_code, From_module, From_predicate, Localisation, Extra_info, Message_mode)
              )
       ).

common_util__error2(10, Error_message, Error_consequences, ArgumentsL, Error_code, From_module, From_predicate, Localisation, Extra_info, Message_mode) :-
    !,
    (Message_mode == debug ->
            (printf(output, "###################################%n", []),
             printf(output, "=>Sikraken: a fatal error has occurred%n", []),
             printf(output, "        Error Code: %w%n", [Error_code]),
             printf(output, "        Message: %s%n", [Error_message]),
             (ArgumentsL == no_arguments ->
                    true
             ;
                    (printf(output, "        Arguments: ", []),
                     cue_print_error_arguments(ArgumentsL, debug)
                    )
             ),
             (Error_consequences == no_error_consequences ->
                    true
             ;
                    printf(output, "        Consequences: %s%n", [Error_consequences])
             ),
             printf(output, "        Localisation: in %w module, at %w predicate", [From_module, From_predicate]),
             (Localisation == no_localisation ->
                    printf(output, "%n", [])
             ;
                    printf(output, ", for %w case%n", [Localisation])
             ),
             (Extra_info == no_extra_info ->
                    true
             ;
                    printf(output, "        Extra Info: %s%n", [Extra_info])
             ),
             %debugging information
             printf(output, "        Debugging Info: %n", []),
             se_globals__get_val('debug_info', Current),
             printf(output, "            Was processing the %w entity when error occurred%n", [Current]),
             printf(output, "            To help debugging, path information prior to error follows ...%n", []),
             se_globals__get_ref('current_path_bran', Current_path_bran),
             printf(output, "            Branches followed prior to error : %w%n", [Current_path_bran]),
             printf(output, "###################################%n", [])
            )
    ;
            (printf(output, "%2n###################################%n", []),
             printf(output, "=>Sikraken: a fatal error has occurred%n", []),
             printf(output, "        Error Code: %w%n", [Error_code]),
             printf(output, "        Message: %s%n", [Error_message]),
             (ArgumentsL = no_arguments ->
                    true
             ;
                    (printf(output, "        Arguments: ", []),
                     cue_print_error_arguments(ArgumentsL, release)
                    )
             ),
             printf(output, "=>Report error to echancrure@gmail.com to have it addressed.%n", []),
             printf(output, "###################################%n", [])
            )
    ),
    log_and_terminate @ eclipse,
    flush(output),
    abort.

common_util__error2(0, Error_message, Error_consequences, ArgumentsL, _Error_code, From_module, From_predicate, Localisation, Extra_info, Message_mode) :-
    !,
    (Message_mode == debug ->
            (printf(output, "Debug_info: %s", [Error_message]),
             (ArgumentsL == no_arguments ->
                    true
             ;
                    cue_print_warning_arguments(ArgumentsL, debug)
             ),
             (Error_consequences == no_error_consequences ->
                    true
             ;
                    printf(output, ", %s", [Error_consequences])
             ),
             printf(output, " in %w module, at %w predicate", [From_module, From_predicate]),
             (Localisation == no_localisation ->
                    true
             ;
                    printf(output, ", for %w case", Localisation)
             ),
             (Extra_info == no_extra_info ->
                    printf(output, "%n", [])
             ;
                    printf(output, ", %s%n", [Extra_info])
             )
            )
    ;
            true
    ),
    flush(output).

common_util__error2(Error_severity, Error_message, Error_consequences, ArgumentsL, Error_code, From_module, From_predicate, Localisation, Extra_info, Message_mode) :-
    (Message_mode == debug ->
            (printf(output, "Sikraken warning level %w, %w, %s", [Error_severity, Error_code, Error_message]),
             (ArgumentsL == no_arguments ->
                    true
             ;
                    cue_print_warning_arguments(ArgumentsL, debug)
             ),
             (Error_consequences == no_error_consequences ->
                    true
             ;
                    printf(output, ", %s", [Error_consequences])
             ),
             printf(output, " in %w module, at %w predicate", [From_module, From_predicate]),
             (Localisation == no_localisation ->
                    true
             ;
                    printf(output, ", for %w case", Localisation)
             ),
             (Extra_info == no_extra_info ->
                    printf(output, "%n", [])
             ;
                    printf(output, ", %s%n", [Extra_info])
             ),
             flush(output)     %only in debug mode as costly
            )
    ;
            ((Error_severity == 1 ->
                    printf(output, "%s%n", [Error_message])
             ;
                    printf(output, "Sikraken warning level %w %w %s", [Error_severity, Error_code, Error_message])
             ),
             (ArgumentsL == no_arguments ->
                    true
             ;
                    (cue_print_warning_arguments(ArgumentsL, debug),
                     printf(output, "%n", [])
                    )
             )
            )
    ).
    
cue_print_warning_arguments([], _Debug) :-
    !.
cue_print_warning_arguments([Warning|Rest], Debug) :-
    (((Debug == debug , Warning = (Entry, Argument)) ; Warning = print(Entry, Argument)) ->
         printf(output, ", %w : %w", [Entry, Argument])
    ;
       true    %ignored
    ),
    cue_print_warning_arguments(Rest, Debug).

cue_print_error_arguments([(Entry, Argument)|R], Debug) :-
    !,
    (Debug == debug ->
            printf(output, "%w : %p%n", [Entry, Argument])
    ;
            printf(output, "%w : %w%n", [Entry, Argument])
    ),
    cuepea_print_error_arguments_rest(R, Debug).

cuepea_print_error_arguments_rest([], _).
cuepea_print_error_arguments_rest([(Entry, Argument)|R], Debug) :-
    (Debug == debug ->
            printf(output, "                   %w : %p%n", [Entry, Argument])
    ;
            printf(output, "                   %w : %w%n", [Entry, Argument])
    ),
    cuepea_print_error_arguments_rest(R, Debug).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%