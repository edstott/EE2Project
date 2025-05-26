module sceneQuery(
    input logic [95:0] pos,
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
