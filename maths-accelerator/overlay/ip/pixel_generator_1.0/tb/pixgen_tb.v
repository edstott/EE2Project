`timescale 1ns / 1ps
module pixgen_tb;

parameter REG_COUNT = 8;

reg clk = 0;
reg rst = 0;
always #5 clk = !clk;

wire [31:0] dataOut;
wire [3:0] keep;
wire last, valid, user;

reg [7:0] writeAdd = 0;
reg [31:0] writeData = 0;
reg writeAddValid = 0, writeValid = 0;
wire writeAddReady, writeReady;

reg [7:0] readAdd = 0;
wire readAddReady;
reg readAddValid = 0;

wire [31:0] readData;
reg readReady = 0;
wire [1:0] readResp;
wire readValid;

reg respReady = 0;
wire [1:0] respData;
wire respValid;

pixel_generator p1 (
  .out_stream_aclk(clk),
  .s_axi_lite_aclk(clk),
  .axi_resetn(rst),
  .periph_resetn(rst),

//Stream output
  .out_stream_tdata(dataOut),
  .out_stream_tkeep(keep),
  .out_stream_tlast(last),
  .out_stream_tready(1'b1),
  .out_stream_tvalid(valid),
  .out_stream_tuser(user), 

//AXI-Lite S
  .s_axi_lite_araddr(readAdd),
  .s_axi_lite_arready(readAddReady),
  .s_axi_lite_arvalid(readAddValid),

  .s_axi_lite_awaddr(writeAdd),
  .s_axi_lite_awready(writeAddReady),
  .s_axi_lite_awvalid(writeAddValid),

  .s_axi_lite_bready(respReady),
  .s_axi_lite_bresp(respData),
  .s_axi_lite_bvalid(respValid),

  .s_axi_lite_rdata(readData),
  .s_axi_lite_rready(readReady),
  .s_axi_lite_rresp(readResp),
  .s_axi_lite_rvalid(readValid),

  .s_axi_lite_wdata(writeData),
  .s_axi_lite_wready(writeReady),
  .s_axi_lite_wvalid(writeValid));

integer i = 0;
  initial begin
    $dumpfile("test.vcd");
    $dumpvars(0,pixgen_tb);
    #16 rst = 1;


    for (i=0; i<REG_COUNT; i = i +1) begin
    #40 writeAdd = i*4;
      writeData = i*32'h11111111;
    #20 writeAddValid = 1;
    #10 writeAddValid = 0;
    #20 writeValid = 1;
    #10 writeValid = 0;
    #20 respReady = 1;
    #10 respReady = 0;
    end

    for (i=0; i<REG_COUNT; i = i +1) begin
    #40 readAdd = i*4;
    #20 readAddValid = 1;
    #10 readAddValid = 0;
    #20 readReady = 1;
    #10 readReady = 0;
    $display(readData);
    end

    #100 $finish;
  end

endmodule