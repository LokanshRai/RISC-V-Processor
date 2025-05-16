module fetch
(
    input wire reset,
    input wire clock,
    input wire PCSel,
    input wire [31:0] ALURes,
    input wire stall,
    output reg [31:0] pc,
    output wire [31:0] f_data_out
);

reg [31:0] f_data_in;
reg f_read_write = 0;
wire f_enable;

`define ADDR_START 32'h0100_0000

always @(posedge clock) begin
  if (reset) begin
    pc <= `ADDR_START;
  end else begin
    if (PCSel)
      pc <= ALURes;
    else if (!stall)
      pc <= pc + 4;
  end
end

assign f_enable = ~stall || reset;

imemory imem1(
  .clock(clock),
  .address(pc),
  .data_in(f_data_in),
  .data_out(f_data_out),
  .read_write(f_read_write),
  .enable(f_enable)
);

endmodule