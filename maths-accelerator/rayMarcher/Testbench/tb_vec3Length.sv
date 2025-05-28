module tb_vec3Length;

    parameter N = 32;
    parameter FRAC = 8;

    vec3 vec;
    logic [N-1:0] length;

    vec3Length #(
        .N(N),
        .FRAC(FRAC)
    ) uut (
        .vec(vec),
        .length(length)
    );

    function logic [31:0] to_fixed(real val);
        return $rtoi(val * (1 << FRAC));
    endfunction

    function real from_fixed(logic [31:0] val);
        return val / real'(1 << FRAC);
    endfunction

    initial begin
        vec.x = to_fixed(3.0);
        vec.y = to_fixed(4.0);
        vec.z = to_fixed(0.0);
        #1;
        $display("Input: (3,4,0) -> Length = %f", from_fixed(length)); // Expect 5.0

        vec.x = to_fixed(1.0);
        vec.y = to_fixed(2.0);
        vec.z = to_fixed(2.0);
        #1;
        $display("Input: (1,2,2) -> Length = %f", from_fixed(length)); // Expect ~3.0

         vec.x = to_fixed(20.0);
        vec.y = to_fixed(18.0);
        vec.z = to_fixed(3.0);
        #1;
        $display("Input: (20,18,3) -> Length = %f", from_fixed(length)); // Expect 

        vec.x = to_fixed(0.0);
        vec.y = to_fixed(0.0);
        vec.z = to_fixed(0.0);
        #1;
        $display("Input: (0,0,0) -> Length = %f", from_fixed(length)); // Expect 0.0

        $finish;
    end

endmodule
