module stack(
    input clk, push, pop,
    input [15:0] data_in,
    output reg [15:0] data_out
);
    reg [15:0] data [0:15];
    reg [3:0] stack_pointer;

    initial begin
        stack_pointer = 0;
    end

    always @(posedge clk) begin
        if (push && stack_pointer < 16) begin
            data[stack_pointer] <= data_in;
            stack_pointer <= stack_pointer + 1;
        end

        if (pop && stack_pointer > 0) begin
            stack_pointer <= stack_pointer - 1;
            data_out <= data[stack_pointer - 1];
        end
    end
endmodule

