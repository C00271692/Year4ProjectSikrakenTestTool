symbolically_interpret(Expression, symb(Type, Symbolic_expression)) :-  %need to be at the top so that it does not unify with the other predicates below
    var(Expression),
    seav__is_seav(Expression), 
    !,
    seav__get(Expression, 'type', Type),
    seav__get(Expression, 'output', Symbolic_expression).
symbolically_interpret('uninitialised', symb(void, 'uninitialised')) :-
    !.
symbolically_interpret(int(Expression), symb(int, Expression)) :-   %constant with no suffix
    !.
symbolically_interpret(unsigned(Expression), symb(unsigned(int), Expression)) :- %u constant, identified in parser
    !.
symbolically_interpret(unsigned_long(Expression), symb(unsigned(long), Expression)) :- %ul constant, identified in parser
    !.
symbolically_interpret(unsigned_long_long(Expression), symb(unsigned(long_long), Expression)) :- %ull constant, identified in parser
    !.
symbolically_interpret(long(Expression), symb(long, Expression)) :- %l constant, identified in parser
    !.
symbolically_interpret(long_long(Expression), symb(long_long, Expression)) :- %ll constant, identified in parser
    !.
symbolically_interpret(double(Expression), symb(double, Expression)) :-   %double is the default type for floating point constants, identified in parser
    !.
symbolically_interpret(float(Expression), symb(float, Expression)) :-     %f constant, identified in parser
    !.
symbolically_interpret(long_double(Expression), symb(long_double, Expression)) :-     %l constant, identified in parser
    !.
symbolically_interpret(function_call(Function, Arguments), Symbolic_expression) :-
    !,
    %mytrace,
    (se_sub_atts__is_sub_atts(Function) ->
        (se_sub_atts__get(Function, 'body', Body),
         (Body == 'no_body_is_extern' -> %calling an extern function with no body
            (se_name_atts__get(Function, 'name', Function_name),
                (is_verifier_input_function(Function_name, Type) ->
                    (%mytrace,
                     ptc_solver__create_variable(Type, Input_var),
                     se_globals__get_ref('verifier_inputs', Verifier_inputs),
                     append(Verifier_inputs, [verif(Type, Input_var)], New_verifier_inputs),
                     se_globals__set_ref('verifier_inputs', New_verifier_inputs),
                     Symbolic_expression = symb(Type, Input_var)
                    )
                ;
                (Function_name == 'Exit' ; Function_name == 'Abort' ; Function_name == 'UC___assert_fail') ->
                    (%Arguments = [Exit_code],
                     %common_util__error(0, "Exit Called:", 'no_error_consequences', [('Exit_code', Exit_code)], '0_170824_1', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info),
                     %mytrace,
                     Symbolic_expression = symb(void, Function_name),  %unused, just for symmetry
                     (end_of_path_predicate(_, _) ->  % we try to label and generate a test input vector
                        (%labeling suceeded, a test vector was generated, and new arcs added to covered
                         fail
                        )
                     ;   
                        %labeling failed...no test input vector was generated, the exit did not occur
                        fail
                     )
                    )
                ;
                    (common_util__error(9, "Function call to unknown external function", "Cannot perform symbolic interpretation", [('Function_name', Function_name)], '09_150824_3', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info),
                     Symbolic_expression = symb(int, 0)
                    )
                )
            )
         ;
            (%mytrace,
             se_sub_atts__get(Function, 'parameters', Parameters),
             se_sub_atts__get(Function, 'return_type', Return_type),
             se_globals__push_scope_stack,          %function parameters scope
             match_parameters_arguments(Parameters, Arguments),
             symbolic_execute(Body, Flow),
             (Flow = return(symb(From_type, Return_expression)) ->
                (ptc_solver__perform_cast(cast(Return_type, From_type), Return_expression, Casted),
                 Symbolic_expression = symb(Return_type, Casted)
                 %was%symbolically_interpret(cast(Return_type, Return_expression), Symbolic_expression)
                )
             ;
                Symbolic_expression = symb('void', 0)   %e.g. via a fall through or a simple return statement with no expression
             ),
             se_globals__pop_scope_stack            %function parameters scope
            )
         )
        )
    ;
        (se_name_atts__get(Function, 'name', Function_name),
         %mytrace,
         common_util__error(9, "Calling a non-extern function that has not been defined", "Seriously wrong; Suggest add include or declare as extern", [('Function_name', Function_name)], '9_100924_1', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info),
         Symbolic_expression = symb(int, 0)
        )
    ).
