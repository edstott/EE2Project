`timescale 1ns / 1ps
module pixgen_tb;

    parameter ALWAYS_READY = 1;
    parameter READY_AWAIT_VALID = 1;
    parameter TIMEOUT = 1000;
    parameter X_SIZE = 480;
    parameter Y_SIZE = 480;
    parameter ENDTIME = 10000;

    reg clk = 0;
    always #5 clk = !clk;
    reg rst = 0;
    initial #16 rst = 1;

    reg ready = ALWAYS_READY;
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

    integer xCount = 0;
    integer yCount = 0;
    integer checkpoint = 0;

    initial begin
        $dumpfile("test.vcd");
        $dumpvars(0,pixgen_tb);

        #15;
        while (1) begin
            checkpoint = $time;
            while (!valid) begin
                #10;
                if ($time > checkpoint + TIMEOUT) $error("Timeout waiting for valid");
            end

            if (xCount == 0 && yCount == 0) begin
                if (sof) $display("SOF OK");
                else $error("No sof(tuser) on first word of line"); 
            end

            if (xCount == X_SIZE - 1) begin
                if (eol) $display("EOL Ok");
                else $error("No eol(tlast on last word of line)"); 
            end

            xCount = (xCount + 1) % X_SIZE;
            if (xCount == 0) yCount = yCount + 1 % Y_SIZE;

            if ($time > ENDTIME) $finish;
            
            #10;
        end


    end

endmodule