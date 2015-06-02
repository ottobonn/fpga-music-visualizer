library verilog;
use verilog.vl_types.all;
entity bel_fft_avl is
    generic(
        word_width      : integer := 16;
        config_num      : integer := 1;
        stage_num       : integer := 4;
        twiddle_rom_max_awidth: integer := 8;
        fft_size        : integer := 256;
        fft_size1       : integer := 256;
        fft_size2       : integer := 256;
        fft_size3       : integer := 256;
        has_butterfly2  : integer := 1
    );
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
        tw_adr          : out    vl_logic_vector;
        tw_rd           : out    vl_logic;
        tw_re           : in     vl_logic_vector;
        tw_im           : in     vl_logic_vector;
        tw_cfg_sel      : out    vl_logic_vector;
        int_o           : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of word_width : constant is 1;
    attribute mti_svvh_generic_type of config_num : constant is 1;
    attribute mti_svvh_generic_type of stage_num : constant is 1;
    attribute mti_svvh_generic_type of twiddle_rom_max_awidth : constant is 1;
    attribute mti_svvh_generic_type of fft_size : constant is 1;
    attribute mti_svvh_generic_type of fft_size1 : constant is 1;
    attribute mti_svvh_generic_type of fft_size2 : constant is 1;
    attribute mti_svvh_generic_type of fft_size3 : constant is 1;
    attribute mti_svvh_generic_type of has_butterfly2 : constant is 1;
end bel_fft_avl;