symbolically_interpret(cast(Raw_typeL, Expression), symb(To_type, Casted)) :-
    !,
    (is_list(Raw_typeL) ->
        (%mytrace, 
         extract_type(Raw_typeL, To_type)    %list of declaration_specifiers
        )
    ;
        To_type = Raw_typeL     %an internal call, already transformed
    ),
    symbolically_interpret(Expression, symb(From_type, Symbolic)),
    (To_type == 'void' ->    %casting to void: discard the expression, but evaluation above still has to happen
        Casted = addr(0)     %just to return something but hopefully will not be used
    ;    
        ptc_solver__perform_cast(cast(To_type, From_type), Symbolic, Casted)
    ).
symbolically_interpret(addr(Expression), symb(pointer(Type), addr(LValue))) :-
    !,
    get_symbolic_lvalue_for_addressing(Expression, Type, LValue).  %not normal symbolic execution: stop once we get an lvalue
symbolically_interpret(deref(Expression), Symbolic_expression) :-
    !,
    symbolically_interpret(Expression, Symbolic_expression_ptr),
    (Symbolic_expression_ptr = symb(_, addr(Inner_symbolic_expression)) ->   %todo: need testing with many levels of derefs
        symbolically_interpret(Inner_symbolic_expression, Symbolic_expression)
    ;
        common_util__error(10, "Dereferencing something which is not a pointer", "Cannot perform symbolic interpretation", [('Symbolic_expression_ptr', Symbolic_expression_ptr)], '10_040924_2', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info)
    ).
symbolically_interpret(index(Array_exp, Index_exp), symb(Element_type, Element)) :-
    !,
    symbolically_interpret(Index_exp, symb(_, Index_value)),
    symbolically_interpret(Array_exp, symb(Array_type, Array_value)),
    (Array_type = array(Element_type, _) ->
        ptc_solver__arithmetic(element(Array_value, [Index_value]), Element)
    ;
     (Array_type = pointer(Element_type), Array_value = addr(Array_var), ptc_solver__is_array(Array_var)) ->
        %dereference of an array name e.g. int *pv = vector; ...pv[3]...
        ptc_solver__arithmetic(element(Array_var, [Index_value]), Element)
    ;
        (common_util__error(9, "Indexing something which is not an array", "Cannot perform symbolic interpretation", [('Array_type', Array_type)], '9_181124', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info),
         Element_type = int,
         Element = 0
        )
    ).
symbolically_interpret(up_rec(Struct_exp, Field, Expression), symb(Struct_type, New_struct)) :-
    !,
    symbolically_interpret(Struct_exp, symb(Struct_type, Struct_value)),
    symbolically_interpret(Expression, symb(_, Expression_value)),  %casting ? do it here or in solver?
    ptc_solver__up_record(Struct_value, Field, Expression_value, New_struct).

symbolically_interpret(select(Struct_exp, Field), symb(Member_type, Member)) :-
    !,
    symbolically_interpret(Struct_exp, symb(_, Struct_value)),
    ptc_solver__get_field(Struct_value, Field, Member_type, Member).
symbolically_interpret('no_initialiser', symb(_, 'no_initialiser')) :-
    !.
symbolically_interpret(initializer([]), symb(_, initialiser([]))) :-
    !.
