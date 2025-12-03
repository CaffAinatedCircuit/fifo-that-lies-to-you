`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Well call it The creative Inc...like what else
// Engineer: The Great...(Drums rolling, trumpets, 3...2...1..) Rishik Nair
// 
// Create Date: 30.11.2025 12:34:01
// Design Name: chaos_FIFO
// Module Name: chaos_fifo
// Project Name: Top Secret
// Target Devices: Uhmm....lemme check...Virtex UltraScale+ VCU118 Evaluation Platform (xcvu9p-flga2104-2L-e)
// Tool Versions: Vivado 2018.2
// Description: The Chaos FIFO implements a storage buffer where the "reality" of its capacity shifts on every transaction. This design uses a Linear Feedback Shift Register (LFSR) to generate a pseudo-random maximum depth (ranging from 1 to 2047) whenever a read or write occurs. 
//If the random depth drops below the current number of stored items, the FIFO "instantly overflows" (asserts full). If the depth is very low, it effectively "refuses to acknowledge reality" by rejecting writes that a standard FIFO would accept.
// 
// Dependencies: one laptop, vivado, and and fpga
// 
// Revision: Done
// Revision 0.01 - File Created
// Additional Comments:The Brain (LFSR): An 11-bit Linear Feedback Shift Register generates a new pseudo-random number on every clock cycle where wr_en or rd_en is high.
// 
 //////////////////////////////////////////////////////////////////////////////////

module chaos_fifo #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 11  // 2^11 = 2048 locations
)(
    input  wire                  clk,
    input  wire                  rst_n,
    
    // Write Interface
    input  wire                  wr_en,
    input  wire [DATA_WIDTH-1:0] wr_data,
    output wire                  full,      // High when count >= random_depth
    
    // Read Interface
    input  wire                  rd_en,
    output reg  [DATA_WIDTH-1:0] rd_data,
    output wire                  empty,     // High when count == 0
    
    // Debug/Chaos Status
    output wire [ADDR_WIDTH-1:0] current_max_depth
);

    // --------------------------------------------------------
    // Memory and Pointers
    // --------------------------------------------------------
    // Infer Block RAM: 2048 depth
    reg [DATA_WIDTH-1:0] mem [0:(1<<ADDR_WIDTH)-1];
    
    reg [ADDR_WIDTH-1:0] wr_ptr;
    reg [ADDR_WIDTH-1:0] rd_ptr;
    reg [ADDR_WIDTH:0]   count; // Extra bit to distinguish full/empty cleanly

    // --------------------------------------------------------
    // LFSR for Randomized Depth
    // --------------------------------------------------------
    // 11-bit LFSR (Polynomial: x^11 + x^2 + 1)
    // Taps at bit 10 and bit 1 (0-indexed)
    reg [10:0] lfsr_reg;
    
    wire lfsr_feedback;
    assign lfsr_feedback = lfsr_reg[10] ^ lfsr_reg[1]; // XNOR/XOR form

    // The Chaos Trigger: Update LFSR on any attempted access
    wire chaos_trigger = (wr_en || rd_en);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Seed must be non-zero for standard XOR LFSR
            lfsr_reg <= 11'h5A5; 
        end else if (chaos_trigger) begin
            // Shift left and insert feedback
            lfsr_reg <= {lfsr_reg[9:0], lfsr_feedback};
        end
    end

    // The "Reality" of the FIFO currently
    // Masking to ensure we stay within physical bounds (0 to 2047)
    assign current_max_depth = lfsr_reg;

    // --------------------------------------------------------
    // FIFO Logic
    // --------------------------------------------------------
    
    // Standard Full/Empty based on physical pointers vs Randomized Depth
    // "Instantly overflows" if the new random depth is less than current count.
    assign full  = (count >= current_max_depth);
    assign empty = (count == 0);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= 0;
            rd_ptr <= 0;
            count  <= 0;
            rd_data <= 0;
        end else begin
            // WRITE OPERATION
            // Only write if enabled and we haven't hit the *current* random limit
            if (wr_en && !full) begin
                mem[wr_ptr] <= wr_data;
                wr_ptr <= wr_ptr + 1;
            end

            // READ OPERATION
            // Standard read logic
            if (rd_en && !empty) begin
                rd_data <= mem[rd_ptr];
                rd_ptr <= rd_ptr + 1;
            end

            // COUNT UPDATE
            // Handles simultaneous R/W
            case ({ (wr_en && !full), (rd_en && !empty) })
                2'b10: count <= count + 1; // Write only
                2'b01: count <= count - 1; // Read only
                2'b11: count <= count;     // Write and Read (count stays same)
                default: count <= count;
            endcase
        end
    end

endmodule

