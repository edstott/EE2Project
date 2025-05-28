import vector_pkg::*;
`include "common_defs.sv"

module sceneQuery(
    input logic clk,
    input vec3 pos,
    output fp closestDistance
);

    // logic [95:0] boxFrameDimensions = (1.0f, 1.0f, 1.0f); //TODO CHANGE THESE
    // logic [31:0] barThickness = 0.1f;
    // sdfBoxFrame getDistance (
    //     .p(pos),
    //     .dimensions(boxFrameDimensions),
    //     .thickness(barThickness),
    //     .outputDistance(closestDistance)
    // );

    fp s = 32'h0019999a; //s = 0.1
    sdfSphere getDistance (
        .clk(clk),
        .p(pos),
        .radius(s),
        .outputDistance(closestDistance)
    );

endmodule;
