`include "common_defs.sv"

typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
} vec2;

module getSurfaceNormal #(
    parameter logic [31:0] eps = 0.001; 
)(
    input vec3 p,
    output vec3 normalVector
);





endmodule;