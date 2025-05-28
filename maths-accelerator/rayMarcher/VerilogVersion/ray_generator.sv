import vector_pkg::*;
`include "common_defs.svh";

module ray_generator #(
    parameter SCREEN_WIDTH = `SCREEN_WIDTH,
    parameter SCREEN_HEIGHT = `SCREEN_HEIGHT
)(
    input logic clk,
    input logic rst,
    input fp screen_x,  
    input fp screen_y,
    input logic coords_valid,
    input fp aspect_ratio, //// have to use division to compute this, can compute internally or pass as input
    input vec3 camera_forward,
    
    output vec3 ray_direction,
    output logic valid
);

// calculating camera up and right vectors internally
// right [0,1,0] and up calculated using cross product
// EDGECASE: Approach doesn't work if camera pointing directly up or down (cross product is zero)




localparam fp FP_ONE = 32'h01000000;
localparam fp FP_TWO = 32'h02000000;
localparam fp INV_HALF_WIDTH = 32'h00051EB8;  // 1/320
localparam fp INV_HALF_HEIGHT = 32'h006AAAAB; // 1/240 precomputed recipricol for now


vec3 camera_right, camera_up;
logic valid_r1, valid_r2, valid_r3;

// global fp variables
fp ndc_x, ndc_y;
fp pixel_x_fp, pixel_y_fp;

// 1: normalizing pixel coords to [-1,1]
always_ff @(posedge clk) begin
    if (!rst) begin
        valid_r1 <= 0;
    end else begin
        pixel_x_fp <= screen_x << `FRAC_BITS;
        pixel_y_fp <= screen_y << `FRAC_BITS;

        ndc_x <= fp_mul(pixel_x_fp, INV_HALF_WIDTH) - FP_ONE;
        ndc_y <= FP_ONE - fp_mul(pixel_y_fp, INV_HALF_HEIGHT);
        valid_r1 <= coords_valid;
    end
end

// so far we have normalised pixel coordinates, Set up inputs/outputs and fixed-point constants
// 2: FOV and aspect ratio to calculate camera up and camera right
vec3 world_up = '{0, FP_ONE, 0};

vec3 right_unscaled, up_unscaled;
fp right_len_sq, up_len_sq;
fp right_inv_len, up_inv_len;

always_ff @(posedge clk) 
    begin
        if (!rst) begin
            camera_right <= '{0,0,0};
            camera_up    <= '{0,0,0};
            valid_r2     <= 0;
    end else if (valid_r1) 
	    begin
            right_unscaled = cross(camera_forward, world_up);
            up_unscaled    = cross(right_unscaled, camera_forward);
    
            right_len_sq = vec3_dot(right_unscaled, right_unscaled);
            up_len_sq    = vec3_dot(up_unscaled, up_unscaled);
    
            right_inv_len = inv_sqrt(right_len_sq);
            up_inv_len    = inv_sqrt(up_len_sq);
    
            camera_right <= vec3_scale(right_unscaled, right_inv_len);
            camera_up    <= vec3_scale(up_unscaled, up_inv_len);
    
            valid_r2 <= 1;
        end
end

// last part; compute ray direction
vec3 ray_unscaled;
fp ray_len_sq, ray_inv_len;

always_ff @(posedge clk) 
    begin
        if (!rst) begin
            ray_direction <= '{0, 0, 0};
            valid         <= 0;
    end else if (valid_r2) 
        begin
            vec3 x_term = vec3_scale(camera_right, fp_mul(ndc_x, aspect_ratio));
            vec3 y_term = vec3_scale(camera_up, ndc_y);
            ray_unscaled = vec3_add(vec3_add(x_term, y_term), camera_forward);
    
            ray_len_sq  = vec3_dot(ray_unscaled, ray_unscaled);
            ray_inv_len = inv_sqrt(ray_len_sq);
            ray_direction <= vec3_scale(ray_unscaled, ray_inv_len);
    
            valid <= 1;
        end
end

endmodule
