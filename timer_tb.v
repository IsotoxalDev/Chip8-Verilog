module test;
    reg clk, set;
    reg [7:0] time_in;
    wire [7:0] time_out;
    
    parameter fps = 27000000;
    localparam DELAY_FRAMES = 27000000 / fps;
    
    timer #(27000000) uut (
        .clk(clk),
        .time_in(time_in),
        .set(set),
        .time_out(time_out)
    );
    //defparam uut.fps = 27000000;
    
    always #1 clk = ~clk;
    
    initial begin
        clk = 0;
        set = 0;
        time_in = 8'd8;
        
        #2;
        set = 1;
        #2;
        set = 0;
        
        #100
        
        $stop;
    end

    initial begin
        $dumpfile("timer.vcd");
        $dumpvars(0,test);
    end
endmodule
