module test();
    reg [11:0] address;
    reg [7:0] data_in;
    reg set;
    reg clk;
    wire [7:0] data_out;
    
    memory mem (
        .address(address),
        .data_in(data_in),
        .set(set),
        .clk(clk),
        .data_out(data_out)
    );
    
    always #5 clk = ~clk;
    
    initial begin
        clk = 0;
        set = 0;
        address = 0;
        data_in = 0;
        
        #10;
        address = 12'h001;
        data_in = 8'hA5;
        set = 1;
        #10;
        set = 0;
        
        #10;
        address = 12'h001;
        #10;
        
        address = 12'h002;
        data_in = 8'h3C;
        set = 1;
        #10;
        set = 0;
        
        #10;
        address = 12'h002;
        #10;
        
        address = 12'h001;
        #10;

        address = 12'h050;
        #20;
        
        $stop;
    end

    initial begin
        $dumpfile("mem.vcd");
        $dumpvars(0,test);
    end
    
endmodule
