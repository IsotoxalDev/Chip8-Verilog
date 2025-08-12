`timescale 1ps/1ps

module test;
    reg clk;
    reg set;
    wire uart_tx;
    reg [63:0] screen [31:0];
    reg [2047:0] screen_flat;
    integer i, j;

    always @(*) begin
        for (i = 0; i < 32; i = i + 1) begin
            screen_flat[i*64 +: 64] = screen[i];
        end
    end

    Display uut (
        .clk(clk),
        .uart_tx(uart_tx),
        .screen_flat(screen_flat),
        .set(set)
    );

    always #5 clk = ~clk;

    initial begin
        clk = 0;
        set = 0;
        
        for (i = 0; i < 32; i = i + 1) begin
            for (j = 0; j < 8; j = j + 1) begin
                screen[i][8*j +: 8] = $random & 8'hFF;
            end
        end
        
        screen[2][16 +: 8] = 8'hAA;
        screen[5][32 +: 8] = 8'h55;
        screen[10][48 +: 8] = 8'hEC;
        
        #50 set = 1;
        #10 set = 0;
        
        $dumpfile("display_tb.vcd");
        $dumpvars(0, uut);
        
        #5000000 $finish;
    end
endmodule
