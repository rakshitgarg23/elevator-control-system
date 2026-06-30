`timescale 1ns / 1ps

module request_manager #(
    parameter NUM_FLOORS = 8
)(
    input  wire [NUM_FLOORS-1:0] pending_requests,
    input  wire [$clog2(NUM_FLOORS)-1:0] current_floor,
    
    output reg  req_above,
    output reg  req_below,
    output wire req_here,
    output wire any_req
);

    assign req_here = pending_requests[current_floor];
    assign any_req  = (pending_requests != {NUM_FLOORS{1'b0}});

    integer i;
    
    always @(*) begin
        req_above = 1'b0;
        // Check all floors above the current floor
        for (i = 0; i < NUM_FLOORS; i = i + 1) begin
            if (i > current_floor && pending_requests[i]) begin
                req_above = 1'b1;
            end
        end
        
        req_below = 1'b0;
        // Check all floors below the current floor
        for (i = 0; i < NUM_FLOORS; i = i + 1) begin
            if (i < current_floor && pending_requests[i]) begin
                req_below = 1'b1;
            end
        end
    end

endmodule
