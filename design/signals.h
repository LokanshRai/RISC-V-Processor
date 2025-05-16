/* Your Code Below! Enable the following define's
 * and replace ??? with actual wires */
// ----- signals -----
// You will also need to define PC properly
`define F_PC                f_pc
`define F_INSN              d_data_out

`define D_PC                d_pc
`define D_OPCODE            d_opcode
`define D_RD                d_rd
`define D_RS1               d_rs1
`define D_RS2               d_rs2
`define D_FUNCT3            d_funct3
`define D_FUNCT7            d_funct7
`define D_IMM               d_imm
`define D_SHAMT             d_shamt

`define R_WRITE_ENABLE      w_RegWEn
`define R_WRITE_DESTINATION w_rd
`define R_WRITE_DATA        w_data_out
`define R_READ_RS1          d_rs1
`define R_READ_RS2          d_rs2
`define R_READ_RS1_DATA     x_data_rs1
`define R_READ_RS2_DATA     x_data_rs2

`define E_PC                x_pc
`define E_ALU_RES           x_ALURes
`define E_BR_TAKEN          x_PCSel

`define M_PC                m_pc
`define M_ADDRESS           m_ALURes
`define M_RW                m_MemRW
`define M_SIZE_ENCODED      m_MEMBitWidth
`define M_DATA              m_bypass_data

`define W_PC                w_pc
`define W_ENABLE            w_RegWEn
`define W_DESTINATION       w_rd
`define W_DATA              w_data_out

`define IMEMORY             fetch1.imem1
`define DMEMORY             memory1.dmemory1

// ----- signals -----

// ----- design -----
`define TOP_MODULE                 pd
// ----- design -----
