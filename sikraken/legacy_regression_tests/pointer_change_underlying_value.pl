parsed([
function_definition(LC_pointer_change_underlying_value, [void], [
declaration(int, [LC_five_4], [
assignment(LC_five_4 , 5)]),
declaration(int, [LC_ten_4], [
assignment(LC_ten_4 , 10)]),
declaration(intpointer , [LC_five_pointer_4], [
assignment(LC_five_pointer_4 , address_of(LC_five_4))]),
declaration(intpointer , [LC_ten_pointer_4], [
assignment(LC_ten_pointer_4 , address_of(LC_ten_4))]),
declaration(int, [LC_temp_4], [
assignment(LC_temp_4 , dereference(LC_five_pointer_4))]),expression_statement(
assignment(dereference(LC_five_pointer_4) , dereference(LC_ten_pointer_4))),expression_statement(
assignment(dereference(LC_ten_pointer_4) , LC_temp_4)),return(LC_five_4)], int),

global_variables(999, 999)

]).