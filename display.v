module Display (
    input clk,
    output uart_tx,
    input [2047:0] screen_flat, // Flattened 64-bit x 32 array
    input set
);
    localparam DELAY_FRAMES = 234;

    localparam TX_STATE_IDLE = 0;
    localparam TX_STATE_START_BIT = 1;
    localparam TX_STATE_WRITE = 2;
    localparam TX_STATE_STOP_BIT = 3;

    localparam START_BYTE = 8'hAA;
    localparam END_BYTE = 8'h55;
    localparam ESCAPE_BYTE = 8'hEC;

    reg [3:0] txState = TX_STATE_IDLE;
    reg txPinRegister = 1;
    reg [24:0] txCounter = 0;
    reg [7:0] data_out = 0;
    reg [5:0] rowCounter = 0;
    reg [4:0] colCounter = 0;
    reg [2:0] txBitNumber = 0;
    reg escaped = 0;
    reg endReg = 0;
    reg [7:0] escapedData = 0;
    reg [7:0] tempData = 0;

    assign uart_tx = txPinRegister;

    always @(posedge clk) begin
        case (txState)
            TX_STATE_IDLE: begin
                if (set) begin
                    txState <= TX_STATE_START_BIT;
                    rowCounter <= 0;
                    colCounter <= 0;
                    data_out <= START_BYTE;
                end else begin
                    txPinRegister <= 1;
                end
            end

            TX_STATE_START_BIT: begin
                txPinRegister <= 0;
                if (txCounter >= DELAY_FRAMES) begin
                    txState <= TX_STATE_WRITE;
                    txBitNumber <= 0;
                    txCounter <= 0;
                end else begin
                    txCounter <= txCounter + 1;
                end
            end

            TX_STATE_WRITE: begin
                txPinRegister <= data_out[txBitNumber];
                if (txCounter >= DELAY_FRAMES) begin
                    if (txBitNumber == 3'b111) begin
                        txState <= TX_STATE_STOP_BIT;
                    end else begin
                        txBitNumber <= txBitNumber + 1;
                    end
                    txCounter <= 0;
                end else begin
                    txCounter <= txCounter + 1;
                end
            end

            TX_STATE_STOP_BIT: begin
                txPinRegister <= 1;
                if (txCounter >= DELAY_FRAMES) begin
                    if (endReg) begin
                        txState <= TX_STATE_IDLE;
                    end else if (rowCounter == 8) begin
                        if (colCounter == 31) begin
                            data_out <= END_BYTE;
                            endReg <= 1;
                        end else begin
                            colCounter <= colCounter + 1;
                            rowCounter <= 0;
                        end
                    end else begin
                        rowCounter <= rowCounter + 1;
                        tempData <= screen_flat[colCounter * 64 + rowCounter * 8 +: 8];

                        if (escaped) begin
                            data_out <= escapedData;
                            escaped <= 0;
                        end else begin
                            case (tempData)
                                START_BYTE, END_BYTE, ESCAPE_BYTE: begin
                                    escaped <= 1;
                                    escapedData <= tempData;
                                    data_out <= ESCAPE_BYTE;
                                end
                                default: data_out <= tempData;
                            endcase
                        end
                        
                        txState <= TX_STATE_START_BIT;
                    end
                    txCounter <= 0;
                end else begin
                    txCounter <= txCounter + 1;
                end
            end

        endcase
    end
endmodule
