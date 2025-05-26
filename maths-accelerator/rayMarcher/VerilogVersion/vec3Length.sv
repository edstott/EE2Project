typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module vec3Length #(
  parameter int N = 16,     // total input bits
  parameter int FRAC = 8    // fractional bits
)(
    input vec3 vec,
    output logic [31:0] length
    );
    
    logic [2*N-1:0] x_scaled;         // Need extra width for precision
    logic [N-1:0] sqrt_result;
    logic [N-1:0] square;

    integer i;
    logic [2*N-1:0] rem;
    logic [N-1:0] root, test_div;

    always_comb begin
        square = (vec.x * vec.x) + (vec.y * vec.y) + (vec.z * vec.z);




        x_scaled = x_in << FRAC;       // Shift left to account for fractional bits
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
    end

endmodule;
