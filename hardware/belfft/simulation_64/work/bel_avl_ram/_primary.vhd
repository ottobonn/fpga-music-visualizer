library verilog;
use verilog.vl_types.all;
entity bel_avl_ram is
    generic(
        size            : integer := 64;
        adr_width       : integer := 6;
        input_file_name : string  := "bel_avl_ram_in.dat";
        output_file_name: string  := "bel_avl_ram_out.dat";
        log_file_name   : string  := "bel_wb_ram.log"
    );
    port(
        clk_i           : in     vl_logic;
        rst_i           : in     vl_logic;
        address         : in     vl_logic_vector;
        readdata        : out    vl_logic_vector(31 downto 0);
        writedata       : in     vl_logic_vector(31 downto 0);
        read            : in     vl_logic;
        write           : in     vl_logic;
        readdatavalid   : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of size : constant is 1;
    attribute mti_svvh_generic_type of adr_width : constant is 1;
    attribute mti_svvh_generic_type of input_file_name : constant is 1;
    attribute mti_svvh_generic_type of output_file_name : constant is 1;
    attribute mti_svvh_generic_type of log_file_name : constant is 1;
end bel_avl_ram;
