%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% se_typedef_atts.pl
% Defines the module for attributed typedef declarations: a very close copy of se_name_atts.pl
% Unique argument is the type represented 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
:- module('se_typedef_atts').
%%%
:- export se_typedef_atts__is_typedef_atts/1, se_typedef_atts__create/2, se_typedef_atts__get/3.

:- meta_attribute('se_typedef_atts', [unify:unify_typedef/2, print:print_typedef/2]).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%called to confirm unification after unification with an another attributed variable or a non-variable
%Value is a non-variable or another attributed variable
unify_typedef(_, Typedef_attr) :-			%ECLiPSe fails on compilation if this is not present even though the documentation says that the handler is not called in this case 
	var(Typedef_attr).                    	%Ignore if no attribute for this extension
unify_typedef(Term, Typedef_attr) :-
	compound(Typedef_attr), %todo: revisit and do the same as for SEAVs
	unify_term_typedef(Term, Typedef_attr).

unify_term_typedef(_{AttrY}, Typedef_attr) :-   %META + META
	-?->
	Typedef_attr = AttrY.  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
print_typedef(_{se_typedef_atts(Type)}, Print) :-
	-?->
	Print = type_from_typedef(Type).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_typedef_atts__is_typedef_atts(_{se_typedef_atts(Type)}) :-
    -?->
    true.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_typedef_atts__create(Type, Typedef_atts) :-
    add_attribute(Typedef_atts, se_typedef_atts(Type)).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
se_typedef_atts__get(_{Attr}, 'type', Type) :-
    -?->
    Attr = se_typedef_atts(Type).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%