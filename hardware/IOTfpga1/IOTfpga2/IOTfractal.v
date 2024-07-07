module IOTfractal (
    input wire clk,
    input wire reset, // 外部リセット信号：システム全体をリセットする
    input wire start_new_calc, // 新しい計算を開始するための外部信号
    output wire calc_done_led // 計算完了信号をLEDに接続
);
    wire [9:0] x [7:0]; // 各並列モジュールのx座標
    wire [8:0] y [7:0]; // 各並列モジュールのy座標
    wire [7:0] iter [7:0]; // 各並列モジュールの計算結果
    reg [18:0] addr [7:0]; // 各並列モジュールのメモリアドレス
    reg [7:0] mem_data_in [7:0]; // 各並列モジュールのメモリ入力データ
    reg mem_we [7:0]; // 各並列モジュールのメモリ書き込みイネーブル
    wire [7:0] mem_data_out [7:0]; // 各並列モジュールのメモリ出力データ

    reg [9:0] x_count [7:0];
    reg [8:0] y_count [7:0];
    reg [7:0] iter_done [7:0]; // 各並列モジュールの計算完了フラグ

    reg init; // メモリ初期化信号
    reg calc_done; // 内部計算完了信号

    // Mandelbrot計算モジュールのインスタンス化
    genvar i;
    generate
        for (i = 0; i < 8; i = i + 1) begin : mandelbrot_gen
            mandelbrot_calc mandelbrot_calc_inst (
                .clk(clk),
                .reset(reset), // 各モジュールのリセット信号に外部リセット信号を接続
                .x(x_count[i]),
                .y(y_count[i]),
                .iter(iter[i])
            );
        end
    endgenerate

    // メモリモジュールのインスタンス化
    generate
        for (i = 0; i < 8; i = i + 1) begin : memory_gen
            memory memory_inst (
                .clk(clk),
                .reset(reset), // メモリモジュールのリセット信号に外部リセット信号を接続
                .init(init), // メモリ初期化信号
                .addr(addr[i]),
                .data_in(mem_data_in[i]),
                .we(mem_we[i]),
                .data_out(mem_data_out[i])
            );
        end
    endgenerate

    // メモリクリアのためのステートマシン
    reg [1:0] state;
    localparam CLEAR_MEM = 2'b00, CALC = 2'b01, WAIT_NEW_CALC = 2'b10;

    assign calc_done_led = calc_done; // LEDに計算完了信号を接続

    integer j;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            // リセット時の初期化処理
            for (j = 0; j < 8; j = j + 1) begin
                addr[j] <= 0;
                x_count[j] <= 0;
                y_count[j] <= 0;
                mem_we[j] <= 0;
                iter_done[j] <= 0;
            end
            calc_done <= 0; // リセット時にcalc_doneを0にリセット
            init <= 1; // メモリ初期化をトリガー
            state <= CLEAR_MEM;
        end else begin
            case (state)
                CLEAR_MEM: begin
                    init <= 0;
                    state <= CALC;
                end
                CALC: begin
                    calc_done <= 0;
                    for (j = 0; j < 8; j = j + 1) begin
                        if (x_count[j] < 640 && y_count[j] < 480) begin
                            mem_data_in[j] <= iter[j];
                            mem_we[j] <= 1;
                            addr[j] <= y_count[j] * 640 + x_count[j];
                            if (x_count[j] == 639) begin
                                x_count[j] <= 0;
                                y_count[j] <= y_count[j] + 1;
                            end else begin
                                x_count[j] <= x_count[j] + 1;
                            end
                        end else begin
                            mem_we[j] <= 0;
                            iter_done[j] <= 1;
                        end
                    end
                    if (iter_done[0] && iter_done[1] && iter_done[2] && iter_done[3] &&
                        iter_done[4] && iter_done[5] && iter_done[6] && iter_done[7]) begin
                        calc_done <= 1;
                        state <= WAIT_NEW_CALC;
                    end
                end
                WAIT_NEW_CALC: begin
                    if (start_new_calc) begin
                        // 新しい計算の開始
                        for (j = 0; j < 8; j = j + 1) begin
                            x_count[j] <= 0;
                            y_count[j] <= 0;
                            iter_done[j] <= 0;
                        end
                        calc_done <= 0;
                        state <= CLEAR_MEM;
                    end
                end
            endcase
        end
    end

endmodule