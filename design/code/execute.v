module execute
(
    input wire [31:0] pc,
    input wire BrUn,
    input wire ASel,
    input wire BSel,
    input wire [3:0] ALUSel,
    input wire [31:0] imm,
    input wire [31:0] data_rs1,
    input wire [31:0] data_rs2,
    output wire BrEq,
    output wire BrLT,
    output wire [31:0] ALURes,
    input wire [1:0] ASelBypass,
    input wire [1:0] BSelBypass,
    input wire [31:0] m_ALURes,
    input wire [31:0] w_data_out,
    output wire [31:0] B_bypass_data 
);

wire [31:0] A;
wire [31:0] B;
wire [31:0] A_bypass_data;

assign A_bypass_data = (ASelBypass == 1) ? m_ALURes : (ASelBypass == 2) ? w_data_out : data_rs1;
assign B_bypass_data = (BSelBypass == 1) ? m_ALURes : (BSelBypass == 2) ? w_data_out : data_rs2;

assign A = ASel ? pc : A_bypass_data;
assign B = BSel ? imm : B_bypass_data;

branch_comparator branch_comparator1(
    .dataA(A_bypass_data),
    .dataB(B_bypass_data),
    .BrUn(BrUn),
    .BrLT(BrLT),
    .BrEq(BrEq)
);

alu alu1(
    .A(A),
    .B(B),
    .ALUSel(ALUSel), 
    .ans(ALURes)
);

endmodule