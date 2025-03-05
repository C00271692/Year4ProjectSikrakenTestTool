parsed([
function_definition(LC_counter, [void], [
declaration(static_int, [LC_x_4], [
assignment(LC_x_4 , 0)]),expression_statement(
post_increment(LC_x_4 , LC_x_4+1)),return(LC_x_4)], int),
function_definition(LC_static_persist_value, [void], [return(
function_call(LC_counter, [])+
function_call(LC_counter, [])+
function_call(LC_counter, []))], int),

global_variables(999, 999)

]).