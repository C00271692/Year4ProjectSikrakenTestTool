%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% se_sub_atts.pl
% Defines the module for attributed subprogram variables
% The attribute is of the form: se_sub_atts(Return_type, Parameters, Body)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- module('se_sub_atts').

%%%
:- export se_sub_atts__is_sub_atts/1, se_sub_atts__create/4, se_sub_atts__get/3.

:- meta_attribute('se_sub_atts', [unify:unify_sub/2, print:print_sub/2]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%internal attributed variable handlers
%called to confirm unification after unification with an another attributed variable or a non-variable
%Value is a non-variable or another attributed variable
unify_sub(_, Attr) :-
	var(Attr).                       %ANY+META
unify_sub(Term, Attr) :-
	compound(Attr),
	unify_term_sub(Term, Attr).
unify_term_sub(_{AttrY}, AttrX) :-   %META + META
	-?->
	AttrX = AttrY.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_sub(_{se_sub_atts(Return_type, Params, Body)}, Print) :-
	-?->
	Print = sub_atts(Return_type, Params, Body).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_sub_atts__is_sub_atts(_{se_sub_atts(_, _, _)}) :-
    -?->
    true.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_sub_atts__create(Return_type, Parameters, Body, Sub_atts) :-
    (se_sub_atts__is_sub_atts(Sub_atts) ->  %redeclaration of a function
        true    %we assume semantically equivalent since compiler is assumed happy, and keep the original function intact 
    ;
        add_attribute(Sub_atts, se_sub_atts(Return_type, Parameters, Body))
    ).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_sub_atts__get(_{Attr}, 'return_type', Return_type) :-
    -?->
    Attr = se_sub_atts(Return_type, _, _).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_sub_atts__get(_{Attr}, 'parameters', Parameters) :-
    -?->
    Attr = se_sub_atts(_, Parameters, _).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_sub_atts__get(_{Attr}, 'body', Body) :-
    -?->
    Attr = se_sub_atts(_, _, Body).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%