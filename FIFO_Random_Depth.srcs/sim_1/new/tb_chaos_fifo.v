`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 30.11.2025 12:56:38
// Design Name: 
// Module Name: tb_chaos_fifo
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module tb_chaos_fifo;

    // --------------------------------------------------------
    // Parameters and Signals
    // --------------------------------------------------------
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 11;

    reg                   clk;
    reg                   rst_n;
    reg                   wr_en;
    reg  [DATA_WIDTH-1:0] wr_data;
    wire                  full;
    
    reg                   rd_en;
    wire [DATA_WIDTH-1:0] rd_data; // Driven by DUT
    wire                  empty;
    
    wire [ADDR_WIDTH-1:0] current_max_depth;

    // Test Bench Variables
    integer i;
    reg [DATA_WIDTH-1:0] expected_val;
    reg [DATA_WIDTH-1:0] captured_val; // FIX: Register to hold task output
    integer write_success_count;
    integer read_success_count;

    // --------------------------------------------------------
    // DUT Instantiation
    // --------------------------------------------------------
    chaos_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_chaos_fifo (
        .clk(clk),
        .rst_n(rst_n),
        .wr_en(wr_en),
        .wr_data(wr_data),
        .full(full),
        .rd_en(rd_en),
        .rd_data(rd_data),
        .empty(empty),
        .current_max_depth(current_max_depth)
    );

    // --------------------------------------------------------
    // Clock Generation
    // --------------------------------------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns period
    end

    // --------------------------------------------------------
    // Test Tasks
    // --------------------------------------------------------

    // Task: Stubborn Write
    task stubborn_write;
        input [DATA_WIDTH-1:0] data;
        reg accepted;
        begin
            accepted = 0;
            wr_data = data;
            wr_en = 1;
            
            while (!accepted) begin
                @(posedge clk);
                #1; // Hold time
                
                if (full) begin
                    $display("[T=%0t] Write BLOCKED (Val: 0x%h). Depth shrunk to %0d. Retrying...", 
                             $time, data, current_max_depth);
                    // wr_en stays high to tick the LFSR
                end else begin
                    $display("[T=%0t] Write SUCCESS (Val: 0x%h). Depth is %0d.", 
                             $time, data, current_max_depth);
                    accepted = 1;
                end
            end
            
            wr_en = 0;
            write_success_count = write_success_count + 1;
            @(posedge clk);
        end
    endtask

    // Task: Simple Read
    // Reads from DUT wire 'rd_data' and returns it via 'data_out'
    task try_read;
        output [DATA_WIDTH-1:0] data_out;
        begin
            rd_en = 1;
            @(posedge clk); // Sync with clock for the read command
            #1; 
            // Check if empty *before* we expect valid data
            if (empty) begin
                $display("[T=%0t] Read FAILED: FIFO Empty.", $time);
                data_out = 8'hXX; // Return undefined if empty
            end else begin
                // In this design, read data is available 1 cycle after rd_en
                // Wait for that next cycle to capture the data
                @(posedge clk);
                #1 data_out = rd_data; 
                $display("[T=%0t] Read SUCCESS: Got 0x%h.", $time, data_out);
            end
            rd_en = 0;
            @(posedge clk); // Cleanup cycle
        end
    endtask

    // --------------------------------------------------------
    // Main Stimulus
    // --------------------------------------------------------
    initial begin
        // Init
        rst_n = 0;
        wr_en = 0;
        rd_en = 0;
        wr_data = 0;
        write_success_count = 0;
        read_success_count = 0;
        captured_val = 0;

        // Reset Pulse
        #20 rst_n = 1;
        #10;

        $display("=== CHAOS FIFO TEST START ===");
        
        // 1. Write Sequence
        for (i = 0; i < 32; i = i + 1) begin
            stubborn_write(8'h10 + i);
        end

        $display("--- Write Phase Complete ---");
        
        // 2. Read Back and Verify
        $display("--- Starting Read Phase ---");
        for (i = 0; i < 32; i = i + 1) begin
            if (empty) begin
                $display("ERROR: FIFO unexpectedly empty at index %0d", i);
                $stop;
            end
            
            // FIX: Pass a reg variable (captured_val), NOT the wire (rd_data)
            try_read(captured_val);
            
            expected_val = 8'h10 + i;
            
            if (captured_val !== expected_val) begin
                $display("ERROR: Mismatch! Exp: 0x%h, Got: 0x%h", expected_val, captured_val);
            end else begin
                read_success_count = read_success_count + 1;
            end
        end

        // 3. Final Report
        if (read_success_count == 32) begin
            $display("=== TEST PASSED: Survived the Chaos ===");
        end else begin
            $display("=== TEST FAILED: Data corruption detected ===");
        end

        $finish;
    end

endmodule
