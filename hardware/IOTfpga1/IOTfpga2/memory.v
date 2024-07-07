module memory (
    input wire clk,
    input wire reset,
    input wire init, // メモリ初期化信号
    input wire [18:0] addr,
    input wire [7:0] data_in,
    input wire we,
    output reg [7:0] data_out
);
    reg [7:0] mem [0:307199]; // 640x480ピクセル分のメモリ
    reg [18:0] init_addr;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            data_out <= 8'h00;
            init_addr <= 0;
        end else if (init && init_addr < 307200) begin
            mem[init_addr] <= 8'h00;
            init_addr <= init_addr + 1;
        end else begin
            if (we) begin
                mem[addr] <= data_in;
            end
            data_out <= mem[addr];
        end
    end
endmodule
