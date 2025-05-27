import common_defs::*;
import vector_pkg::*;

module ray_generator #(
    parameter SCREEN_WIDTH = `SCREEN_WIDTH,
    parameter SCREEN_HEIGHT = `SCREEN_HEIGHT
)(
    input logic clk,
    input logic rst,
    input fp screen_x,  
    input fp screen_y,
    input logic coords_valid;
    input fp aspect_ratio, // have to use division to compute this, can compute internally or pass as input
    input vec3 camera_forward,
    
    output vec3 ray_direction,
    output logic valid
);

// calculating camera up and right vectors internally
// right [0,1,0] and up calculated using cross product
// EDGECASE: Approach doesn't work if camera pointing directly up or down (cross product is zero)

localparam fp FP_ONE = 32'h01000000;
localparam fp FP_TWO = 32'h02000000;
localparam fp INV_HALF_WIDTH = 32'h00051EB8; // 1/320
localparam fp INV_HALF_HEIGHT = 32'h006AAAAB; // 1/240 precomputed recipricol for now

vec3 camera_right, camera_up;
logic valid_r1, valid_r2, valid_r3;

// 1: normalizing pixel coords to [-1,1]
always_ff @(posedge clk) begin
    if(!rst) begin
        camera_right <= 0;
        camera_up <= 0;
        valid_r3 <=0;
    end else begin
        fp pixel_x_fp, pixel_y_fp;
        pixel_x_fp <= screen_x << `FRAC_BITS;
        pixel_y_fp <= screen_y << `FRAC_BITS;

        // NDC to [-1,1] (2*pixel res) - 1
        ndc_x <= fp_mul(pixel_x_fp, INV_HALF_WIDTH) - FP_ONE;
        ndc_y <= FP_ONE- fp_mul(pixel_y_fp, INV_HALF_HEIGHT);
        valid_r1 <= coords_valid;
    end
end

// 2: FOV and aspect ratio to calculate camera up and camera right


        


endmodule




