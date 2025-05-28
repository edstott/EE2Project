import vector_pkg::*;
`include "common_defs.sv"

module sceneQuery(
    input logic clk,
    input vec3 p,
    input fp radius,
    output fp outputDistance
);
    fp vectorLength; //Allocate lots of bits
    vec3Length calcLength(
        clk(clk),
        vec3(p),
        length(vectorLength)
    );
    assign outputDistance = vectorLength - radius;

endmodule;
