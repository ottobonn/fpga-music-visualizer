

// x = a + b * c

module bel_cmac (a_re_i, a_im_i, b_re_i, b_im_i, c_re_i, c_im_i, x_re_o, x_im_o);

    input signed [15:0] a_re_i;
    input signed [15:0] a_im_i;
    input signed [15:0] b_re_i;
    input signed [15:0] b_im_i;
    input signed [15:0] c_re_i;
    input signed [15:0] c_im_i;
    output signed [15:0] x_re_o;
    output signed [15:0] x_im_o;

    wire signed [31:0]   scratch0;
    wire signed [31:0]   scratch1;
    wire signed [31:0]   scratch2;
    wire signed [31:0]   scratch3;

    assign 	  scratch0 = b_re_i * c_re_i;
    assign 	  scratch1 = b_re_i * c_im_i;
    assign 	  scratch2 = b_im_i * c_re_i;
    assign 	  scratch3 = b_im_i * c_im_i;

    // assign        scratch4 = scratch0 - scratch3;
    // assign        scratch5 = scratch1 + scratch2;
    assign 	  x_re_o = (scratch0 - scratch3  + a_re_i * 32768 + 16384) / 32768;
    assign 	  x_im_o = (scratch1 + scratch2  + a_im_i * 32768 + 16384) / 32768;

    // assign x_re_o = ((a_re_i * b_re_i - a_im_i * b_im_i) + ( 1 << 14)) >> 15;
    // assign x_im_o = ((a_re_i * b_im_i + a_im_i * b_im_i) + ( 1 << 14)) >> 15;
    
endmodule // bel_cmac

