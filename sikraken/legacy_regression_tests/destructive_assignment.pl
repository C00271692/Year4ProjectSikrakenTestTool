parsed([
function_definition(LC_destructive_assignment, [
declaration(int, [LC_x_5], []),
declaration(int, [LC_y_5], []) ], [expression_statement(
assignment(LC_x_5 , LC_x_5+LC_y_5)),
if_statement(7, expression(LC_x_5>0), [return(1)], []),expression_statement(
assignment(LC_x_5 , LC_x_5+1)),
if_statement(11, expression(LC_x_5>=1), [return(LC_x_5)], []),return(42)], int),

global_variables(999, 999)

]).