module pd(
  input clock,
  input reset
);

/* ----------- Variables ----------- */

// FETCH: F/D Transitional Variables
wire [31:0] f_pc;

// DECODE: F/D Transitional Variables
reg [31:0] d_pc;
wire [31:0] d_data_temp;
wire [31:0] d_data_out;

// DECODE: Internal Variables
wire [4:0] d_shamt;
reg decode_reset;

// DECODE: D/X Transitional Variables
// d_pc
wire [31:0] d_imm;
wire [6:0] d_opcode;
wire [2:0] d_funct3;
wire [6:0] d_funct7;
wire [4:0] d_rs1;
wire [4:0] d_rs2;
wire [4:0] d_rd;

// EXECUTE: D/X Transitional Variables
reg [31:0] x_pc;
wire [31:0] x_data_rs1;
wire [31:0] x_data_rs2;
reg [31:0] x_imm;
reg [6:0] x_opcode;
reg [2:0] x_funct3;
reg [6:0] x_funct7;
reg [4:0] x_rs1;
reg [4:0] x_rs2;
reg [4:0] x_rd;

// EXECUTE: Internal/Control Variables
wire x_BrEq;
wire x_BrLT;
wire x_BrUn;
wire x_ASel;
wire x_BSel;
wire [3:0] x_ALUSel;
wire x_PCSel;
wire [1:0] ASelBypass;
wire [1:0] BSelBypass;
wire stall;
reg execute_reset;
wire [31:0] x_data_rs1_temp;
wire [31:0] x_data_rs2_temp;

// EXECUTE: X/M Transitional Variables
// x_pc
// x_rs1
// x_rs2
// x_rd
// x_opcode
wire [31:0] x_data_rs2_bypass;
wire [31:0] x_ALURes;
wire x_MemRW;
wire [1:0] x_MEMBitWidth;
wire x_MEMUnsigned;
wire [1:0] x_WBSel;
wire x_RegWEn;

// MEMORY: X/M Transitional Variables
reg [31:0] m_pc;
reg [31:0] m_data_rs2;
reg [4:0] m_rs1;
reg [4:0] m_rs2;
reg [4:0] m_rd;
reg [6:0] m_opcode;
reg [31:0] m_ALURes;
reg m_MemRW;
reg [1:0] m_MEMBitWidth;
reg m_MEMUnsigned;
reg [1:0] m_WBSel;
reg m_RegWEn;

// MEMORY: Internal Variables
wire WMSelBypass;
wire [31:0] m_bypass_data;
wire [31:0] m_data_out_temp;

// MEMORY: M/W Transitional Variables
// m_pc
// m_rs1
// m_rs2
// m_rd
// m_opcode
// m_RegWEn
// m_ALURes
// m_WBSel;
wire [31:0] m_data_out;

// WRITE BACK: M/W Transitional Variables
reg [31:0] w_pc;
reg [4:0] w_rs1;
reg [4:0] w_rs2;
reg [4:0] w_rd;
reg [6:0] w_opcode;
reg w_RegWEn;
reg [31:0] w_ALURes;
reg [1:0] w_WBSel;
wire [31:0] w_data_out;
wire w_RegWEn_R;

reg writeback_reset;

/* ------------- Stages ------------- */

// NOP: ADDI x0, x0, 0
`define NOP_INSTR 32'h00000013
`define NOP_OPCODE 7'b0010011

