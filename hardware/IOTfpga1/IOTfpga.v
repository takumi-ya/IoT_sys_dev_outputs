module IOTfpga(
    input wire clk,
    input wire reset,
    output wire [7:0] vga_r,
    output wire [7:0] vga_g,
    output wire [7:0] vga_b,
    output wire hsync,
    output wire vsync
);
    wire [9:0] x;
    wire [8:0] y;
    wire [7:0] iter;
    reg [18:0] addr; // メモリアドレス
    wire [7:0] mem_data_out;
    reg [7:0] mem_data_in;
    reg mem_we;

    // VGA同期モジュールのインスタンス化
    vga_sync vga_sync_inst (
        .clk(clk),
        .reset(reset),
        .hsync(hsync),
        .vsync(vsync),
        .x(x),
        .y(y)
    );

    // Mandelbrot計算モジュールのインスタンス化
    mandelbrot_calc mandelbrot_calc_inst (
        .clk(clk),
        .reset(reset),
        .x(x),
        .y(y),
        .iter(iter)
    );

    // メモリモジュールのインスタンス化
    memory memory_inst (
        .clk(clk),
        .reset(reset),
        .addr(addr),
        .data_in(mem_data_in),
        .we(mem_we),
        .data_out(mem_data_out)
    );

    // 色の割り当て（簡単なグレースケール）
    assign vga_r = (iter == 255) ? 8'h00 : iter;
    assign vga_g = (iter == 255) ? 8'h00 : iter;
    assign vga_b = (iter == 255) ? 8'h00 : iter;

    // ピクセルデータをメモリに格納
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            addr <= 0;
            mem_we <= 0;
        end else if (x < 640 && y < 480) begin
            mem_data_in <= iter;
            mem_we <= 1;
            addr <= addr + 1;
        end else begin
            mem_we <= 0;
        end
    end
endmodule
