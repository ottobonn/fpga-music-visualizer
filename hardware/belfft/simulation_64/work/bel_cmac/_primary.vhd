library verilog;
use verilog.vl_types.all;
entity bel_cmac is
    port(
        a_re_i          : in     vl_logic_vector(15 downto 0);
        a_im_i          : in     vl_logic_vector(15 downto 0);
        b_re_i          : in     vl_logic_vector(15 downto 0);
        b_im_i          : in     vl_logic_vector(15 downto 0);
        c_re_i          : in     vl_logic_vector(15 downto 0);
        c_im_i          : in     vl_logic_vector(15 downto 0);
        x_re_o          : out    vl_logic_vector(15 downto 0);
        x_im_o          : out    vl_logic_vector(15 downto 0)
    );
end bel_cmac;
