`timescale 1ns / 1ps

module elevator_tb;

    parameter NUM_FLOORS = 8;
    parameter MOVE_DELAY = 5;
    parameter DOOR_OPEN_TIME = 5;

    reg clk;
    reg rst;
    reg emergency_stop;
    reg [NUM_FLOORS-1:0] hall_requests;
    reg [NUM_FLOORS-1:0] car_requests;

    wire [$clog2(NUM_FLOORS)-1:0] current_floor;
    wire [1:0] direction;
    wire door_open;
    wire door_closed;
    wire busy;
    wire [2:0] state;

    // Instantiate the Unit Under Test (UUT)
    elevator_controller #(
        .NUM_FLOORS(NUM_FLOORS),
        .MOVE_DELAY(MOVE_DELAY),
        .DOOR_OPEN_TIME(DOOR_OPEN_TIME)
    ) uut (
        .clk(clk),
        .rst(rst),
        .emergency_stop(emergency_stop),
        .hall_requests(hall_requests),
        .car_requests(car_requests),
        .current_floor(current_floor),
        .direction(direction),
        .door_open(door_open),
        .door_closed(door_closed),
        .busy(busy),
        .state(state)
    );

    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period -> 100MHz clock
    end

    // Test sequence
    initial begin
        $dumpfile("elevator_tb.vcd");
        $dumpvars(0, elevator_tb);
        
        // Initialize Inputs
        rst = 1;
        emergency_stop = 0;
        hall_requests = 0;
        car_requests = 0;

        // Wait 100 ns for global reset to finish
        #100;
        rst = 0;
        #20;
        
        // --- Test 1: Single request (Upward movement) ---
        $display("Time=%0t: Requesting Floor 3", $time);
        hall_requests[3] = 1;
        #10;
        hall_requests[3] = 0;
        
        wait(current_floor == 3 && door_open == 1);
        $display("Time=%0t: Reached Floor 3, doors opened", $time);
        wait(door_closed == 1);
        #50;
        
        // --- Test 2: Multiple requests (Downward movement) ---
        $display("Time=%0t: Requesting Floor 1 and Floor 0", $time);
        car_requests[1] = 1;
        hall_requests[0] = 1;
        #10;
        car_requests[1] = 0;
        hall_requests[0] = 0;
        
        wait(current_floor == 1 && door_open == 1);
        $display("Time=%0t: Reached Floor 1, doors opened", $time);
        wait(door_closed == 1);
        
        wait(current_floor == 0 && door_open == 1);
        $display("Time=%0t: Reached Floor 0, doors opened", $time);
        wait(door_closed == 1);
        #50;

        // --- Test 3: Emergency Stop handling ---
        $display("Time=%0t: Moving to Floor 7 and triggering Emergency Stop", $time);
        car_requests[7] = 1;
        #10;
        car_requests[7] = 0;
        
        wait(current_floor == 2); // Wait until it reaches floor 2
        #15;
        $display("Time=%0t: Triggering Emergency Stop!", $time);
        emergency_stop = 1;
        
        #100; // Hold emergency for 100ns
        $display("Time=%0t: Clearing Emergency Stop", $time);
        emergency_stop = 0;
        
        // The pending_requests should persist through emergency, 
        // so it should automatically resume moving to floor 7.
        wait(current_floor == 7 && door_open == 1);
        $display("Time=%0t: Reached Floor 7, doors opened", $time);
        wait(door_closed == 1);

        #100;
        $display("Simulation completed successfully.");
        $finish;
    end

endmodule
