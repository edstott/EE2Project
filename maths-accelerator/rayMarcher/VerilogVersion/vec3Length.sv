import vector_pkg::*;
`include "common_defs.sv"

module vec3Length #(
    parameter int N = 32,     // Total bits
    parameter int FRAC_BITS = 24    // Fractional bits
)(
    input logic clk,
    input vec3 vec,
    output logic [`WORD_WIDTH-1:0] length
);

    logic [N-1:0] x2, y2, z2, sum_squares, moduleOut; //Sum_squares 32 bits?

    always_comb begin
        x2 = fp_mul(vec.x, vec.x);
        y2 = fp_mul(vec.y, vec.y);
        z2 = fp_mul(vec.z, vec.z);
        sum_squares = fp_add3(x2, y2, z2);
        inv_sqrt getSqrt(
            .clk(clk),
            .x(sum_squares),
            .inv_sqrt(moduleOut)
        )
        length = fp_mul(moduleOut, sum_squares);
    end
endmodule
