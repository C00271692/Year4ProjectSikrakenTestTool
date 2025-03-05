%16 Nov 2024
%"An object is a named region of storage; an lvalue is an expression referring to an object" -K&R p. 197
%get_symbolic_lvalue_for_addressing returns this region of storage, e.g. a variable, a struct member, an array element, the dereference of a pointer expression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
get_symbolic_lvalue_for_addressing(LValue_expression, Type, LValue) :-
    var(LValue_expression),
    !,
    (seav__is_seav(LValue_expression) ->
        (seav__get(LValue_expression, 'type', Type),
         LValue = LValue_expression    %that's the difference with symbolic execution: we only return the object i.e. here the SEAV variable and not its contents
        )
    ;
        common_util__error(9, "Unknown LValue variable", "Sikraken needs expanding", [('LValue_expression', LValue_expression)], '09_261124', 'se_get_symbolic_lvalue', 'get_symbolic_lvalue_for_addressing', no_localisation, no_extra_info)
    ).
get_symbolic_lvalue_for_addressing(int(0), void, 0) :- %the location of 0 aka NULL: used for initialisations
    !.
get_symbolic_lvalue_for_addressing(LValue_expression, void, 0) :-
    !,
    common_util__error(9, "Unknown LValue expression", "Sikraken needs expanding", [('LValue_expression', LValue_expression)], '09_161124', 'se_get_symbolic_lvalue', 'get_symbolic_lvalue_for_addressing', no_localisation, no_extra_info).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%