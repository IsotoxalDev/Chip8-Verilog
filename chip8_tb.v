`timescale 1ns/1ps

module test;

    reg clk;
    wire uart_tx;

    // Instantiate the DUT (Device Under Test)
    chip8 uut (
        .clk(clk),
        .uart_tx(uart_tx)
    );

    // Clock generation: 50 MHz (20 ns period)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // Test procedure
    initial begin
        // Optional: display UART TX changes
        $monitor("Time = %0t | uart_tx = %b", $time, uart_tx);

        // Optional: dump waveform
        $dumpfile("chip8_tb.vcd");
        $dumpvars(0, test);

        // Allow some time for initialization
        #1000;

        // Wait for some frames to simulate
        #10000000;

        // End simulation
        $display("Test complete.");
        $finish;
    end

endmodule
