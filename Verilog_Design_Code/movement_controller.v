`timescale 1ns / 1ps

module movement_controller #(
    parameter NUM_FLOORS = 8,
    parameter MOVE_DELAY = 5 // Clock cycles between floors
)(
    input  wire clk,
    input  wire rst,
    input  wire emergency,
    
    // Requests
    input  wire req_above,
    input  wire req_below,
    input  wire req_here,
    input  wire any_req,
    
    // Door Controller interface
    input  wire door_timer_done,
    output reg  start_door_timer,
    
    // Outputs
    output reg [$clog2(NUM_FLOORS)-1:0] current_floor,
    output reg [1:0] current_direction, // 0: IDLE, 1: UP, 2: DOWN
    output reg floor_serviced,          // Pulse to clear request
    output wire [2:0] current_state     // For debugging/viewing
);

    localparam STATE_IDLE       = 3'd0;
    localparam STATE_MOVE_UP    = 3'd1;
    localparam STATE_MOVE_DOWN  = 3'd2;
    localparam STATE_DOOR_OPEN  = 3'd3;
    localparam STATE_DOOR_CLOSE = 3'd4;
    localparam STATE_EMERGENCY  = 3'd5;
    
    localparam DIR_IDLE = 2'd0;
    localparam DIR_UP   = 2'd1;
    localparam DIR_DOWN = 2'd2;

    reg [2:0] state;
    assign current_state = state;
    
    reg [$clog2(MOVE_DELAY+1)-1:0] move_timer;
    
    always @(posedge clk) begin
        if (rst) begin
            state <= STATE_IDLE;
            current_floor <= 0;
            current_direction <= DIR_IDLE;
            start_door_timer <= 1'b0;
            floor_serviced <= 1'b0;
            move_timer <= 0;
        end else if (emergency) begin
            // Immediately stop, transition to emergency state.
            state <= STATE_EMERGENCY;
            current_direction <= DIR_IDLE;
            start_door_timer <= 1'b0;
            floor_serviced <= 1'b0;
            move_timer <= 0;
        end else begin
            // Default de-asserts
            start_door_timer <= 1'b0;
            floor_serviced <= 1'b0;
            
            case (state)
                STATE_IDLE: begin
                    move_timer <= 0;
                    if (req_here) begin
                        state <= STATE_DOOR_OPEN;
                        start_door_timer <= 1'b1;
                        floor_serviced <= 1'b1;
                    end else if (req_above) begin
                        state <= STATE_MOVE_UP;
                        current_direction <= DIR_UP;
                    end else if (req_below) begin
                        state <= STATE_MOVE_DOWN;
                        current_direction <= DIR_DOWN;
                    end else begin
                        current_direction <= DIR_IDLE;
                    end
                end
                
                STATE_MOVE_UP: begin
                    if (req_here) begin
                        // Found a request at current floor while moving
                        state <= STATE_DOOR_OPEN;
                        start_door_timer <= 1'b1;
                        floor_serviced <= 1'b1;
                    end else if (move_timer < MOVE_DELAY) begin
                        move_timer <= move_timer + 1;
                    end else begin
                        // Move up one floor
                        if (current_floor < NUM_FLOORS - 1) begin
                            current_floor <= current_floor + 1;
                        end
                        move_timer <= 0;
                        
                        // Note: Next cycle it will check req_here for the new floor.
                        // If no requests above, we could switch direction, but that 
                        // is handled by returning to IDLE if no req_above.
                        if (!req_above && !req_here) begin
                            // Actually wait for next cycle to evaluate req_here safely
                            // But if there are strictly no requests above, we can re-evaluate
                        end
                    end
                    
                    // Stop moving up if no requests above AND no request here
                    if (!req_above && !req_here && move_timer == 0) begin
                         // state <= STATE_IDLE; 
                         // It's safer to let the next cycle handle it.
                    end
                    // Better logic: if there are no requests above and no request here, go IDLE.
                    if (!req_above && !req_here) begin
                         state <= STATE_IDLE;
                    end
                end
                
                STATE_MOVE_DOWN: begin
                    if (req_here) begin
                        state <= STATE_DOOR_OPEN;
                        start_door_timer <= 1'b1;
                        floor_serviced <= 1'b1;
                    end else if (move_timer < MOVE_DELAY) begin
                        move_timer <= move_timer + 1;
                    end else begin
                        if (current_floor > 0) begin
                            current_floor <= current_floor - 1;
                        end
                        move_timer <= 0;
                    end
                    
                    if (!req_below && !req_here) begin
                         state <= STATE_IDLE;
                    end
                end
                
                STATE_DOOR_OPEN: begin
                    // Wait for the door timer to finish
                    if (door_timer_done) begin
                        state <= STATE_DOOR_CLOSE;
                    end
                end
                
                STATE_DOOR_CLOSE: begin
                    // Door is closing. In a real system, there's a sensor.
                    // Here, we take 1 clock cycle to close, then go IDLE to re-evaluate.
                    state <= STATE_IDLE;
                end
                
                STATE_EMERGENCY: begin
                    // Remain in emergency until reset clears it.
                    // The system could also have an emergency_clear signal, but reset is fine.
                    if (!emergency) begin
                        // If emergency clears, optionally return to IDLE
                        state <= STATE_IDLE;
                    end
                end
                
                default: state <= STATE_IDLE;
            endcase
        end
    end

endmodule
