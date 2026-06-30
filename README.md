# Elevator Controller System (Verilog HDL)

A professional, parameterized Verilog HDL project implementing an 8-floor elevator controller. Designed with modularity in mind, this project demonstrates real-world RTL design concepts including Finite State Machines (FSM), request prioritization, timer delays, and synchronous reset handling.

## 🌟 Features
- **Parameterized Architecture:** Easily scale the number of floors (`NUM_FLOORS = 8` by default).
- **Bidirectional Request Management:** Handles simultaneous requests from both inside the elevator and hall.
- **Smart Elevator Algorithm:** Completes all requests in the current direction before reversing.
- **Configurable Door Timing:** Wait states for opening and closing doors.
- **Emergency Stop:** Safely halts operations while preserving pending requests.

## 📂 Project Structure
- `Verilog_Design_Code/` - Contains the core Verilog modules (FSM, door controller, request manager).
- `Testbench_Code/` - Contains the self-checking testbench (`elevator_tb.v`).
- `run_sim.bat` - One-click script to compile and run the simulation on Windows.

## 🚀 How to Run & Simulate (GTKWave)

Make sure you have [Icarus Verilog](http://iverilog.icarus.com/) and GTKWave installed.

**Option 1: Using the provided script (Windows)**
Simply double-click the `run_sim.bat` file. It will compile the code, run the simulation, and automatically open GTKWave to show you the waveforms!

**Option 2: Manual Commands**
1. Compile the design:
   ```bash
   iverilog -o elevator.vvp Verilog_Design_Code/*.v Testbench_Code/elevator_tb.v
   ```
2. Run the simulation:
   ```bash
   vvp elevator.vvp
   ```
3. View the waveforms:
   ```bash
   gtkwave elevator_tb.vcd
   ```