always @(posedge clock) begin
  if (reset) begin
    d_pc <= `ADDR_START;

    x_pc <= `ADDR_START;
    x_imm <= 0;
    x_opcode <= `NOP_OPCODE;     // Set to NOP
    x_funct3 <= 0;              // Set to NOP
    x_funct7 <= 0;              // Set to NOP
    x_rs1 <= 0;                 // Set to NOP
    x_rs2 <= 0;                 // Set to NOP
    x_rd <= 0;                  // Set to NOP

    m_pc <= `ADDR_START;
    m_data_rs2 <= 0;
    m_rs1 <= 0;                 // Set to NOP
    m_rs2 <= 0;                 // Set to NOP
    m_rd <= 0;                  // Set to NOP
    m_opcode <= `NOP_OPCODE;     // Set to NOP
    m_ALURes <= 0;
    m_MemRW <= 0;
    m_MEMBitWidth <= 0;
    m_MEMUnsigned <= 0;
    m_WBSel <= 1;               // Should default to ALU
    m_RegWEn <= 0;

    w_pc <= `ADDR_START;
    w_rs1 <= 0;                 // Set to NOP
    w_rs2 <= 0;                 // Set to NOP
    w_rd <= 0;                  // Set to NOP
    w_opcode <= `NOP_OPCODE;     // Set to NOP
    w_RegWEn <= 0;
    w_ALURes <= 0;
    w_WBSel <= 1;               // Should default to ALU

    decode_reset <= 1;
    execute_reset <= 1;
    writeback_reset <= 1;
  end else begin
    // If branching, set FETCH and DECODE to NOP
    if (x_PCSel == 1) begin
      // F/D FETCH TO DECODE
      d_pc <= `ADDR_START;
      // D/X DECODE TO EXECUTE
      x_pc <= `ADDR_START;
      x_imm <= 0;
      x_opcode <= `NOP_OPCODE;     // Set to NOP
      x_funct3 <= 0;              // Set to NOP
      x_funct7 <= 0;              // Set to NOP
      x_rs1 <= 0;                 // Set to NOP
      x_rs2 <= 0;                 // Set to NOP
      x_rd <= 0;                  // Set to NOP
  
    // If stalling, insert NOP at D/X and stall FETCH & DECODE
    end else if (stall == 1) begin
        // FETCH stalled in fetch1 module
        // DECODE stalled by not including F/D transition
        
        // D/X DECODE TO EXECUTE
        x_pc <= `ADDR_START;
        x_imm <= 0;
        x_opcode <= `NOP_OPCODE;     // Set to NOP
        x_funct3 <= 0;              // Set to NOP
        x_funct7 <= 0;              // Set to NOP
        x_rs1 <= 0;                 // Set to NOP
        x_rs2 <= 0;                 // Set to NOP
        x_rd <= 0;                  // Set to NOP

    // If not branching or stalling, continue as normal
    end else begin
      // F/D FETCH TO DECODE
      d_pc <= f_pc;
      // D/X DECODE TO EXECUTE
      x_pc <= d_pc;
      x_imm <= d_imm;
      x_opcode <= d_opcode;
      x_funct3 <= d_funct3;
      x_funct7 <= d_funct7;
      x_rs1 <= d_rs1;
      x_rs2 <= d_rs2;
      x_rd <= d_rd;
    end
    
    // X/M EXECUTE TO MEMORY
    m_pc <= x_pc;
    m_data_rs2 <= x_data_rs2_bypass;
    m_rs1 <= x_rs1;
    m_rs2 <= x_rs2;
    m_rd <= x_rd;
    m_opcode <= x_opcode;
    m_ALURes <= x_ALURes;
    m_MemRW <= x_MemRW;
    m_MEMBitWidth <= x_MEMBitWidth;
    m_MEMUnsigned <= x_MEMUnsigned;
    m_WBSel <= x_WBSel;
    m_RegWEn <= x_RegWEn;
    // M/W MEMORY TO WRITEBACK
    w_pc <= m_pc;
    w_rs1 <= m_rs1;
    w_rs2 <= m_rs2;
    w_rd <= m_rd;
    w_opcode <= m_opcode;
    w_RegWEn <= m_RegWEn;
    w_WBSel <= m_WBSel;
    w_ALURes <= m_ALURes;

    decode_reset <= reset || x_PCSel;
    execute_reset <= reset || stall;
    writeback_reset <= reset;
  end
end

