`timescale 1ns / 1ps

module floor_register #(
    parameter NUM_FLOORS = 8
)(
    input  wire clk,
    input  wire rst,
    
    // Raw button inputs (1 bit per floor). 
    // In a real system, these would be OR'd from hall and car panels.
    input  wire [NUM_FLOORS-1:0] req_in,       
    
    // Signal from FSM indicating that the current floor is being serviced
    // and its request should be cleared.
    input  wire floor_serviced,                
    
    // Current floor index
    input  wire [$clog2(NUM_FLOORS)-1:0] current_floor,
    
    // Latched requests available to the system
    output reg  [NUM_FLOORS-1:0] pending_requests
);

    integer i;
    
    always @(posedge clk) begin
        if (rst) begin
            pending_requests <= {NUM_FLOORS{1'b0}};
        end else begin
            // 1. Latch new requests
            for (i = 0; i < NUM_FLOORS; i = i + 1) begin
                if (req_in[i]) begin
                    pending_requests[i] <= 1'b1;
                end
            end
            
            // 2. Clear request for the current floor if it is being serviced
            // Note: This overrides the latching if both happen simultaneously,
            // which is desired (clearing takes priority when doors are open).
            if (floor_serviced) begin
                pending_requests[current_floor] <= 1'b0;
            end
        end
    end

endmodule
