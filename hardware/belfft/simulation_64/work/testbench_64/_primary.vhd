library verilog;
use verilog.vl_types.all;
entity testbench_64 is
    generic(
        input_file_name : string  := "input_data_64.dat";
        fft_size        : integer := 64;
        inverse         : integer := 0;
        word_width      : integer := 16;
        ram_awidth      : integer := 6
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of input_file_name : constant is 1;
    attribute mti_svvh_generic_type of fft_size : constant is 1;
    attribute mti_svvh_generic_type of inverse : constant is 1;
    attribute mti_svvh_generic_type of word_width : constant is 1;
    attribute mti_svvh_generic_type of ram_awidth : constant is 1;
end testbench_64;
