module stall_control
(
    input wire [4:0] d_rs1,
    input wire [4:0] d_rs2,
    input wire [6:0] d_opcode,
    input wire [4:0] x_rd,
    input wire [6:0] x_opcode,
    input wire [4:0] w_rd,
    input wire [6:0] w_opcode,
    output wire stall
);
wire load_to_use_stall;
wire writeback_decode_stall;
wire store_memory_decode_stall;

wire d_rs1_valid;
wire d_rs2_valid;
wire x_rd_valid;
wire w_rd_valid;

assign d_rs1_valid =
    d_opcode[6:2] != 5'b01101 // No LUI - No rs1
    && d_opcode[6:2] != 5'b00101 // No AUIPC - No rs1
    && d_opcode[6:2] != 5'b11011; // Mo JAL - No rs1

assign d_rs2_valid =
    d_opcode[6:2] == 5'b11000 // Branch Instructions - Have rs2
    || d_opcode[6:2] == 5'b01100 // ALU Instructions - Have rs2
    || d_opcode[6:2] == 5'b01000; // Store Instructions - Have rs2

assign x_rd_valid = 
    x_opcode[6:2] == 5'b00000 // Only need load instruction
    && x_rd != 0; // Don't need to stall if rd is x0

assign w_rd_valid =
    w_opcode[6:2] != 5'b11000 // No Branch instructions - No rd 
    && w_opcode[6:2] != 5'b01000 // No Store Instructions - No rd
    && w_rd != 0; // Don't need to stall if rd is x0

assign load_to_use_stall = (x_rd_valid 
    && ((d_rs1_valid && (d_rs1 == x_rd))
    || (d_rs2_valid && (d_rs2 == x_rd))));

assign writeback_decode_stall = (w_rd_valid 
    && ((d_rs1_valid && (w_rd == d_rs1))
    || (d_rs2_valid && (w_rd == d_rs2))));

assign stall = load_to_use_stall || writeback_decode_stall;

endmodule