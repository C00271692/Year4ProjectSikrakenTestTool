%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create the folder for TestComp format and the metadata file
print_preamble_testcomp(Install_dir, Source_dir, Target_source_file_name_no_ext) :-
    concat_atom([Install_dir, "/sikraken_output/", Target_source_file_name_no_ext], Result_folder),
    concat_atom([Result_folder, '/test-suite'], Test_suite_folder),
    (exists(Test_suite_folder) ->
        (concat_atom(['rm -rf ', Test_suite_folder], Delete_test_suite_folder_call),
         system(Delete_test_suite_folder_call)
        )
    ;
        true
    ),
    mkdir(Test_suite_folder),
    %mytrace,
    concat_atom([Result_folder, '/test-suite.zip'], Zip_filename),
    (exists(Zip_filename) ->
        (concat_string(["rm ", Zip_filename], Delete_zip_file_call),
         exec(Delete_zip_file_call, [])      %delete existing zip archive from a previous run if it exists [todo remove]?
        )
    ;
        true
    ),
    se_globals__set_val(testcomp_test_suite_folder, Test_suite_folder),
    cd(Test_suite_folder),  %the cwd is now '/sikraken_output/Target_source_file_name_no_ext/testsuite' all read and write commands are from now on 
    concat_atom([Source_dir, '/', Target_source_file_name_no_ext, '.c'], Target_C_file),    %todo could be a .i
    open('metadata.xml', 'write', 'metadata_stream'),
    printf('metadata_stream', "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n", []),
    printf('metadata_stream', "<!DOCTYPE test-metadata PUBLIC \"+//IDN sosy-lab.org//DTD test-format test-metadata 1.1//EN\" \"https://sosy-lab.org/test-format/test-metadata-1.1.dtd\">\n", []),
    printf('metadata_stream', "<test-metadata>\n", []),
    printf('metadata_stream', "\t<sourcecodelang>C</sourcecodelang>\n", []),
    printf('metadata_stream', "\t<producer>Sikraken</producer>\n", []),
    printf('metadata_stream', "\t<specification>CHECK( init(main()), FQL(cover EDGES(@DECISIONEDGE)) )</specification>\n", []),
    printf('metadata_stream', "\t<programfile>%w</programfile>\n", [Target_C_file]),
    get_hash(Install_dir, Target_C_file, Hash),
    printf('metadata_stream', "\t<programhash>%w</programhash>\n", [Hash]),
    printf('metadata_stream', "\t<entryfunction>main</entryfunction>\n", []),
    se_globals__get_val('data_model', Data_model),
    (Data_model = '-m32' ->
        Data_model_str = "32bit"
    ;
        Data_model_str = "64bit"
    ),
    printf('metadata_stream', "\t<architecture>%w</architecture>\n", [Data_model_str]),
    get_Date_time(Date_time),
    printf('metadata_stream', "\t<creationtime>%w</creationtime>\n", [Date_time]),
    printf('metadata_stream', "</test-metadata>", []),
    close('metadata_stream').
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_hash(Install_dir, Target_C_file, Hash) :-
        %mytrace,
        concat_atom([Install_dir, '/SymbolicExecutor/get_hash.sh ', Target_C_file], Hash_call),
        exec(Hash_call, [_, 'hash_stream', _]),
        read_string('hash_stream', end_of_line, "", _, Hash),
        close('hash_stream').
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    get_Date_time(Date_time) :-
        get_flag(unix_time, T), 
        local_time_string(T, "%c", Date_time).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%create a new test input vector in foo.xml file
print_test_inputs_testcomp(Labeled_inputs) :-
    se_globals__get_val('path_nb', Test_nb),
    concat_atom(['test_input-', Test_nb, '.xml'], Input_vector_filename),
    open(Input_vector_filename, 'write', 'test_input_stream'),
    printf('test_input_stream', "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"no\"?>\n", []),
    printf('test_input_stream', "<!DOCTYPE testcase PUBLIC \"+//IDN sosy-lab.org//DTD test-format testcase 1.1//EN\" \"https://sosy-lab.org/test-format/testcase-1.1.dtd\">\n", []),
    printf('test_input_stream', "<testcase>\n", []),
    %mytrace,
    print_inputs(Labeled_inputs),
    printf('test_input_stream', "</testcase>", []),
    close('test_input_stream').
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    print_inputs([]).
    print_inputs([Input|R]) :-
        printf('test_input_stream', "\t<input>%w</input>\n", [Input]),
        print_inputs(R).
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%