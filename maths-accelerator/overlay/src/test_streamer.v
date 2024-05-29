
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.05.2024 22:03:08
// Design Name: 
// Module Name: test_block_v
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module test_streamer(
input           out_stream_aclk,
input           s_axi_lite_aclk,
input           axi_resetn,
input           periph_resetn,

//Stream output
output [31:0]   out_stream_tdata,
output [3:0]    out_stream_tkeep,
output          out_stream_tlast,
input           out_stream_tready,
output          out_stream_tvalid,
output [0:0]    out_stream_tuser, 

//AXI-Lite S
input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_araddr,
output          s_axi_lite_arready,
input           s_axi_lite_arvalid,

input [AXI_LITE_ADDR_WIDTH-1:0]     s_axi_lite_awaddr,
output          s_axi_lite_awready,
input           s_axi_lite_awvalid,

input           s_axi_lite_bready,
output [1:0]    s_axi_lite_bresp,
output          s_axi_lite_bvalid,

output [31:0]   s_axi_lite_rdata,
input           s_axi_lite_rready,
output [1:0]    s_axi_lite_rresp,
output          s_axi_lite_rvalid,

input  [31:0]   s_axi_lite_wdata,
output          s_axi_lite_wready,
input           s_axi_lite_wvalid

);

localparam X_SIZE = 640;
localparam Y_SIZE = 480;
localparam REG_FILE_SIZE = 8;
parameter AXI_LITE_ADDR_WIDTH = 8;

localparam AWAIT_WADD = 2'b00;
localparam AWAIT_RESP = 2'b01;
localparam AWAIT_WRITE = 2'b10;
localparam AWAIT_WRITE_AND_RESP = 2'b11;

localparam AWAIT_RADD = 2'b00;
localparam AWAIT_FETCH = 2'b01;
localparam AWAIT_READ = 2'b10;

localparam AXI_OK = 2'b00;
localparam AXI_ERR = 2'b10;

reg [31:0]                          regfile [REG_FILE_SIZE-1:0];
reg [AXI_LITE_ADDR_WIDTH-1:0]       writeAddr = AWAIT_WADD;
reg [AXI_LITE_ADDR_WIDTH-1:0]       readAddr = AWAIT_RADD;
reg [31:0]                          readData;
reg [1:0]                           readState, writeState;


//Read from the register file
always @(posedge s_axi_lite_aclk) begin
    
    readData <= regfile[readAddr];

    if (axi_resetn) begin
    readState <= AWAIT_RADD;
    end

    else case (readState)

        AWAIT_RADD: begin
            if (s_axi_lite_arvalid) begin
                readAddr <= s_axi_lite_araddr;
                readState <= AWAIT_FETCH;
            end
        end

        AWAIT_FETCH: begin
            readState <= AWAIT_READ;
        end

        AWAIT_READ: begin
            if (s_axi_lite_rready) begin
                readState <= AWAIT_RADD;
            end
        end

        default: begin
            readState <= AWAIT_RADD;
        end

    endcase
end

assign s_axi_lite_arready = (readState == AWAIT_RADD);
assign s_axi_lite_rresp = (readAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;
assign s_axi_lite_rvalid = (readState == AWAIT_READ);
assign s_axi_lite_rdata = readData;

//Write to the register file, use a state machine to track address write, data write and response read events
always @(posedge s_axi_lite_aclk) begin

    if (axi_resetn) begin
        writeState <= AWAIT_WADD;
    end

    else case (writeState)

        AWAIT_WADD: begin  //Idle, awaiting a write address
            if (s_axi_lite_awvalid) begin
                writeAddr <= s_axi_lite_awaddr;
                writeState <= AWAIT_WRITE_AND_RESP;
            end          
        end

        AWAIT_WRITE_AND_RESP: begin //Received address, waiting for write and response
            case ({s_axi_lite_wvalid, s_axi_lite_bready})
                2'b10: begin
                    regfile[writeAddr] <= s_axi_lite_wdata;
                    writeState <= AWAIT_RESP;
                end
                2'b01: begin
                    writeState <= AWAIT_WRITE;
                end
                2'b11: begin
                    regfile[writeAddr] <= s_axi_lite_wdata;
                    writeState <= AWAIT_WADD;
                end
                default: begin
                    writeState <= writeState;
                end
            endcase
        end

        AWAIT_RESP: begin   //Write complete, awaiting response transmission
            if (s_axi_lite_bready) begin
                writeState <= AWAIT_WADD;
            end
        end

        AWAIT_WRITE: begin  //Response sent, awaiting write
            if (s_axi_lite_wvalid) begin
                    regfile[writeAddr] <= s_axi_lite_wdata;
                    writeState <= AWAIT_WADD;
            end
        end

        default: begin
            writeState <= AWAIT_WADD;
        end
    endcase
end

assign s_axi_lite_awready = (writeState == AWAIT_WADD);
assign s_axi_lite_wready = (writeState == AWAIT_WRITE || writeState == AWAIT_WRITE_AND_RESP);
assign s_axi_lite_bvalid = (writeState == AWAIT_RESP || writeState == AWAIT_WRITE_AND_RESP);
assign s_axi_lite_bresp = (writeAddr < REG_FILE_SIZE) ? AXI_OK : AXI_ERR;



reg [9:0] x;
reg [8:0] y;

wire first = (x == 0) & (y==0);
wire lastx = (x == X_SIZE - 1);
wire lasty = (y == Y_SIZE - 1);

always @(posedge out_stream_aclk) begin
    if (periph_resetn) begin
        if (ready) begin
            if (lastx) begin
                x <= 9'd0;
                if (lasty) begin
                    y <= 9'd0;
                end
                else begin
                    y <= y + 9'd1;
                end
            end
            else x <= x + 9'd1;
        end
    end
    else begin
        x <= 0;
        y <= 0;
    end
end

wire valid_int = 1'b1;

wire [7:0] r, g, b;
assign r = x[7:0];
assign g = y[7:0];
assign b = x[6:0]+y[6:0];

packer pixel_packer(    .aclk(out_stream_aclk),
                        .aresetn(periph_resetn),
                        .r(r), .g(g), .b(b),
                        .eol(lastx), .in_stream_ready(ready), .valid(valid_int), .sof(first),
                        .out_stream_tdata(out_stream_tdata), .out_stream_tkeep(out_stream_tkeep),
                        .out_stream_tlast(out_stream_tlast), .out_stream_tready(out_stream_tready),
                        .out_stream_tvalid(out_stream_tvalid), .out_stream_tuser(out_stream_tuser) );

 
endmodule
