module invsqrt_bram #(
    parameter ADDR_LENGTH = 12;
              DATA_WIDTH = 32;
)(

    input logic [ADDR_LENGTH-1:0] in_addr,
    input logic                   en,
    output logic [DATA_WIDTH-1:0] out_sqrtinv;
)

    logic [DATA_WIDTH-1:0] data_out;
    
    //LUT Memory that maps input S to output 1/sqrt(S)
    (* ram_style = "block" *) 
    logic [DATA_WIDTH-1:0] lut_rom [0:(1<<ADDR_LENGTH)-1];

    initial begin
     $readmemh("lut_init.mem", lut_rom);
    end

    // then in your logic: creates a an additional one clock memory to read from the BRAM
    always_ff @(posedge clk) begin
        if (en)
            data_out <= lut_mem[in_addr];
    end

    assign out_sqrtinv = data_out;

endmodule
