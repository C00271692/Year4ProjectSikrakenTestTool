parsed([
function_definition(LC_fib, [
declaration(int, [LC_n_4], []) ], [
if_statement(5, expression(LC_n_4<=1), [return(LC_n_4)], []),return(
function_call(LC_fib, [LC_n_4-1])+
function_call(LC_fib, [LC_n_4-2]))], int),
function_definition(LC_fib_helper, [
declaration(int, [LC_x_9], []) ], [
if_statement(10, expression(LC_x_9==9), [return(
function_call(LC_fib, [5])+
function_call(LC_fib, [7]))], []),return(0)], int),

global_variables(999, 999)

]).