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

    input vec3 camera_forward,
    input fp tan_half_fov, // tan(fov / 2)
    // should be taking aspect ratio as an input? Compute width/height (make division module)
    
    output vec3 ray_direction,
    output logic valid
);

// calculating camera up and right vectors internally using tan approximations

localparam fp FP_ONE = 32'h01000000;
localparam fp FP_TWO = 32'h02000000;
localparam fp INV_HALF_WIDTH = 32'h00051EB8;  // 1/320
localparam fp INV_HALF_HEIGHT = 32'h006AAAAB; // 1/240 precomputed recipricol for now
localparam fp ASPECT_RATIO_640_480 = 32'h01555555;

vec3 camera_right, camera_up;
logic valid_r1, valid_r2, valid_r3;
vec3 ray;
fp ray_mag_sq, inv_ray_mag;
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

// 2: FOV and aspect ratio to calculate camera up and camera right

always_ff @(posedge clk) begin
    if(!rst) begin
        camera_x <= 0;
        camera_y <= 0;
        valid_r2 <= 0;
    end else begin
        camera_x <= fp_mul(fp_mul(ndc_x, ASPECT_RATIO_640_480), tan_half_fov);
        camera_y <= fp_mul(ndc_y, tan_half_fov);
        valid_r2 <= valid_r1;
    end
end

// ray direction

vec3 ray_unscaled;
fp ray_len_sq, ray_inv_len;

always_ff @(posedge clk) begin
    if(!rst) begin
        ray <= `{default:0};
        valid_r3 <= 0;
    end else begin
        ray.x <= camera_x;
        ray.y <= camera_y;
        ray.z <= -FP_ONE;
        valid_r3 <= valid_r2;
    end
end

// have to transform to world space if we are rotating camera (can skip if camera fixed)
vec3 world_ray;
always_comb begin
    if(camera_forward.x == 0 && camera_forward == 0 && camera_forward.z == -FP_ONE) begin
        world_ray = ray;
    end
    else begin
        // TODO:
        // do transformation from local ray to world 
    end
end

// normalization
always_comb begin
    ray_mag_sq = vec3_dot(world_ray, world_ray);
end

inv_sqrt invsq_ray(
    .clk(clk),
    .x(ray_mag_sq),
    .inv_sqrt(inv_ray_mag)
);

always_comb begin
    ray_direction.x = fp_mul(world_ray.x, inv_ray_mag);
    ray_direction.y = fp_mul(world_ray.y, inv_ray_mag);
    ray_direction.z = fp_mul(world_ray.z, inv_ray_mag);
    valid = valid_r3;
end
    

endmodule
