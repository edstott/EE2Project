import vector_pkg::*;
`include "common_defs.svh";

module rayMarcher #(
    int MAX_STEPS = 100,
    parameter MAX_DIST = 32'h64000000, //100 decimal
    parameter SURFACE_DIST = 32'h00028f5c //0.01 in decimal
)(
    input logic clk,
    input logic start, //signal to start new raymarch process
    input vec3 rayOrigin,
    input vec3 rayDir,
    output fp distance,
    output vec3 point,
    output logic done //signal to send to higher module that raymarch process is done
);

    fp rayDist, dS;
    vec3 stepVec, position;
    int stepCounter;

    typedef enum {IDLE, STEP, DONE} state;
    state currentState, nextState;

    sceneQuery getClosestDist (
        .clk(clk),
        .pos(position),
        .closestDistance(dS)
    );

    initial begin
        currentState = IDLE;
    end

    always_ff @(posedge clk or posedge start) begin //asynchronous
        if (start) begin
            currentState <= IDLE;
            rayDist <= '0;
            stepCounter <= 0;
            done <= 1'b0;
            point <= '0;
        end else begin
            currentState <= nextState;
            if (currentState == IDLE) begin
                rayDist <= 0;
                stepCounter <= 0;
                done <= 1'b0;
                point <= '0;
            end
            else if (currentState == STEP) begin
                rayDist <= fp_add(rayDist, dS); 
                stepCount <= stepCount + 1;
            end
            else if (currentState == DONE) begin
                done <= 1'b1;
            end
        end
    end

     always_comb begin
        case (currentState)
            IDLE: nextState = STEP;
            STEP: begin
                stepVec = vec3_scale(rayDir, rayDist);
                position = vec3_add(rayOrigin, stepVec);
                if (rayDist > MAX_DIST || dS < SURFACE_DIST || stepCount >= MAX_STEPS)
                    nextState = DONE;
                else nextState = STEP;
            end
            DONE: nextState = DONE;
        endcase
    end

    assign distance = rayDist;
    assign point = position;

endmodule
