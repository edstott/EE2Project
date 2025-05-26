module rayMarcher(
    input logic [95:0] ro,
    input logic [95:0] rd,
    output logic [31:0] distance
);
    parameter MAX_STEPS = 100;
    parameter MAX_DIST = 100;
    parameter SURFACE_DIST = 0.01;
    logic [31:0] rayDist;
    logic [31:0] dS;
    logic [95:0] stepVec;
    logic [95:0] position;
    
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
