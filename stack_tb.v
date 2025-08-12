module test();
    reg clk, push, pop;
    reg [15:0] data_in;
    wire [15:0] data_out;
    
    stack stk (
        .clk(clk),
        .push(push),
        .pop(pop),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        push = 0;
        pop = 0;
        data_in = 0;
        
        #10;
        data_in = 17'h1A3;
        push = 1;
        #10;
        push = 0;
        
        #10;
        data_in = 17'h2B4;
        push = 1;
        #10;
        push = 0;
        
        #10;
        pop = 1;
        #10;
        pop = 0;
        
        #10;
        pop = 1;
        #10;
        pop = 0;
        #20
        
        $stop;
    end

    initial begin
        $dumpfile("stack.vcd");
        $dumpvars(0,test);
    end
endmodule