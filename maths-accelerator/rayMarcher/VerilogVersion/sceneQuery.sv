typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module sceneQuery(
    input vec3 pos,
    output logic [31:0] closestDistance
);

    // logic [95:0] boxFrameDimensions = (1.0f, 1.0f, 1.0f); //TODO CHANGE THESE
    // logic [31:0] barThickness = 0.1f;
    // sdfBoxFrame getDistance (
    //     .p(pos),
    //     .dimensions(boxFrameDimensions),
    //     .thickness(barThickness),
    //     .outputDistance(closestDistance)
    // );

    logic [31:0] s = 0.1f; //TODO: CHANGE INTO BITS
    sdfSphere getDistance (
        .p(pos),
        .radius(s),
        .outputDistance(closestDistance)
    );

endmodule;
