parsed([

global_variables([
declaration(int, [LC_x_0], [
assignment(LC_x_0 , 1)]) ], void),

function_definition(LC_inc, [void], [expression_statement(
add_assignment(LC_x_0 , 1)),return(LC_x_0)], int),
function_definition(LC_use_global_three_times, [
declaration(int, [LC_x_11], []) ], [return(
function_call(LC_inc, [])+
function_call(LC_inc, [])+
function_call(LC_inc, []))], int),

global_variables(999, 999)

]).