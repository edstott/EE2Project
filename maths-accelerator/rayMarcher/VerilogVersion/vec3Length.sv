typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module vec3Length #(
    parameter int N = 32,     // Total bits
    parameter int FRAC = 8    // Fractional bits
)(
    input vec3 vec,
    output logic [N-1:0] length
);

    logic [2*N-1:0] x2, y2, z2, sum_squares, x_scaled;
    logic [N-1:0] root;
    logic [2*N-1:0] rem;
    logic [N-1:0] test_div;

    integer i;

    always_comb begin
        x2 = vec.x * vec.x;
        y2 = vec.y * vec.y;
        z2 = vec.z * vec.z;
        sum_squares = x2 + y2 + z2;
        x_scaled = sum_squares;
        rem = 0;
        root = 0;

        for (i = N-1; i >= 0; i--) begin
            rem = (rem << 2) | ((x_scaled >> (2*i)) & 2'b11);
            test_div = (root << 1) + 1;

            if (rem >= test_div) begin
                rem = rem - test_div;
                root = (root << 1) + 1;
            end else begin
                root = root << 1;
            end
        end

        length = root;
    end
endmodule
