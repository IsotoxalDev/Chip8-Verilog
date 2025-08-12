module memory (
    input clk, set,
    input [11:0] address,
    input [7:0] data_in,
    output reg [7:0] data_out
);
    reg [7:0] data [0:4095];

    initial $readmemh("font.hex", data, 'h050, 'h09F);

    always @(posedge clk) begin
        if (set) begin
            data[address] <= data_in;
            data_out <= data_in;
        end else begin
            data_out <= data[address];
        end
    end
endmodule
