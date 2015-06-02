library verilog;
use verilog.vl_types.all;
entity bel_cdiv4 is
    generic(
        word_width      : integer := 16
    );
    port(
        a_re_i          : in     vl_logic_vector;
        a_im_i          : in     vl_logic_vector;
        x_re_o          : out    vl_logic_vector;
        x_im_o          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_width : constant is 1;
end bel_cdiv4;
