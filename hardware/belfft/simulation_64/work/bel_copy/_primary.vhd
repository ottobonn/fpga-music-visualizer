library verilog;
use verilog.vl_types.all;
entity bel_copy is
    generic(
        word_width      : integer := 16
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        adr_o           : out    vl_logic_vector(31 downto 0);
        dat_re_o        : out    vl_logic_vector;
        dat_re_i        : in     vl_logic_vector;
        dat_im_o        : out    vl_logic_vector;
        dat_im_i        : in     vl_logic_vector;
        wr_o            : out    vl_logic;
        rd_o            : out    vl_logic;
        ack_i           : in     vl_logic;
        err_i           : in     vl_logic;
        start           : in     vl_logic;
        finished        : out    vl_logic;
        finadr          : in     vl_logic_vector(31 downto 0);
        foutadr         : in     vl_logic_vector(31 downto 0);
        fstride         : in     vl_logic_vector(11 downto 0);
        n               : in     vl_logic_vector(11 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_width : constant is 1;
end bel_copy;
