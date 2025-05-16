module bypass
(
    input wire [4:0] x_rs1,
    input wire [4:0] x_rs2,
    input wire [6:0] x_opcode,
    input wire [4:0] m_rs2,
    input wire [4:0] m_rd,
    input wire [6:0] m_opcode,
    input wire [4:0] w_rd,
    input wire [6:0] w_opcode,
    output reg [1:0] ASelBypass,
    output reg [1:0] BSelBypass,
    output reg WMSelBypass
);

wire x_rs1_valid;
wire x_rs2_valid;
wire m_rs2_valid;
wire m_rd_valid;
wire w_rd_valid;

assign x_rs1_valid =
    x_opcode[6:2] != 5'b01101 // No LUI - No rs1
    && x_opcode[6:2] != 5'b00101 // No AUIPC - No rs1
    && x_opcode[6:2] != 5'b11011; // Mo JAL - No rs1

assign x_rs2_valid =
    x_opcode[6:2] == 5'b11000 // Branch Instructions - Have rs2
    || x_opcode[6:2] == 5'b01100 // ALU Instructions - Have rs2
    || x_opcode[6:2] == 5'b01000; // Store Instructions - Have rs2

// Check if store instruction in memory stage
assign m_rs2_valid = m_opcode[6:2] == 5'b01000;

// Can simplify to 000
assign m_rd_valid =
    m_opcode[6:2] != 5'b11000 // No Branch instructions - No rd
    && m_opcode[6:2] != 5'b01000 // No Store Instructions - No rd
    && m_opcode[6:2] != 5'b00000 // No Load instructions - No valid rd in memory stage
    && m_rd != 0; // Don't need to bypass if rd is x0

assign w_rd_valid =
    w_opcode[6:2] != 5'b11000 // No Branch instructions - No rd 
    && w_opcode[6:2] != 5'b01000 // No Store Instructions - No rd
    && w_rd != 0; // Don't need to bypass if rd is x0

always @(*) begin
    // 0 is no bypass
    // 1 is M/X bypass
    // 2 is W/X bypass
    // 3 is nothing
    ASelBypass = 0;
    BSelBypass = 0;

    // 0 is no bypass
    // 1 is W/M bypass
    WMSelBypass = 0;
    
    // M/X Bypass
    if (m_rd_valid) begin
        if (x_rs1_valid && (x_rs1 == m_rd))
            ASelBypass = 1;
        if (x_rs2_valid && (x_rs2 == m_rd))
            BSelBypass = 1;
    end

    // W/X Bypass
    if (w_rd_valid) begin
        if (x_rs1_valid && (x_rs1 == w_rd) && (ASelBypass != 1))
            ASelBypass = 2;
        if (x_rs2_valid && (x_rs2 == w_rd) && (BSelBypass != 1))
            BSelBypass = 2;
    end

    // W/M Bypass
    if (w_rd_valid) begin
        if (m_rs2_valid && w_rd == m_rs2) begin
            WMSelBypass = 1;
        end
    end

end

endmodule