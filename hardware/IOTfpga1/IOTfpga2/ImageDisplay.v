module ImageDisplay(
    input wire clk,
    input wire reset,
    output wire [7:0] ppm_data,
    output wire ppm_valid
);
    reg [18:0] addr; // メモリアドレスカウンター
    reg [7:0] data; // メモリから読み出したデータ
    reg valid; // データ有効フラグ

    // メモリモジュールのインスタンス化
    memory memory_inst (
        .clk(clk),
        .reset(reset),
        .init(1'b0), // 初期化信号は使わない
        .addr(addr),
        .data_in(8'h00),
        .we(1'b0), // 書き込みはしない
        .data_out(data)
    );

    // PPMフォーマットデータ出力
    assign ppm_data = data;
    assign ppm_valid = valid;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr <= 0;
            valid <= 0;
        end else begin
            if (addr < 307200) begin
                addr <= addr + 1;
                valid <= 1;
            end else begin
                valid <= 0;
            end
        end
    end
endmodule