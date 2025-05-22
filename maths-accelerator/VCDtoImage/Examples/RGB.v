/** @file
    Generate an RGB test pattern.
*/

`ifndef RGB_PATTERN_V_
`define RGB_PATTERN_V_

/** RGB Pattern Generator
    @param[in] clk clock input
    @param[in] rst reset
    @param[in] enable pattern generation enable
    @param[out] pixel_rgb 24-bit RGB output
*/
module rgb_pattern(
    input clk,
    input rst,
    input enable,
    output reg [23:0] pixel_rgb
);

reg [7:0] counter_r, counter_g, counter_b;

always @(posedge clk) begin
    if (rst) begin
        counter_r <= 0;
        counter_g <= 85;
        counter_b <= 170;
        pixel_rgb <= 0;
    end else if (enable) begin
        counter_r <= counter_r + 1;
        counter_g <= counter_g + 2;
        counter_b <= counter_b + 3;

        pixel_rgb <= {counter_r, counter_g, counter_b};
    end
end

endmodule


/** RGB Pattern Generator Testbench */
module rgb_pattern_tb;

parameter tck = 10; ///< Clock period

reg clk, rst, enable;
wire [23:0] pixel_rgb;

/** Device under test */
rgb_pattern dut(
    .clk(clk),
    .rst(rst),
    .enable(enable),
    .pixel_rgb(pixel_rgb)
);

always #(tck/2) clk = ~clk; // Clock toggle

initial begin
    $dumpfile("rgb_pattern.vcd");
    $dumpvars(0, rgb_pattern_tb);
end

initial begin
    clk = 0;
    rst = 1;
    enable = 0;
    #(tck * 5);

    rst = 0;
    enable = 1;

    // Let the simulation run long enough to create a full image frame
    #(tck * 640 * 480);  // ~1 frame at 1 pixel per cycle
    $finish;
end

endmodule

`endif // RGB_PATTERN_V_