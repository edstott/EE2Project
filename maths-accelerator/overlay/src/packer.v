module packer(

input           aclk,
input           aresetn,

input [7:0]     r,g,b,
input           eol,
output          in_stream_ready,
input           valid,
input           sof, 

output [31:0]   out_stream_tdata,
output [3:0]    out_stream_tkeep,
output          out_stream_tlast,
input           out_stream_tready,
output          out_stream_tvalid,
output [0:0]    out_stream_tuser );


reg [1:0]       state_reg = 2'b0;

//Act instantly in state 0 if input pixel is start of frame
wire [1:0]      state = sof ? 2'b00 : state_reg;
wire            state0 = (state == 2'b0);

reg             sof_reg;
reg [7:0]       last_r, last_g, last_b;

//Combinational
reg [31:0]      tdata;
reg             tvalid;
reg             ready;


always @(posedge aclk)begin
    if(aresetn) begin
        //Advance state if valid and...
        if (valid) begin
            //...if in state 0 or destination is ready
            if (state0 | out_stream_tready) begin
                //Always return to state zero at end of line
                if (eol) begin
                    state_reg <= 2'b0;
                end
                else begin
                    state_reg <= state + 2'b1;
                end
            end

            // Store the sof flag when it is set (it can't be read in this cycle because output data isn't ready)
            if (sof) begin
                sof_reg <= 1'b1;
            end
            // Reset it after it has been read
            else if (valid & out_stream_tready) begin
                sof_reg <= 1'b0;
            end

            //Latch colour inputs whenever they are valid
            last_r <= r;
            last_g <= g;
            last_b <= b;

        end
    end
    else begin
        state_reg <= 2'b0;
        sof_reg <= 1'b0;
    end
end


always @* begin
    case ({state})
        2'b00 : 
            begin 
                //Output is not complete (valid) in this state, that means we are always ready for the next pixel.
                tdata = {g, last_r, last_b, last_g}; //don't care since valid is false - just copy another state 
                tvalid = 1'b0;
                ready = 1'b1;
            end
        2'b01 :
            begin 
                tdata = {g, last_r, last_b, last_g};
                tvalid = valid;
                ready = out_stream_tready;
            end
        2'b10 : 
            begin 
                tdata = {b, g, last_r, last_b};
                tvalid = valid;
                ready = out_stream_tready;
            end
        2'b11 : 
            begin 
                tdata = {r, b, g, last_r};
                tvalid = valid;
                ready = out_stream_tready;
            end
        default : 
            begin 
                //Output is not complete (valid) in this state, that means we are always ready for the next pixel.
                tdata = {g, last_r, last_b, last_g}; //don't care since valid is false - just copy another state 
                tvalid = 1'b0;
                ready = 1'b1;
            end
    endcase
end

assign in_stream_ready = ready;
assign out_stream_tlast = eol; //Assuming that end of line is never in state zero
assign out_stream_tuser = sof_reg;
assign out_stream_tkeep = 4'hf; //Assuming that line contains a multiple of 4 bytes.
assign out_stream_tdata = tdata;
assign out_stream_tvalid = tvalid;

endmodule