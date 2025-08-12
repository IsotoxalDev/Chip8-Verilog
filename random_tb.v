module test;
    reg clk;
    wire [7:0] data_out;
    
    random uut (
        .clk(clk),
        .data_out(data_out)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        #100;
        $stop;
    end


    initial begin
        $dumpfile("random.vcd");
        $dumpvars(0,test);
    end
endmodule