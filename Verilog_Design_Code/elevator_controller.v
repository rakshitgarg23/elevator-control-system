`timescale 1ns / 1ps

module elevator_controller #(
    parameter NUM_FLOORS = 8,
    parameter MOVE_DELAY = 5,
    parameter DOOR_OPEN_TIME = 5
)(
    input  wire clk,
    input  wire rst,
    input  wire emergency_stop,
    input  wire [NUM_FLOORS-1:0] hall_requests,
    input  wire [NUM_FLOORS-1:0] car_requests,
    
    output wire [$clog2(NUM_FLOORS)-1:0] current_floor,
    output wire [1:0] direction,         // 0: IDLE, 1: UP, 2: DOWN
    output wire door_open,
    output wire door_closed,
    output wire busy,
    output wire [2:0] state
);

    // Combine hall and car requests. In a more complex system, these could be handled separately.
    wire [NUM_FLOORS-1:0] combined_req = hall_requests | car_requests;
    wire [NUM_FLOORS-1:0] pending_requests;
    wire floor_serviced;
    
    wire req_above;
    wire req_below;
    wire req_here;
    wire any_req;
    
    wire start_door_timer;
    wire door_timer_done;
    
    assign busy = any_req || (direction != 2'd0) || door_open;

    // --- Module Instantiations ---

    floor_register #(
        .NUM_FLOORS(NUM_FLOORS)
    ) u_floor_reg (
        .clk(clk),
        .rst(rst),
        .req_in(combined_req),
        .floor_serviced(floor_serviced),
        .current_floor(current_floor),
        .pending_requests(pending_requests)
    );

    request_manager #(
        .NUM_FLOORS(NUM_FLOORS)
    ) u_req_mgr (
        .pending_requests(pending_requests),
        .current_floor(current_floor),
        .req_above(req_above),
        .req_below(req_below),
        .req_here(req_here),
        .any_req(any_req)
    );

    door_controller #(
        .DOOR_OPEN_TIME(DOOR_OPEN_TIME)
    ) u_door_ctrl (
        .clk(clk),
        .rst(rst),
        .start_timer(start_door_timer),
        .door_is_open(door_open),
        .door_is_closed(door_closed),
        .timer_done(door_timer_done)
    );

    movement_controller #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_DELAY(MOVE_DELAY)
    ) u_movement_ctrl (
        .clk(clk),
        .rst(rst),
        .emergency(emergency_stop),
        .req_above(req_above),
        .req_below(req_below),
        .req_here(req_here),
        .any_req(any_req),
        .door_timer_done(door_timer_done),
        .start_door_timer(start_door_timer),
        .current_floor(current_floor),
        .current_direction(direction),
        .floor_serviced(floor_serviced),
        .current_state(state)
    );

endmodule
