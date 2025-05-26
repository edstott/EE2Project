typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module getSurfaceNormal #(
    parameter int N = 32,     // Total bits
    parameter int FRAC = 8    // Fractional bits
)(
    input vec3 vec,
    output logic [N-1:0] length
);



endmodule;