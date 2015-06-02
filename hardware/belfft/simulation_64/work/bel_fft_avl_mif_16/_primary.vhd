library verilog;
use verilog.vl_types.all;
entity bel_fft_avl_mif_16 is
    generic(
        word_width      : integer := 16
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        address         : out    vl_logic_vector(31 downto 0);
        readdata        : in     vl_logic_vector(31 downto 0);
        writedata       : out    vl_logic_vector(31 downto 0);
        read            : out    vl_logic;
        write           : out    vl_logic;
        waitrequest     : in     vl_logic;
        readdatavalid   : in     vl_logic;
        adr0_i          : in     vl_logic_vector(31 downto 0);
        dat_re0_i       : in     vl_logic_vector;
        dat_re0_o       : out    vl_logic_vector;
        dat_im0_i       : in     vl_logic_vector;
        dat_im0_o       : out    vl_logic_vector;
        wr0_i           : in     vl_logic;
        rd0_i           : in     vl_logic;
        ack0_o          : out    vl_logic;
        err0_o          : out    vl_logic;
        adr1_i          : in     vl_logic_vector(31 downto 0);
        dat_re1_i       : in     vl_logic_vector;
        dat_re1_o       : out    vl_logic_vector;
        dat_im1_i       : in     vl_logic_vector;
        dat_im1_o       : out    vl_logic_vector;
        wr1_i           : in     vl_logic;
        rd1_i           : in     vl_logic;
        ack1_o          : out    vl_logic;
        err1_o          : out    vl_logic;
        adr2_i          : in     vl_logic_vector(31 downto 0);
        dat_re2_i       : in     vl_logic_vector;
        dat_re2_o       : out    vl_logic_vector;
        dat_im2_i       : in     vl_logic_vector;
        dat_im2_o       : out    vl_logic_vector;
        wr2_i           : in     vl_logic;
        rd2_i           : in     vl_logic;
        ack2_o          : out    vl_logic;
        err2_o          : out    vl_logic;
        adr3_i          : in     vl_logic_vector(31 downto 0);
        dat_re3_i       : in     vl_logic_vector;
        dat_re3_o       : out    vl_logic_vector;
        dat_im3_i       : in     vl_logic_vector;
        dat_im3_o       : out    vl_logic_vector;
        wr3_i           : in     vl_logic;
        rd3_i           : in     vl_logic;
        ack3_o          : out    vl_logic;
        err3_o          : out    vl_logic;
        user_i          : in     vl_logic_vector(31 downto 0)
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_width : constant is 1;
end bel_fft_avl_mif_16;
