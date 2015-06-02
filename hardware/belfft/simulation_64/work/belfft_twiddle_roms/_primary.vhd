library verilog;
use verilog.vl_types.all;
entity belfft_twiddle_roms is
    generic(
        word_width      : integer := 16;
        config_num      : integer := 1;
        max_awidth      : integer := 6;
        size            : integer := 256;
        awidth          : integer := 6;
        file_name       : string  := "bel_rom_twiddles.dat";
        size2           : integer := 256;
        awidth2         : integer := 6;
        file_name2      : string  := "bel_rom_twiddles2.dat";
        size3           : integer := 256;
        awidth3         : integer := 6;
        file_name3      : string  := "bel_rom_twiddles3.dat";
        size4           : integer := 256;
        awidth4         : integer := 6;
        file_name4      : string  := "bel_rom_twiddles4.dat"
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        adr_i           : in     vl_logic_vector;
        rd_i            : in     vl_logic;
        dat_o           : out    vl_logic_vector;
        cfg_sel_i       : in     vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_width : constant is 1;
    attribute mti_svvh_generic_type of config_num : constant is 1;
    attribute mti_svvh_generic_type of max_awidth : constant is 1;
    attribute mti_svvh_generic_type of size : constant is 1;
    attribute mti_svvh_generic_type of awidth : constant is 1;
    attribute mti_svvh_generic_type of file_name : constant is 1;
    attribute mti_svvh_generic_type of size2 : constant is 1;
    attribute mti_svvh_generic_type of awidth2 : constant is 1;
    attribute mti_svvh_generic_type of file_name2 : constant is 1;
    attribute mti_svvh_generic_type of size3 : constant is 1;
    attribute mti_svvh_generic_type of awidth3 : constant is 1;
    attribute mti_svvh_generic_type of file_name3 : constant is 1;
    attribute mti_svvh_generic_type of size4 : constant is 1;
    attribute mti_svvh_generic_type of awidth4 : constant is 1;
    attribute mti_svvh_generic_type of file_name4 : constant is 1;
end belfft_twiddle_roms;