symbolically_interpret(initializer([Expr|Rest_expr]), symb(_, initialiser([symb(Value_type, Value)|Value_list]))) :-
    !,
    %mytrace,
    symbolically_interpret(Expr, symb(Value_type, Value)),
    symbolically_interpret(initializer(Rest_expr), symb(_, initialiser(Value_list))).
symbolically_interpret(multiply_op(Le_exp, Ri_exp), symb(Common_type, Casted_result)) :-
    !,
    %mytrace,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    Result $= Le_casted_exp * Ri_casted_exp,
    ptc_solver__check_overflow(Common_type, Result, Casted_result).

%todo what do we do on div by 0?
symbolically_interpret(div_op(Le_exp, Ri_exp), symb(Common_type, Casted_result)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    (Common_type == 'int' ->
        ptc_solver__arithmetic(div(Le_casted_exp, Ri_casted_exp), Result, _)
    ;
        Result $= Le_casted_exp / Ri_casted_exp
    ),
    ptc_solver__check_overflow(Common_type, Result, Casted_result).
%mod is not an IC constraint, rem is but it behaves differently and any in C: a mod b == a - b(a//b)
%todo what do we do on div by 0?
symbolically_interpret(mod_op(Le_exp, Ri_exp), symb(Common_type, Casted_result)) :-
    !,   
    %mytrace,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    Result #= Le_casted_exp - Ri_casted_exp*(Le_casted_exp//Ri_casted_exp),
    ptc_solver__check_overflow(Common_type, Result, Casted_result).

symbolically_interpret(plus_op(Le_exp, Ri_exp), symb(Common_type, Casted_result)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    Result $= Le_casted_exp + Ri_casted_exp,
    ptc_solver__check_overflow(Common_type, Result, Casted_result).
symbolically_interpret(plus_op(Expression), symb(Promoted_type, Checked_result)) :-
    !,
    %mytrace,
    symbolically_interpret(Expression, symb(Type, Symbolic_expression)),
    apply_integral_promotion(Type, Promoted_type),
    Result $= Symbolic_expression,
    ptc_solver__perform_cast(cast(Type, Promoted_type), Result, Checked_result).
symbolically_interpret(minus_op(Le_exp, Ri_exp), symb(Common_type, Casted_result)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    Result $= Le_casted_exp - Ri_casted_exp,
    ptc_solver__check_overflow(Common_type, Result, Casted_result).
symbolically_interpret(minus_op(Expression), symb(Promoted_type, Checked_result)) :-
    !,
    %mytrace,
    symbolically_interpret(Expression, symb(Type, Symbolic_expression)),
    apply_integral_promotion(Type, Promoted_type),  %special case if Promoted_type is unsigned(int), unsigned(long) or unsigned(long_long)
    Result $= -Symbolic_expression,
    (Promoted_type = unsigned(Signed_type) ->
        ptc_solver__perform_cast(cast(Promoted_type, Signed_type), Result, Casted_result)
    ;
        ptc_solver__perform_cast(cast(Type, Promoted_type), Result, Casted_result)
    ),
    ptc_solver__check_overflow(Promoted_type, Casted_result, Checked_result).

%%%relational operators: todo a lot of code is repeated: refactor
symbolically_interpret(less_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(<, Le_casted_exp, Ri_casted_exp, R).
symbolically_interpret(greater_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(>, Le_casted_exp, Ri_casted_exp, R).
symbolically_interpret(less_or_eq_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(=<, Le_casted_exp, Ri_casted_exp, R).
symbolically_interpret(greater_or_eq_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(>=, Le_casted_exp, Ri_casted_exp, R).
symbolically_interpret(equal_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(=, Le_casted_exp, Ri_casted_exp, R).
symbolically_interpret(not_equal_op(Le_exp, Ri_exp), symb(int, R)) :-
    !,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, _Common_type, Le_casted_exp, Ri_casted_exp),
    ptc_solver__relation(\=, Le_casted_exp, Ri_casted_exp, R).
%%%
symbolically_interpret(prefix_inc_op(Expression), Symbolic_expression) :-
    !,
    symbolically_interpret(plus_op(Expression, int(1)), Symbolic_expression),
    symbolic_execute(assign(Expression, plus_op(Expression, int(1))), _Flow).  %todo Expression should only be symbolic executed once
symbolically_interpret(prefix_dec_op(Expression), Symbolic_expression) :-
    !,
    symbolically_interpret(minus_op(Expression, int(1)), Symbolic_expression),
    symbolic_execute(assign(Expression, minus_op(Expression, int(1))), _Flow).      %todo Expression should only be symbolic executed once
%
symbolically_interpret(postfix_inc_op(Expression), Symbolic_expression) :-
    !,
    symbolically_interpret(Expression, Symbolic_expression),
    symbolic_execute(assign(Expression, plus_op(Expression, int(1))), _Flow).       %todo Expression should only be symbolic executed once
symbolically_interpret(postfix_dec_op(Expression), Symbolic_expression) :-
    !,
    symbolically_interpret(Expression, Symbolic_expression),
    symbolic_execute(assign(Expression, minus_op(Expression, int(1))), _Flow).      %todo Expression should only be symbolic executed once
%%%
%L and R: C semantics of && is always short circuit
%either L is true and overall truth is R's
%or L is false and overall truth is false
symbolically_interpret(and_op(Le_exp, Ri_exp), symb(int, R)) :-   
    !,
    (R == 1 -> %forcing true
        (symbolically_interpret(Le_exp, symb(_, 1)),
         symbolically_interpret(Ri_exp, symb(_, 1))
        )
    ;
     R == 0 -> %forcing false
        ((random(2, 0) ->
            (   symbolically_interpret(Le_exp, symb(_, 0))    %force Le to be false
            ;%deliberate choice point
                (symbolically_interpret(Le_exp, symb(_, 1)),    %impose true Le first
                 symbolically_interpret(Ri_exp, symb(_, 0))     %and force Ri to be false
                )
            )
         ;
            (   (symbolically_interpret(Le_exp, symb(_, 1)),    %impose true Le first
                 symbolically_interpret(Ri_exp, symb(_, 0))     %and force Ri to be false
                )
            ;%deliberate choice point
                symbolically_interpret(Le_exp, symb(_, 0))    %force Le to be false
            )
         )
        )  
    ;
        (R #:: 0..1,    %not forcing anything
         %mytrace, 
         symbolically_interpret(Le_exp, symb(_, Le_symbolic)), %only performed once as it should
         (Le_symbolic == 1 ->        
            symbolically_interpret(Ri_exp, symb(_, R))
         ;
          Le_symbolic == 0 ->        
            R #= 0
         ;    
          (random(2, 0) -> %i.e. between 0 and 2-1, so only 2 values allowed 0 or 1
                (
                    (ptc_solver__sdl(Le_symbolic),          %impose true Le first
                     symbolically_interpret(Ri_exp, symb(_, R)) %R is still undecided
                    )
                ;%deliberate choice point
                    (ptc_solver__sdl(not(Le_symbolic)),     %impose false Le
                     R #= 0                                 %R is false
                    )
                )
          ;
                (
                    (ptc_solver__sdl(not(Le_symbolic)),     %impose false Le first
                     R #= 0                                 %R is false
                    )
                ;%deliberate choice point
                    (ptc_solver__sdl(Le_symbolic),          %impose true Le
                     symbolically_interpret(Ri_exp, symb(_, R)) %R is still undecided
                    )
                )
          )
         )
        )
    ).
%%%
%L or R: C semantics of || is always short circuit
%either L is true and overall truth is true
%or L is false and overall truth is R's
symbolically_interpret(or_op(Le_exp, Ri_exp), symb(int, R)) :-   
    !,
    (R == 1 -> %forcing true
        ((random(2, 0) ->
            (   symbolically_interpret(Le_exp, symb(_, 1))
            ;%deliberate choice point
                (symbolically_interpret(Le_exp, symb(_, 0)),
                 symbolically_interpret(Ri_exp, symb(_, 1))     
                )
            )
         ;
            (   (symbolically_interpret(Le_exp, symb(_, 0)),
                 symbolically_interpret(Ri_exp, symb(_, 1))
                )
            ;%deliberate choice point
                symbolically_interpret(Le_exp, symb(_, 1))
            )
         )
        )  
    ;
     R == 0 -> %forcing false
                (symbolically_interpret(Le_exp, symb(_, 0)),
                 symbolically_interpret(Ri_exp, symb(_, 0))
                )
    ;
        (R #:: 0..1,    %not forcing anything
         %mytrace,
         symbolically_interpret(Le_exp, symb(_, Le_symbolic)), %only performed once as it should
         (Le_symbolic == 1 ->
            R #= 1
         ;
          Le_symbolic == 0 ->
            symbolically_interpret(Ri_exp, symb(_, R))
         ;
            (random(2, 0) -> %i.e. between 0 and 2-1, so only 2 values allowed 0 or 1
                (
                    (
                        (ptc_solver__sdl(Le_symbolic),
                         R #= 1
                        )
                    ;%deliberate choice point
                        (ptc_solver__sdl(not(Le_symbolic)),
                         symbolically_interpret(Ri_exp, symb(_, R))
                        )
                    )
                )
             ;
                (
                    (
                        (ptc_solver__sdl(not(Le_symbolic)),
                         symbolically_interpret(Ri_exp, symb(_, R))
                        )
                    ;%deliberate choice point
                        (ptc_solver__sdl(Le_symbolic),
                         R #= 1
                        )
                    )
                )
            )
         )
        )
    ).
%%%
%
symbolically_interpret(not_op(Le_exp), symb(int, R)) :-
    !,
    R #:: 0..1,
    (var(Le_exp) ->
        (symbolically_interpret(Le_exp, symb(_, Le_symbolic)),
         R #= neg(Le_symbolic)
        )
    ;
     Le_exp = and_op(Le, Ri) ->
        symbolically_interpret(or_op(not_op(Le), not_op(Ri)), symb(_, R))
    ;
     Le_exp = or_op(Le, Ri) ->
        symbolically_interpret(and_op(not_op(Le), not_op(Ri)), symb(_, R))
    ;
     Le_exp = not_op(Le) ->  %double negation
        symbolically_interpret(Le, symb(_, R))
    ;
        (symbolically_interpret(Le_exp, symb(_, Le_symbolic)),
         R #= neg(Le_symbolic)
        )
    ).
%handling of conditional expression construct in C "(cond) ? true_exp : false_exp"
symbolically_interpret(cond_exp(branch(Id, Condition), True_exp, False_exp), symb(Common_type, Symbolic)) :-
    !,
    %mytrace,
    %resulting Common_type is not sound: according to C standard type of the overall conditional expression is the common type of the True and False expressions, 
    %but because we do not extract types statitically extracting both types would mean symbolically executing both expressions which due to side effects, would be even more unsound
    %todo revisit when type extraction can be performed statically: e.g. in parser or during CFG building   
    symbolically_interpret(Condition, symb(_, Cond_Symbolic)),
    (Cond_Symbolic == 1 ->    %to avoid creating unnecessary choice point 
        (se_globals__update_ref('current_path_bran', branch(Id, 'true')),
         symbolically_interpret(True_exp, symb(Common_type, Symbolic))
        )
    ;
     Cond_Symbolic == 0 ->    %to avoid creating unnecessary choice point 
        (se_globals__update_ref('current_path_bran', branch(Id, 'false')),
         symbolically_interpret(False_exp, symb(Common_type, Symbolic))
        )
    ;
        (random(2, R2), %i.e. between 0 and 2-1, so only 2 values allowed 0 or 1
         %R2 = 0, 
         %mytrace,
         (R2 == 0 -> %randomness to ensure true and false expressions are given equal chances
            (
                (ptc_solver__sdl(Cond_Symbolic),
                 se_globals__update_ref('current_path_bran', branch(Id, 'true')),
                 symbolically_interpret(True_exp, symb(Common_type, Symbolic))
                )
            ;%deliberate choice point
                (ptc_solver__sdl(not(Cond_Symbolic)),
                 se_globals__update_ref('current_path_bran', branch(Id, 'false')),
                 symbolically_interpret(False_exp, symb(Common_type, Symbolic))
                )
            )
         ;
            (
                (ptc_solver__sdl(not(Cond_Symbolic)),
                 se_globals__update_ref('current_path_bran', branch(Id, 'false')),
                 symbolically_interpret(False_exp, symb(Common_type, Symbolic))
                )
            ;%deliberate choice point
                (ptc_solver__sdl(Cond_Symbolic),
                 se_globals__update_ref('current_path_bran', branch(Id, 'true')),
                 symbolically_interpret(True_exp, symb(Common_type, Symbolic))
                )
            )
         )
        )
    ).
%%% bitwise operators %%%
    %we use the equivalence of ~x == -(x+1) which holds for signed an unsigned in c
symbolically_interpret(bw_one_comp(Le_exp), symb(Common_type, -(Le_casted_exp + 1))) :-
    !,
    %mytrace,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    implicit_type_casting(Le_type, int, Le_symbolic, 0, Common_type, Le_casted_exp, _).

symbolically_interpret(bitwise(Op, Le_exp, Ri_exp), symb(Common_type, Result)) :-
    !,
    %mytrace,
    symbolically_interpret(Le_exp, symb(Le_type, Le_symbolic)),
    symbolically_interpret(Ri_exp, symb(Ri_type, Ri_symbolic)),
    implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp),
    (Common_type = unsigned(_) ->
        Sign = 'unsigned'
    ;
        Sign = 'signed'
    ),
    ptc_solver__size(Common_type, Byte_size),
    Len is Byte_size * 8,
    ptc_solver__create_variable(Common_type, Result),
    (Op == bw_and ->
        ptc_solver__arithmetic(bw_and(Le_casted_exp, Ri_casted_exp, Len, Sign), Result, _)
    ;
     Op == bw_or ->
        ptc_solver__arithmetic(bw_or(Le_casted_exp, Ri_casted_exp, Len, Sign), Result, _)
    ;
     Op == bw_xor ->
        ptc_solver__arithmetic(bw_xor(Le_casted_exp, Ri_casted_exp, Len, Sign), Result, _)
    ;
     Op == left_shift ->
        ptc_solver__arithmetic(left_shift(Le_casted_exp, Ri_casted_exp, Len, Sign), Result, _)
    ;
     Op == right_shift ->
        ptc_solver__arithmetic(right_shift(Le_casted_exp, Ri_casted_exp, Len, Sign), Result, _)
    ;
        common_util__error(9, "Invalid bitwise operator", "Cannot perform symbolic interpretation", [print('Op', Op)], '9_020824_2', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info)
    ).
%%%
symbolically_interpret(comma_op(Left_expression, Right_expression), Symbolic_expression) :-
    !,
    symbolically_interpret(Left_expression, _),
    symbolically_interpret(Right_expression, Symbolic_expression).
symbolically_interpret(size_of_exp(Expression), symb(unsigned(int), Size)) :-
    !,
    symbolically_interpret(Expression, symb(Type_name, _)),      %should not be evaluated: should be done at parsing time
    ptc_solver__size(Type_name, Size).
symbolically_interpret(size_of_type(Specifiers), symb(unsigned(int), Size)) :-
    !,
    extract_type(Specifiers, Type_name),
    ptc_solver__size(Type_name, Size).
%%% GCC statement expression %%%
symbolically_interpret(stmt_exp(Compound_statement), symb(void, 0)) :-    
    !,
    symbolic_execute(Compound_statement, _Flow). %not handled properly: if the last statement is an expression, that should be the symbolic value and type
%%%
symbolically_interpret(Unhandled_expression, symb(int, 0)) :-
    !,
    common_util__error(9, "Expression is not handled", "Cannot perform symbolic interpretation", [print('Unhandled_expression', Unhandled_expression)], '9_020824', 'se_symbolically_interpret', 'symbolically_interpret', no_localisation, no_extra_info).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
implicit_type_casting(Same_type, Same_type, Le_symbolic, Ri_symbolic, Same_type, Le_symbolic, Ri_symbolic) :-   %Types are equal: no casting needed
    !.  %added a todo 18/10/2024 to check this rule
implicit_type_casting(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp) :-
    %mytrace,
    (float_conversion(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp) ->
        true
    ;
        (apply_integral_promotion(Le_type, Le_type_c),
         apply_integral_promotion(Ri_type, Ri_type_c),
         (Le_type_c == Ri_type_c ->     %both integral types are equal after promotion: no casting needed
            (Common_type = Le_type_c,
             Le_casted_exp = Le_symbolic,
             Ri_casted_exp = Ri_symbolic
            )
         ;
            integer_conversion(Le_type_c, Ri_type_c, Le_symbolic, Ri_symbolic, Common_type, Le_casted_exp, Ri_casted_exp)
         )
        )
    ).
    %%%
    %may need indexing, but order is important so be careful
    integer_conversion(unsigned(long_long), From_type, Le_symbolic, Ri_symbolic, unsigned(long_long), Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(long_long), From_type), Ri_symbolic, Ri_casted_exp).
    integer_conversion(From_type, unsigned(long_long), Le_symbolic, Ri_symbolic, unsigned(long_long), Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(long_long), From_type), Le_symbolic, Le_casted_exp).
    integer_conversion(long_long, From_type, Le_symbolic, Ri_symbolic, long_long, Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(long_long, From_type), Ri_symbolic, Ri_casted_exp).
    integer_conversion(From_type, long_long, Le_symbolic, Ri_symbolic, long_long, Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(long_long, From_type), Le_symbolic, Le_casted_exp).
    integer_conversion(unsigned(long), From_type, Le_symbolic, Ri_symbolic, unsigned(long), Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(long), From_type), Ri_symbolic, Ri_casted_exp).
    integer_conversion(From_type, unsigned(long), Le_symbolic, Ri_symbolic, unsigned(long), Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(long), From_type), Le_symbolic, Le_casted_exp).
    integer_conversion(long, From_type, Le_symbolic, Ri_symbolic, long, Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(long, From_type), Ri_symbolic, Ri_casted_exp).
    integer_conversion(From_type, long, Le_symbolic, Ri_symbolic, long, Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(long, From_type), Le_symbolic, Le_casted_exp).
    integer_conversion(unsigned(int), From_type, Le_symbolic, Ri_symbolic, unsigned(int), Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(int), From_type), Ri_symbolic, Ri_casted_exp).
    integer_conversion(From_type, unsigned(int), Le_symbolic, Ri_symbolic, unsigned(int), Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(unsigned(int), From_type), Le_symbolic, Le_casted_exp).
    integer_conversion(Le_type, Ri_type, Le_symbolic, Ri_symbolic, Le_type, Le_symbolic, Ri_symbolic) :-
        !,
        common_util__error(9, "Should not happen", "Cannot perform symbolic interpretation", [('Le_type', Le_type), ('Ri_type', Ri_type)], '9_040924_3', 'se_symbolically_interpret', 'integer_conversion', no_localisation, no_extra_info).
    %%%
    %may need indexing, but order is important so be careful
    float_conversion(long_double, From_type, Le_symbolic, Ri_symbolic, long_double, Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(long_double, From_type), Ri_symbolic, Ri_casted_exp).
    float_conversion(From_type, long_double, Le_symbolic, Ri_symbolic, long_double, Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(long_double, From_type), Le_symbolic, Le_casted_exp).
    float_conversion(double, From_type, Le_symbolic, Ri_symbolic, double, Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(double, From_type), Ri_symbolic, Ri_casted_exp).
    float_conversion(From_type, double, Le_symbolic, Ri_symbolic, double, Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(double, From_type), Le_symbolic, Le_casted_exp).
    float_conversion(float, From_type, Le_symbolic, Ri_symbolic, float, Le_symbolic, Ri_casted_exp) :-
        !,
        ptc_solver__perform_cast(cast(float, From_type), Ri_symbolic, Ri_casted_exp).
    float_conversion(From_type, float, Le_symbolic, Ri_symbolic, float, Le_casted_exp, Ri_symbolic) :-
        !,
        ptc_solver__perform_cast(cast(float, From_type), Le_symbolic, Le_casted_exp).
    float_conversion(_, _, _, _, _, _, _) :-
        fail.
%%%
    apply_integral_promotion(char, int) :-
        !.
    apply_integral_promotion(unsigned(char), int) :-
        !.
    apply_integral_promotion(short, int) :-
        !.
    apply_integral_promotion(unsigned(short), int) :-
        !.
    apply_integral_promotion(enum, int) :-
        !.
    apply_integral_promotion(Other_types_are_unchanged, Other_types_are_unchanged) :-   %in particular unsigned(int) remain unsigned(int)
        !.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
is_verifier_input_function('UC___VERIFIER_nondet_bool', bool).
is_verifier_input_function('UC___VERIFIER_nondet_char', char).
is_verifier_input_function('UC___VERIFIER_nondet_int', int).
is_verifier_input_function('UC___VERIFIER_nondet_int128', int128) :-  %128 bit integer, gcc extension
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_int128')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_float', float).
is_verifier_input_function('UC___VERIFIER_nondet_double', double).
is_verifier_input_function('UC___VERIFIER_nondet_loff_t', loff_t) :-  %large offset for file manipulation
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_loff_t')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_long', long).
is_verifier_input_function('UC___VERIFIER_nondet_longlong', long_long).
is_verifier_input_function('UC___VERIFIER_nondet_pchar', pointer(char)) :-
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_pchar')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_pthread_t', pointer(thread_t)) :-
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_pthread_t')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_sector_t', sector_t) :-
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_sector_t')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_short', short).
is_verifier_input_function('UC___VERIFIER_nondet_size_t', size_t) :-
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_size_t')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_u32', u32) :-
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_u32')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_uchar', unsigned(char)).
is_verifier_input_function('UC___VERIFIER_nondet_uint', unsigned(int)).
is_verifier_input_function('UC___VERIFIER_nondet_uint128', uint128) :-  %128 bit unsigned integer, gcc extension
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_uint128')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
is_verifier_input_function('UC___VERIFIER_nondet_ulong', unsigned(long)).
is_verifier_input_function('UC___VERIFIER_nondet_ulonglong', unsigned(long_long)).
is_verifier_input_function('UC___VERIFIER_nondet_unsigned', unsigned(int)).
is_verifier_input_function('UC___VERIFIER_nondet_ushort', unsigned(short)).
is_verifier_input_function('UC___VERIFIER_nondet_pointer', pointer) :-  %pointer to void
    common_util__error(10, "Unhandled function name in is_verifier_input_function", "Cannot perform symbolic interpretation", [('Function name', 'UC___VERIFIER_nondet_pointer')], '10_040924', 'se_symbolically_interpret', 'is_verifier_input_function', no_localisation, no_extra_info).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%