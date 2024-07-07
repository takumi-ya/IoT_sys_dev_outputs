module IOTimage (
    input wire clk,
    input wire reset,
    output reg done         // Signal indicating calculation is done
);

    // Parameters for Mandelbrot calculation and memory size
    parameter H_DISPLAY = 640;  // Horizontal display width
    parameter V_DISPLAY = 480;  // Vertical display height
    parameter MAX_ITER = 250;   // Maximum number of iterations
    parameter NUM_UNITS = 4;    // Number of parallel calculation units

    // Memory to store the calculation results
    reg [7:0] mem [0:H_DISPLAY*V_DISPLAY-1];
    integer i, j;

    // Horizontal and vertical counters
    reg [9:0] h_count [0:NUM_UNITS-1];
    reg [9:0] v_count [0:NUM_UNITS-1];
    reg [18:0] mem_addr [0:NUM_UNITS-1];

    // Color values from the Mandelbrot modules
    wire [7:0] color [0:NUM_UNITS-1];

    // Completion flags for each unit
    reg unit_done [0:NUM_UNITS-1];

    // Calculate if all units are done
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            done <= 0;
        end else begin
            done <= 1;
            for (j = 0; j < NUM_UNITS; j = j + 1) begin
                if (!unit_done[j]) begin
                    done <= 0;
                end
            end
        end
    end

    // Instantiate the Mandelbrot modules
    genvar k;
    generate
        for (k = 0; k < NUM_UNITS; k = k + 1) begin : mandelbrot_units
            initial begin
                h_count[k] = k * (H_DISPLAY / NUM_UNITS);
                v_count[k] = 0;
                mem_addr[k] = k * (H_DISPLAY / NUM_UNITS);
                unit_done[k] = 0;
            end

            always @(posedge clk or posedge reset) begin
                if (reset) begin
                    h_count[k] <= k * (H_DISPLAY / NUM_UNITS);
                    v_count[k] <= 0;
                    mem_addr[k] <= k * (H_DISPLAY / NUM_UNITS);
                    unit_done[k] <= 0;
                end else if (!unit_done[k]) begin
                    if (h_count[k] < (k + 1) * (H_DISPLAY / NUM_UNITS) - 1) begin
                        h_count[k] <= h_count[k] + 1;
                    end else begin
                        h_count[k] <= k * (H_DISPLAY / NUM_UNITS);
                        if (v_count[k] < V_DISPLAY - 1) begin
                            v_count[k] <= v_count[k] + 1;
                        end else begin
                            unit_done[k] <= 1; // This unit is done
                        end
                    end

                    // Store the result in memory
                    mem[mem_addr[k]] <= color[k];
                    mem_addr[k] <= mem_addr[k] + 1;
                end
            end

            mandelbrot_calc mandelbrot_inst (
                .clk(clk),
                .reset(reset),
                .pixel_x(h_count[k]),
                .pixel_y(v_count[k]),
                .color(color[k])
            );
        end
    endgenerate

endmodule