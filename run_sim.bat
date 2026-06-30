@echo off
echo Compiling Verilog files...
iverilog -o elevator.vvp Verilog_Design_Code/*.v Testbench_Code/elevator_tb.v
if %errorlevel% neq 0 (
    echo Compilation failed!
    pause
    exit /b %errorlevel%
)

echo Running Simulation...
vvp elevator.vvp
if %errorlevel% neq 0 (
    echo Simulation failed!
    pause
    exit /b %errorlevel%
)

echo Opening GTKWave...
start gtkwave elevator_tb.vcd
exit
