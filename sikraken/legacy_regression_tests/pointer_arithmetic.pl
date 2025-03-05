parsed([
function_definition(LC_pointer_arithmetic, [void], [
declaration(int, [LC_five_3], [
assignment(LC_five_3 , 5)]),
declaration(intpointer , [LC_five_pointer_3], [
assignment(LC_five_pointer_3 , address_of(LC_five_3))]),expression_statement(
post_increment((dereference(LC_five_pointer_3)) , (dereference(LC_five_pointer_3))+1)),expression_statement(
add_assignment(dereference(LC_five_pointer_3) , 2)),return(dereference(LC_five_pointer_3))], int),

global_variables(999, 999)

]).