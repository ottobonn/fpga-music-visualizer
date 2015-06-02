library verilog;
use verilog.vl_types.all;
entity belfft_twiddle_rom0 is
    port(
        clock           : in     vl_logic;
        clken           : in     vl_logic;
        address         : in     vl_logic_vector(5 downto 0);
        q               : out    vl_logic_vector(31 downto 0)
    );
end belfft_twiddle_rom0;
