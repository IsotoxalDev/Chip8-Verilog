module chip8 (
    input clk,
    output uart_tx
);
    reg [7:0] sound_time_in, delay_time_in;
    reg sound_set, delay_set;
    wire [7:0] sound_time_out, delay_time_out;

    timer sound_timer (
        .clk(clk),
        .time_in(sound_time_in),
        .time_out(sound_time_out),
        .set(sound_set)
    );

    timer delay_timer (
        .clk(clk),
        .time_in(delay_time_in),
        .time_out(delay_time_out),
        .set(delay_set)
    );

    reg [2047:0] screen;  // 64x32 bits = 2048 bits
    reg display_set;

    Display display (
        .clk(clk),
        .uart_tx(uart_tx),
        .screen_flat(screen),
        .set(display_set)
    );

    reg [7:0] memory [0:4095];

    // CPU

    parameter instructions_per_second = 700;
    localparam DELAY_FRAMES = 27000000 / instructions_per_second;
    reg [15:0] frame_counter;
    reg [11:0] PC;
    reg [7:0] V [0:15];
    reg [11:0] I;

    reg display_pulse;

    // Declare all needed variables outside always block
    reg [15:0] Instruction;
    reg [3:0] instr;
    reg [3:0] X;
    reg [3:0] Y;
    reg [3:0] N;
    reg [7:0] NN;
    reg [11:0] NNN;

    reg [5:0] x;
    reg [4:0] y;
    integer r, p;
    reg [10:0] bit_index;
    reg [7:0] b;

    initial begin
        $readmemh("font.hex", memory, 'h050, 'h09F); // Load font data into memory
        $readmemb("IBMLOGO.bin", memory, 'h200);
        frame_counter = 0;
        PC = 12'h200;
        display_set = 0;
        display_pulse = 0;
    end

    always @(posedge clk) begin
        frame_counter <= frame_counter + 1;

        if (display_pulse) begin
            display_set <= 1;
            display_pulse <= 0;
        end else begin
            display_set <= 0;
        end

        if (frame_counter >= DELAY_FRAMES) begin
            frame_counter <= 0;

            Instruction = {memory[PC], memory[PC + 1]};
            PC <= PC + 2;

            instr = Instruction[15:12];
            X = Instruction[11:8];
            Y = Instruction[7:4];
            N = Instruction[3:0];
            NN = Instruction[7:0];
            NNN = Instruction[11:0];

            case (instr)
                'h0: begin
                    if (N == 0) screen <= 0;
                    display_pulse <= 1;
                end
                'h1: PC <= NNN;
                'h6: V[X] <= NN;
                'h7: V[X] <= V[X] + NN;
                'hA: I <= NNN;
                'hD: begin
                    x = V[X] & 6'b111111;
                    y = V[Y] & 5'b11111;
                    V[15] = 0;

                    for (r = 0; r < 16; r = r + 1) begin
                        if (r < N && (y + r) < 32) begin
                            b = memory[I + r];
                            for (p = 0; p < 8; p = p + 1) begin
                                if ((x + p) < 64) begin
                                    bit_index = (y + r) * 64 + (x + p);
                                    if (b[7 - p]) begin
                                        if (screen[bit_index]) V[15] = 1;
                                        screen[bit_index] = screen[bit_index] ^ 1;
                                    end
                                end
                            end
                        end
                    end
                    display_pulse <= 1;
                end
            endcase
        end
    end
endmodule
