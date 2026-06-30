`timescale 1ns / 1ps

module door_controller #(
    parameter DOOR_OPEN_TIME = 5 // Number of clock cycles the door stays open
)(
    input  wire clk,
    input  wire rst,
    input  wire start_timer,   // Signal from FSM to start the door open timer
    output wire door_is_open,  // High when the door is open
    output wire door_is_closed,// High when the door is closed
    output wire timer_done     // Pulse when the timer finishes
);

    reg [$clog2(DOOR_OPEN_TIME+1)-1:0] timer;
    reg active;

    assign door_is_open   = active;
    assign door_is_closed = !active;
    assign timer_done     = (active && (timer == DOOR_OPEN_TIME));

    always @(posedge clk) begin
        if (rst) begin
            timer <= 0;
            active <= 1'b0;
        end else begin
            // Start the timer when requested
            if (start_timer && !active) begin
                active <= 1'b1;
                timer <= 0;
            end 
            // If active, increment the timer
            else if (active) begin
                if (timer < DOOR_OPEN_TIME) begin
                    timer <= timer + 1;
                end else begin
                    // Timer finished, close the door
                    active <= 1'b0;
                end
            end
        end
    end

endmodule
