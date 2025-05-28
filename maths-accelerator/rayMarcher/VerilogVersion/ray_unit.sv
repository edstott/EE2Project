import vector_pkg::*;
`include "common_defs.svh";

module ray_unit #(
)(
    input logic clk,
    input logic rst_gen,
    input fp screen_x,  
    input fp screen_y,
    input logic coords_valid,
    input vec3 camera_forward,
    input vec3 ray_origin,
    output fp distance,
    output vec3 surface_point,  
    output logic valid
);

    logic raygen_valid;
    vec3 ray_direction;

ray_generator ray_gen (
    .clk(clk),
    .rst(rst_gen),
    .screen_x(x),
    .screen_y(y),
    .coords_valid(valid_coor),
    .camera_forward(camera_forward),
    .ray_direction(ray_direction),
    .valid(raygen_valid)
);

rayMarcher ray_marcher(
    .ro(ray_origin),
    .rd(ray_direction),
    .distance(distance),
    .point(surface_point),
    .valid (valid)
);

endmodule