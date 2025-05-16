module writeback
(
    input wire [31:0] alu_out,
    input wire [31:0] pc,
    input wire [31:0] m_data_out,
    input wire [1:0] wb_sel,
    output reg [31:0] wb_data_out
);

wire [31:0] pc_4;

// Write back inputs
assign pc_4 = pc + 4;

// Write back selection
always @(*) begin
    case(wb_sel)
        // dmemory
        2'd0 : wb_data_out = m_data_out;
        // ALU
        2'd1 : wb_data_out = alu_out;
        // PC+4
        default : wb_data_out = pc_4;
    endcase
end

endmodule