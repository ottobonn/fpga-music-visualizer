library verilog;
use verilog.vl_types.all;
entity bel_fft_avl_sif is
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        address         : in     vl_logic_vector(9 downto 0);
        readdata        : out    vl_logic_vector(31 downto 0);
        writedata       : in     vl_logic_vector(31 downto 0);
        read            : in     vl_logic;
        write           : in     vl_logic;
        byteenable      : in     vl_logic_vector(3 downto 0);
        waitrequest     : out    vl_logic;
        readdatavalid   : out    vl_logic;
        adr_o           : out    vl_logic_vector(9 downto 0);
        dat_i           : in     vl_logic_vector(31 downto 0);
        dat_o           : out    vl_logic_vector(31 downto 0);
        bsel_o          : out    vl_logic_vector(3 downto 0);
        wr_o            : out    vl_logic;
        rd_o            : out    vl_logic;
        ack_i           : in     vl_logic;
        err_i           : in     vl_logic
    );
end bel_fft_avl_sif;
