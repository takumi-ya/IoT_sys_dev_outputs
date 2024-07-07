module mandelbrot_calc(
    input wire clk,
    input wire reset,
    input wire [9:0] x, // 横方向のピクセル座標
    input wire [8:0] y, // 縦方向のピクセル座標
    output reg [7:0] iter // 反復回数
);
    parameter MAX_ITER = 255;
    parameter FIXED_POINT_FRACTION_BITS = 16;
    parameter SCALE = 32'h10000; // 固定小数点スケールファクター (1 << FIXED_POINT_FRACTION_BITS)

    reg signed [31:0] a, b, xn, yn, xn2, yn2, temp_xn;
    reg [7:0] iteration;
    reg [1:0] state;

    localparam IDLE = 2'b00;
    localparam CALC = 2'b01;
    localparam DONE = 2'b10;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            iter <= 0;
            state <= IDLE;
        end else begin
            case (state)
                IDLE: begin
                    if (x < 640 && y < 480) begin
                        // ピクセル位置をマンデルブロー集合の座標にマッピング
                        a <= ((x * SCALE) / 640) - (SCALE / 2);
                        b <= ((y * SCALE) / 480) - (SCALE / 4);
                        xn <= 0;
                        yn <= 0;
                        xn2 <= 0;
                        yn2 <= 0;
                        iteration <= 0;
                        state <= CALC;
                    end
                end

                CALC: begin
                    if (iteration < MAX_ITER && (xn2 + yn2 <= (4 * SCALE))) begin
                        xn2 <= (xn * xn) >> FIXED_POINT_FRACTION_BITS;
                        yn2 <= (yn * yn) >> FIXED_POINT_FRACTION_BITS;
                        temp_xn <= xn2 - yn2 + a;
                        yn <= ((xn * yn) >> (FIXED_POINT_FRACTION_BITS - 1)) + b;
                        xn <= temp_xn;
                        iteration <= iteration + 1;
                    end else begin
                        iter <= iteration;
                        state <= DONE;
                    end
                end

                DONE: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule