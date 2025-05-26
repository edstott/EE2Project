typedef struct packed {
    logic [31:0] x;
    logic [31:0] y;
    logic [31:0] z;
} vec3;

module rayMarcher(
    input vec3 ro,
    input vec3 rd,
    output logic [31:0] distance
);
    parameter MAX_STEPS = 100;
    parameter MAX_DIST = 100;
    parameter SURFACE_DIST = 0.01;
    logic [31:0] rayDist;
    logic [31:0] dS;
    vec3 stepVec;
    vec3 position;
    
    initial begin
        rayDist = 0.0;
    end
    
    always_comb begin
        for (i = 0; i < MAX_STEPS; i++) begin : rayMarching
            scalarMul calcDistance (
                .vec3(rd),
                .scalar(rayDist),
                .vec3_res(stepVec)
            );
            addVec3 addDistance (
                .vec3_a(ro),
                .vec3_b(stepVec),
                .vec3_res(position)
            );
            sceneQuery getClosestDist (
                .pos(position),
                .closestDistance(dS)
            );
            rayDist += dS;
            if(rayDist > MAX_DIST || dS < SURFACE_DIST) break;
            end 
        distance = rayDist;                         
    end

endmodule;
