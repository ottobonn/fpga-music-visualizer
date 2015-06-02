library verilog;
use verilog.vl_types.all;
entity belfft is
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        m_address       : out    vl_logic_vector(31 downto 0);
        m_readdata      : in     vl_logic_vector(31 downto 0);
        m_writedata     : out    vl_logic_vector(31 downto 0);
        m_read          : out    vl_logic;
        m_write         : out    vl_logic;
        m_waitrequest   : in     vl_logic;
        m_readdatavalid : in     vl_logic;
        s_address       : in     vl_logic_vector(9 downto 0);
        s_readdata      : out    vl_logic_vector(31 downto 0);
        s_writedata     : in     vl_logic_vector(31 downto 0);
        s_read          : in     vl_logic;
        s_write         : in     vl_logic;
        s_byteenable    : in     vl_logic_vector(3 downto 0);
        s_waitrequest   : out    vl_logic;
        s_readdatavalid : out    vl_logic;
        int_o           : out    vl_logic
    );
end belfft;
