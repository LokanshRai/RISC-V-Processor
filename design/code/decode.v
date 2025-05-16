module decode
(
    input wire [31:0] instr,
    output wire [6:0] opcode,
    output wire [4:0] rd,
    output wire [4:0] rs1,
    output wire [4:0] rs2,
    output wire [2:0] funct3,
    output wire [6:0] funct7,
    output reg [31:0] imm
);

assign opcode = instr[6:0];
assign rd = instr[11:7];
assign funct3 = instr[14:12];
assign rs1 = (opcode[4:2] == 3'b101 ) ? {5{1'b0}} : instr[19:15]; // Set rs1 to 0x0 for LUI
assign rs2 = instr[24:20];
assign funct7 = instr[31:25];

// TODO:
// - Add mux to select last bits in S and I type instructions instead of using case statement
always @(*) begin
    casez(opcode[6:2])
        // U-type
        5'b??101 : imm = {funct7, rs2, instr[19:15], funct3, {12{1'b0}}}; // rs1 immediate bits needs to be kept for LUI
        // J-type
        5'b1?011 : imm = {{11{funct7[6]}}, funct7[6], rs1, funct3, rs2[0], funct7[5:0], rs2[4:1], 1'b0};
        // I-type
        5'b00?00, 5'b11001 : imm = {{20{funct7[6]}}, funct7, rs2}; 
        // B-type
        5'b11000 : imm = {{19{funct7[6]}}, funct7[6], rd[0], funct7[5:0], rd[4:1], 1'b0};
        // S-type
        5'b010?? : imm = {{20{funct7[6]}}, funct7, rd};
        // R-type or default
        default : imm = 0;
    endcase
end

endmodule