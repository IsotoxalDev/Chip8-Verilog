module timer #(
    parameter fps = 60
) (
    input clk,
    input [7:0] time_in,
    input set,
    output reg [7:0] time_out
);
    localparam DELAY_FRAMES = 27000000 / fps;
    reg [18:0] frame_count;

    initial frame_count = 0;

    always @(posedge clk) begin
        frame_count <= frame_count + 1;

        if (set) begin
            time_out <= time_in;
            frame_count <= 0;
        end
        
        if (frame_count + 1 >= DELAY_FRAMES) begin
            if (time_out > 0) 
                time_out <= time_out - 1;
            frame_count <= 0;
        end
    end
endmodule
