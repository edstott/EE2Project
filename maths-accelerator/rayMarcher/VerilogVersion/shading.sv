module shading #(
    parameter DATA_WIDTH = 32,
              OUT_WIDTH = 24
)(  
    //all Q8.24
    input  logic signed [DATA_WIDTH-1:0] nx,
    input  logic signed [DATA_WIDTH-1:0] ny,
    input  logic signed [DATA_WIDTH-1:0] nz,
    input  logic signed [DATA_WIDTH-1:0] lx,
    input  logic signed [DATA_WIDTH-1:0] ly,
    input  logic signed [DATA_WIDTH-1:0] lz,
    output logic [OUT_WIDTH-1:0]       shade_out

);

    logic signed [(2*DATA_WIDTH)-1:0] dot_nl;
    logic [DATA_WIDTH-1:0] diffuse;
    logic [DATA_WIDTH-1:0] amb_comp;
    logic [DATA_WIDTH-1:0] ambient,dot_reduced;

    //Q8.24 intermediate shade
    logic [DATA_WIDTH-1:0] shade_r, shade_g, shade_b;
    logic[7:0] r_out,g_out,b_out;

    //I will change these values later?
    logic  [DATA_WIDTH-1:0] amb_r_fixed, amb_g_fixed, amb_b_fixed;  
    logic [DATA_WIDTH-1:0] diff_r_fixed, diff_g_fixed, diff_b_fixed;

    localparam logic [DATA_WIDTH-1:0] HALF = 32'h00800000;

    //all Q0.15 
    localparam logic  [15:0] AMB_R = 16'd6553;   // 0.2 * 32768
    localparam logic  [15:0] AMB_G = 16'd9830;   // 0.3 * 32768
    localparam logic  [15:0] AMB_B = 16'd13107;  // 0.4 * 32768
    //for diffuse same Q0.15
    localparam logic [15:0] DIFF_R = 16'd26214; // 0.8 * 32768
    localparam logic [15:0] DIFF_G = 16'd22937; // 0.7 * 32768
    localparam logic [15:0] DIFF_B = 16'd16384; // 0.5 * 32768


    function automatic logic [7:0] clamp_to_8bit(input signed [DATA_WIDTH-1:0] val);
        logic [31:0] scaled_val;
        begin
            
            if (val < 0)
                clamp_to_8bit = 8'd0;
                
            else if (val > (1 << 24)) 
            // Clamp to 1.0 in Q8.24
                clamp_to_8bit = 8'd255;
            else begin
            // Take upper 8 bits after Q8.24 shift
                scaled_val = val * 255;
                clamp_to_8bit = scaled_val[31:24]; 

            end
        end
    endfunction
    

    always_comb begin
        
        //have to reduce after fixed point multiplication
        dot_nl = (nx * lx + ny * ly + nz * lz) ; 
        dot_reduced = dot_nl >>> 24;

        diffuse = (dot_nl < 0) ? 0 : dot_reduced ;


        amb_comp = (ny > 0) ? ny : 0;
        //Q8.24
        ambient = HALF + ((HALF * amb_comp) >> 24);

        amb_r_fixed = (ambient * AMB_R) >> 15;
        amb_g_fixed = (ambient * AMB_G) >> 15;
        amb_b_fixed = (ambient * AMB_B) >> 15;

        diff_r_fixed = (diffuse * DIFF_R) >> 15;
        diff_g_fixed = (diffuse * DIFF_G) >> 15;
        diff_b_fixed = (diffuse * DIFF_B) >> 15;

        shade_r = amb_r_fixed + diff_r_fixed;
        shade_g = amb_g_fixed + diff_g_fixed;
        shade_b = amb_b_fixed + diff_b_fixed;

        r_out = clamp_to_8bit(shade_r);
        g_out = clamp_to_8bit(shade_g);
        b_out = clamp_to_8bit(shade_b);

        shade_out = {r_out, g_out, b_out};
    end

endmodule


        
        
        