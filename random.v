module random(
    input clk,
    output reg [7:0] data_out
);
    always @(posedge clk)
        data_out = $random % 256;
endmodule
