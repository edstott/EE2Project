typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module sceneQuery(
    input vec3 p,
    input logic [31:0] radius,
    output logic [31:0] outputDistance
);
    parameter [31:0] vectorLength; //Allocate lots of bits
    vec3Length calcLength(
        vec3(p),
        length(vectorLength)
    );
    assign outputDistance = vectorLength - radius;

endmodule;