// Fetch Stage
fetch fetch1(
  .reset(reset),
  .clock(clock),
  .pc(f_pc),
  .f_data_out(d_data_temp),
  .PCSel(x_PCSel),
  .ALURes(x_ALURes),
  .stall(stall)
);

assign d_data_out = decode_reset ? `NOP_INSTR : d_data_temp;

// Decode Stage
decode decode1(
  .instr(d_data_out),
  .opcode(d_opcode),
  .rd(d_rd),
  .rs1(d_rs1),
  .rs2(d_rs2),
  .funct3(d_funct3),
  .funct7(d_funct7),
  .imm(d_imm)
);

register_file register_file1(
    .clock(clock),
    .addr_rs1(d_rs1),
    .addr_rs2(d_rs2),
    .addr_rd(w_rd),
    .data_rd(w_data_out),
    .data_rs1(x_data_rs1_temp),
    .data_rs2(x_data_rs2_temp),
    .write_enable(w_RegWEn_R)
);

assign x_data_rs1 = execute_reset ? 0 : x_data_rs1_temp;
assign x_data_rs2 = execute_reset ? 0 : x_data_rs2_temp;

assign d_shamt = d_rs2;
assign w_RegWEn_R = w_RegWEn & ~reset;

// Control Logic / Execute Stage
control control1(
    .opcode(x_opcode), 
    .funct3(x_funct3),
    .funct7(x_funct7),
    .BrEq(x_BrEq),
    .BrLT(x_BrLT),
    .RegWEn(x_RegWEn),
    .BrUn(x_BrUn),
    .ASel(x_ASel),
    .BSel(x_BSel),
    .ALUSel(x_ALUSel),
    .PCSel(x_PCSel),
    .WBSel(x_WBSel),
    .MemRW(x_MemRW),
    .MEMBitWidth(x_MEMBitWidth),
    .MEMUnsigned(x_MEMUnsigned)
);

execute execute1(
    .pc(x_pc),
    .BrUn(x_BrUn),
    .ASel(x_ASel),
    .BSel(x_BSel),
    .ALUSel(x_ALUSel),
    .imm(x_imm),
    .data_rs1(x_data_rs1),
    .data_rs2(x_data_rs2),
    .BrEq(x_BrEq),
    .BrLT(x_BrLT),
    .ALURes(x_ALURes),
    .ASelBypass(ASelBypass),
    .BSelBypass(BSelBypass),
    .m_ALURes(m_ALURes),
    .w_data_out(w_data_out),
    .B_bypass_data(x_data_rs2_bypass)
);

bypass bypass1(
    .x_rs1(x_rs1),
    .x_rs2(x_rs2),
    .x_opcode(x_opcode),
    .m_rs2(m_rs2),
    .m_rd(m_rd),
    .m_opcode(m_opcode),
    .w_rd(w_rd),
    .w_opcode(w_opcode),
    .ASelBypass(ASelBypass),
    .BSelBypass(BSelBypass),
    .WMSelBypass(WMSelBypass)
);

stall_control stall_control1(
    .d_rs1(d_rs1),
    .d_rs2(d_rs2),
    .d_opcode(d_opcode),
    .x_rd(x_rd),
    .x_opcode(x_opcode),
    .w_rd(w_rd),
    .w_opcode(w_opcode),
    .stall(stall)
);

// Memory Stage
memory memory1(
    .clock(clock),
    .read_write(m_MemRW),
    .address(m_ALURes),
    .data_in(m_data_rs2),
    .is_unsigned(m_MEMUnsigned),
    .access_size(m_MEMBitWidth),
    .mem_data_out(m_data_out_temp),
    .WMSelBypass(WMSelBypass),
    .w_data_out(w_data_out),
    .bypass_data(m_bypass_data)
);

assign m_data_out = writeback_reset ? 0 : m_data_out_temp;

// Writeback Stage
writeback writeback1(
  .alu_out(w_ALURes),
  .pc(w_pc),
  .m_data_out(m_data_out),
  .wb_sel(w_WBSel),
  .wb_data_out(w_data_out)
);

endmodule
