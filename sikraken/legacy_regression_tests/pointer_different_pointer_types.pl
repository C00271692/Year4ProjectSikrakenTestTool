parsed([
function_definition(LC_pointer_different_pointer_types, [void], [
declaration(char, [LC_letter_a_3], [
assignment(LC_letter_a_3 , 97)]),
declaration(intpointer , [LC_int_pointer_3], [
assignment(LC_int_pointer_3 , address_of(LC_letter_a_3))]),
declaration(charpointerpointer , [LC_char_pointer_3], [
assignment(LC_char_pointer_3 , address_of(LC_int_pointer_3))]),return(dereference(dereference(LC_char_pointer_3)))], char),

global_variables(999, 999)

]).