module control
(
    input wire [6:0] opcode, 
    input wire [2:0] funct3,
    input wire [6:0] funct7,
    input wire BrEq,
    input wire BrLT,
    output reg RegWEn,
    output reg BrUn, // 0 - Signed; 1 - Unsigned
    output reg ASel, // 1 - pc; 0 - reg[rs1]
    output reg BSel, // 1 - immediate; 0 - reg[rs2]
    output reg [3:0] ALUSel,
    output reg PCSel, // 1 - ALU; 0 - PC + 4
    output reg [1:0] WBSel, // 0 - Mem; 1 - ALU; 2 - PC+4
    output reg MemRW,
    output reg [1:0] MEMBitWidth, // 0 - Byte; 1 - Half Word; 2 - Word
    output reg MEMUnsigned // 0 - Signed; 1 - Unsigned
);

always @(*) begin
    PCSel = 0; // Default: PC + 4
    RegWEn = 1; // Default: Write Enable
    ASel = 0; // Default: reg[rs1]
    BSel = 1; // Default: immediate
    ALUSel = 0; // Default: add
    MemRW = 0; // Default: Write Disabled
    WBSel = 1; // Default: ALU

    MEMBitWidth = 2; // Default: word
    MEMUnsigned = 0; // Default: signed

    BrUn = 0; // Default: signed
    
    case (opcode[6:2])
        5'b01100 : begin
            //R-Type

            // PCSel already set to PC + 4
            // RegWEn already set to enable
            // ASel already set to register
            BSel = 0; // Set to reg
            // ALUSel will be set below
            // MemRW already set to write disabled
            // WBSel already to ALU

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
            case(funct3)
                3'b000 : begin
                    if (funct7[5]) begin
                        //SUB 
                        ALUSel = 1; // Set to sub
                    end
                    else begin
                        //ADD
                        ALUSel = 0; // Set to add
                    end
                end
                3'b001 : begin
                    //SLL
                    ALUSel = 2; // Set to shift left logical
                end
                3'b010 : begin
                    //SLT
                    ALUSel = 3; // Set to less than
                end
                3'b011 : begin
                    //SLTU
                    ALUSel = 4; // Set to less than unsigned
                end
                3'b100 : begin
                    //XOR
                    ALUSel = 5; // Set to xor
                end
                3'b101 : begin
                    if (funct7[5]) begin
                        //SRA
                        ALUSel = 6; // Set to shift right arithmetic
                    end else begin
                        //SRL
                        ALUSel = 7; // Set to shift right logical
                    end
                end
                3'b110 : begin
                    //OR
                    ALUSel = 8; // Set to or
                end
                3'b111 : begin
                    //AND
                    ALUSel = 9; // Set to and
                end
                default : begin
                    //NOP
                    PCSel = 0; //PC select is set to PC + 4
                    RegWEn = 0; // Disable reg writes
                    MemRW = 0; //Disable write to memory
                end
            endcase
        end
        5'b00100 : begin
            //I-TYPE
            
            // PCSel already set to PC + 4
            // RegWEn already set to enable
            // ASel already set to register
            // BSel already set to immediate
            // ALUSel will be set below
            // MemRW already set to write disabled
            // WBSel already to ALU

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
            case(funct3)
                3'b101 : begin
                    if (funct7[5]) begin
                        //SRAI
                        ALUSel = 6; // Set to shift right arithmetic
                    end else begin
                        //SRLI
                        ALUSel = 7; // Set to shift right logical
                    end
                end
                3'b001 : begin
                    //SLLI
                    ALUSel = 2; // Set to shift left logical
                end
                3'b111 : begin
                    //ANDI
                    ALUSel = 9; // Set to and
                end
                3'b110 : begin
                    //ORI
                    ALUSel = 8; // Set to or
                end
                3'b100 : begin
                    //XORI
                    ALUSel = 5; // Set to xor
                end
                3'b011 : begin
                    //SLTIU
                    ALUSel = 4; // Set to less than unsigned
                end
                3'b010 : begin
                    //SLTI
                    ALUSel = 3; // Set to less than
                end
                3'b000 : begin
                    //ADDI
                    ALUSel = 0; // Set to add
                end
                default : begin
                    //NOP
                    PCSel = 0; //PC select is set to PC + 4
                    RegWEn = 0; // Disable reg writes
                    MemRW = 0; //Disable write to memory
                end
            endcase
        end
        5'b01000 : begin
            //S-TYPE

            // PCSel already set to PC + 4
            RegWEn = 0; // Disable register writes
            // ASel already set to register
            // BSel already set to immediate
            // ALUSel already set to add
            MemRW = 1; // Enable memory writes
            // WBSel value doesn't matter

            // MEMBitWidth value set below
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
            case(funct3)
                3'b010 : begin
                    //SW
                    MEMBitWidth = 2; // Set to word
                end
                3'b001 : begin
                    //SH
                    MEMBitWidth = 1; // Set to half word
                end
                3'b000 : begin
                    //SB
                    MEMBitWidth = 0; // Set to byte
                end
                default : begin
                    //NOP
                    PCSel = 0; //PC select is set to PC + 4
                    RegWEn = 0; // Disable reg writes
                    MemRW = 0; //Disable write to memory
                end
            endcase
        end
        5'b00000 : begin
            //I-TYPE for memory reads

            // PCSel already set to PC + 4
            // RegWEn already set to enable
            // ASel already set to register
            // BSel already set to immediate
            // ALUSel already set to add
            // MemRW already set to write disabled
            WBSel = 0; // Set to memory

            // MEMBitWidth will be set below
            // MEMUnsigned already set to signed

            // BrUn value doesn't matter
            case(funct3)
                3'b000 : begin
                    //LB
                    MEMBitWidth = 0; // Set to byte
                end
                3'b001 : begin
                    //LH
                    MEMBitWidth = 1; // Set to half word
                end
                3'b010 : begin
                    //LW
                    MEMBitWidth = 2; // Set to word
                end
                3'b100 : begin
                    //LBU
                    MEMUnsigned = 1; // Set to unsigned
                    MEMBitWidth = 0; // Set to byte
                end
                3'b101 : begin
                    //LHU
                    MEMUnsigned = 1; // Set to unsigned
                    MEMBitWidth = 1; // Set to half word
                end
                default : begin
                    //NOP
                    PCSel = 0; //PC select is set to PC + 4
                    RegWEn = 0; // Disable reg writes
                    MemRW = 0; //Disable write to memory
                end
            endcase
        end
        5'b11000 : begin
            //B-TYPE

            // PCSel already set to PC + 4
            RegWEn = 0; // Disable write to reg
            ASel = 1; // Set to PC
            // BSel already set to immediate
            // ALUSel already set to add
            // MemRW already set to write disabled
            // WBSel value doesn't matter

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn already set to signed
            case(funct3)
                3'b111 : begin
                    //BGEU
                    BrUn = 1; // Set to unsigned
                    PCSel = ~BrLT; // PCSel follows inverse of BrLT 
                end
                3'b110 : begin
                    //BLTU
                    BrUn = 1; // Set to unsigned
                    PCSel = BrLT; // PCSel follows BrLT 
                end
                3'b101 : begin
                    //BGE
                    PCSel = ~BrLT; // PCSel follows inverse of BrLT 
                end
                3'b100 : begin
                    //BLT
                    PCSel = BrLT; // PCSel follows BrLT 
                end
                3'b001 : begin
                    //BNE
                    PCSel = ~BrEq; // PCSel follows inverse of BrEq
                end
                3'b000 : begin
                    //BEQ
                    PCSel = BrEq; // PCSel follows BrEq
                end
                default : begin
                    //NOP
                    PCSel = 0; // PC select is set to PC + 4
                    RegWEn = 0; // Disable reg writes
                    MemRW = 0; // Disable write to memory
                end
            endcase
        end
        5'b11001 : begin
            //JALR

            PCSel = 1; // Set to ALU        
            // RegWEn already set to enable
            // ASel already set to register
            // BSel already set to immediate
            // ALUSel already set to add
            // MemRW already set to write disabled
            WBSel = 2; // Set to PC + 4

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
        end
        5'b11011 : begin
            //JAL

            PCSel = 1; // Set to ALU        
            // RegWEn already set to enable
            ASel = 1; // Set to PC
            // BSel already set to immediate
            // ALUSel already set to add
            // MemRW already set to write disabled
            WBSel = 2; // Set to PC + 4

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
        end
        5'b00101 : begin
            //AUIPC

            // PCSel already set to PC + 4      
            // RegWEn already set to enable
            ASel = 1; // Set to PC
            // BSel already set to immediate
            // ALUSel already set to add
            // MemRW already set to write disabled
            // WBSel alraedy set to alu

            // MEMBitWidth value doesn't matter
            // MEMUnsigned value doesn't matter

            // BrUn value doesn't matter
        end
        5'b01101 : begin
            //LUI
            // By default, everything already set
            // Reg1 already set to 0 in decode stage
        end
        default : begin
            // ECALL + NOP
            PCSel = 0; //PC select is set to PC + 4
            RegWEn = 0; // Disable reg writes
            MemRW = 0; //Disable write to memory
        end          
    endcase
end
endmodule