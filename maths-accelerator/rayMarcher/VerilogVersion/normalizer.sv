module vector_normalizer #(
    parameter WIDTH = 32,
    parameter FRAC_BITS = 24,
)(
    input logic clk,
    input logic rst,
    input logic valid,
    input logic [WIDTH-1:0]

);