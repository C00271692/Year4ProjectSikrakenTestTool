parsed([

global_variables([
declaration(int, [LC_y_0], [
assignment(LC_y_0 , 5)]) ], void),

function_definition(LC_check_global, [void], [return(LC_y_0)], int),
function_definition(LC_abc, [
declaration(int, [LC_x_80], []),
declaration(int, [LC_y_80], []) ], [expression_statement(
assignment(LC_x_80 , LC_x_80+LC_y_80)),
if_statement(82, expression(LC_x_80>0), [return(1)], []),expression_statement(
assignment(LC_x_80 , LC_x_80+1)),
if_statement(86, expression(LC_x_80>=1), [return(LC_x_80)], []),return(42)], int),
function_definition(LC_check_password, [
declaration(intpointer , [LC_buf_103], []) ], [
if_statement(104, expression(andop(andop(andop(andop(LC_buf_103[0]==15 , LC_buf_103[1]==1) , LC_buf_103[2]==99) , LC_buf_103[3]==(-5)) , LC_buf_103[4]==0)), [return(1)], []),return(0)], int),

global_variables(999, 999)

]).