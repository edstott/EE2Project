`timescale 1ns / 1ps
module pixgen_tb;

    //Ready signal mode
    localparam ALWAYS_READY = 1;        //Ready signal is always true
    localparam RANDOM_READY = 2;        //Ready signal is true 50% of the time according to pseudo-random sequence
    localparam READY_AFTER_VALID = 3;   //Ready signal goes true after valid is true, then goes false
    
    parameter READY_MODE = RANDOM_READY;


    parameter TIMEOUT = 1000;           //Time to wait for valid to be true
    parameter X_SIZE = 480;             //X dimension of image in words (words = pixels * 3/4)
    parameter Y_SIZE = 480;             //Y dimension of image
    parameter ENDTIME = 10000000;       //End time of simulation
    parameter RND_SEED = 1246504138;    //Random seed for ready signal generation
    
    //Simulation configuration
    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,pixgen_tb);
        #ENDTIME $finish;
    end

    //Generate the clock input
    reg clk = 0;
    always #5 clk = !clk;

    //Generate the reset input
    reg rst = 0;
    initial #16 rst = 1;

    //Instantiate the pixel generator
    wire valid, sof, eol;
    pixel_generator p1 (
        .out_stream_aclk(clk),
        .s_axi_lite_aclk(clk),
        .axi_resetn(rst),
        .periph_resetn(rst),

        //Stream output
        .out_stream_tdata(),
        .out_stream_tkeep(),
        .out_stream_tlast(eol),
        .out_stream_tready(ready),
        .out_stream_tvalid(valid),
        .out_stream_tuser(sof), 

        //AXI-Lite S
        .s_axi_lite_araddr(8'h0),
        .s_axi_lite_arready(),
        .s_axi_lite_arvalid(1'b0),

        .s_axi_lite_awaddr(8'h0),
        .s_axi_lite_awready(),
        .s_axi_lite_awvalid(1'b0),

        .s_axi_lite_bready(1'b0),
        .s_axi_lite_bresp(),
        .s_axi_lite_bvalid(),

        .s_axi_lite_rdata(),
        .s_axi_lite_rready(1'b0),
        .s_axi_lite_rresp(),
        .s_axi_lite_rvalid(),

        .s_axi_lite_wdata(32'h0),
        .s_axi_lite_wready(),
        .s_axi_lite_wvalid(1'b0));


    //Ready signal generation
    reg [32:0] prbs = RND_SEED;
    reg ready = 1'b0;

    always @(posedge clk) begin
        prbs <= {prbs[31:0], prbs[32] ^ !prbs[19]};

        case (READY_MODE)
            ALWAYS_READY: begin
                ready <= 1'b1;
            end

            RANDOM_READY: begin
                ready <= prbs[32];
            end

            READY_AFTER_VALID: begin
                if (valid && ready) begin
                    ready <= 1'b0;
                end
                else if (valid) begin
                    ready <= 1'b1;
                end
                else begin
                    ready <= 1'b0;
                end
            end

        endcase

    end
    
    //Output word counting
    integer xCount = 0;
    integer yCount = 0;
    integer frameCount = 0;
    integer checkpoint = 0;

    always @(posedge clk) begin

        //Check for timeout waiting for valid
        if (valid) checkpoint = $time;
        if ($time > checkpoint + TIMEOUT) begin
            $display("Error: Timeout waiting for valid");
            checkpoint = $time;
        end

        if (valid && ready) begin
            
            //Check for Start of Frame (tuser in AXI Stream) on first word of each frame
            if (xCount == 0 && (yCount % Y_SIZE) == 0) begin
                if (sof) begin
                    $display("SOF Ok on frame %0d",frameCount);
                    yCount = 0;
                    frameCount = frameCount + 1;
                end
                else begin
                    $display("Error: Expected SOF but not received"); 
                end
            end
            else if (sof) begin
                $display("Error: Unexpected SOF received on word %0d of line %0d of frame %0d", xCount, yCount, frameCount);
                xCount = 0;
                yCount = 0;
                frameCount = frameCount + 1;
            end

            //Check for End of Line (tlast in AXI Stream) on last word of each line
            if (xCount == X_SIZE - 1) begin
                if (eol) begin
                    $display("EOL Ok on line %0d", yCount);
                    xCount = 0;
                    yCount = yCount + 1;
                end
                else begin
                    $display("Error: No EOL on word %0d of line %0d", X_SIZE - 1, yCount);
                    xCount = xCount + 1; 
                end
            end
            else if (eol) begin
                $display("Error: Unexpected EOL received on word %0d of line %0d", xCount, yCount);
                xCount = 0;
                yCount = yCount + 1;
            end
            else begin
                xCount = xCount + 1;
            end

        end
        

    end

endmodule