typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module vec3Length #(
    parameter int N = 32,     // Total bits
    parameter int FRAC = 24    // Fractional bits
)(
    input vec3 vec,
    output logic [N-1:0] length
);

    logic [2*N-1:0] x2, y2, z2, sum_squares, moduleOut;

    integer i;

    always_comb begin
        x2 = vec.x * vec.x;
        y2 = vec.y * vec.y;
        z2 = vec.z * vec.z;
        sum_squares = x2 + y2 + z2;
        inv_sqrt getSqrt(
            .clk(clk),
            .x_in(sum_squares),
            .inv_sqrt(moduleOut)
        )
        length = moduleOut * sum_squares;
    end
endmodule
