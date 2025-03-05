%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEAV
% Defines the module seav for Symbolic Execution Attributed Variables
% It implements the Variable-Level Stack solution to the scoping of identifiers in C
% The attribute is of the form: se_seav_atts([scope(Type_name, Input_value, Output_value)|Older]) and denotes for the id of SEAV a stack of scopes with its top at the head   
%   Type_name    : just the type_name of the variable
%   Input_value  : the input value of the variable: free for uninitialised variables, immutable during symbolic execution
%   Output_value : the current value of the variable: initially Input_value, mutated via assignments
% The predicate push_scope_list is called when an identifier is declared 
% The predicate pop_scope_list is awakened when an identifer is out of scope (e.g. at the end of a block) 
% The global reference 'scope_stack' is of the form [scope(Current_level, Current_var_scope)|Older] and denotes the global stack of scope levels with its top at the head
%   It is used during symbolic execution to indicate when a scope is entered or left
%   Current_level : an integer
%   Current_var_scope : a free Prolog variable, which is instantiated on leaving a scope and thus trigger all the id-level scopes for the ids declared in that scope to be popped   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- module('se_seav_atts').
:- export seav__create_var/4, seav__is_seav/1, seav__get/3, seav__update/3, seav__seav_is_in_scope/1.
:- use_module(['se_globals']).
:- meta_attribute('se_seav_atts', [unify:unify_seav/2, print:print_seav/2]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%internal attributed variable handlers
%called to confirm unification after unification with an another attributed variable or a non-variable
%Value is a non-variable or another attributed variable
unify_seav(_, Attr) :-          %ECLiPSe fails on compilation if this is not present even though the documentation says that the handler is not called in this case 
    var(Attr).                  %Ignore if no attribute for this extension
unify_seav(Term, _Attr) :-
    meta(Term),                 %fails otherwise: e.g. when unified with an atom
    fail.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_seav(_{se_seav_atts(Scope_list)}, Print) :-
	-?->
	Print = seav(Scope_list).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seav__create_var(Type_name, Input, Output, SEAV):-
    (seav__is_seav(SEAV) -> %it is already a SEAV, so new scope: must shadow
        push_scope_list(SEAV, scope(Type_name, Input, Output))
    ;
        add_attribute(SEAV, se_seav_atts([scope(Type_name, Input, Output)])) %brand new SEAV only has one scope
    ),
    se_globals__get_ref('scope_stack', [scope(_Current_level, Current_var_scope)|_]),
    suspend(pop_scope_list(SEAV), 3, Current_var_scope->inst).  %delays pop_scope_list until Current_var_scope becomes instantiated (i.e. when leaving a scope)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    push_scope_list(_{Attr}, New_scope) :-
        -?->
        Attr = se_seav_atts(Old_scopes),
        setarg(1, Attr, [New_scope|Old_scopes]).
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %called when awakened by leaving a scope
    pop_scope_list(_{Attr}) :-
        -?->
        Attr = se_seav_atts([_|Old_scopes]),
        setarg(1, Attr, Old_scopes).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seav__is_seav(_{Attr}) :-
    -?->
    compound(Attr),
    Attr = se_seav_atts(_).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seav__seav_is_in_scope(_{Attr}) :-
    -?->
    compound(Attr),
    Attr = se_seav_atts(ScopeL),
    ScopeL \== [].
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seav__get(_{Attr}, 'type', Type_name) :-        
    -?->
    Attr = se_seav_atts([scope(Type_name, _, _)|_]).
seav__get(_{Attr}, 'input', Input) :-        
    -?->
    Attr = se_seav_atts([scope(_, Input, _)|_]).
seav__get(_{Attr}, 'output', Output) :-        
    -?->
    Attr = se_seav_atts([scope(_, _, Output)|_]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
seav__update(_{Attr}, 'input', Input) :-        
    -?->
    Attr = se_seav_atts([scope(Type_name, _, Output)|R]),
    setarg(1, Attr, [scope(Type_name, Input, Output)|R]).
seav__update(_{Attr}, 'output', Output) :-        
    -?->
    Attr = se_seav_atts([scope(Type_name, Input, _)|R]),
    setarg(1, Attr, [scope(Type_name, Input, Output)|R]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%