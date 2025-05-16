// DO NOT rely on this file, it will be changed with a fresh one
`include "signals.h"

module top(
  input wire reset,
  input wire clock,
  output wire[31:0] F_PC,
  output wire[31:0] F_INSN,
  output wire[31:0] W_PC,
  output wire       W_ENABLE,
  output wire[4:0]  W_DESTINATION,
  output wire[31:0] W_DATA
);
design_wrapper dut(
  .clock(clock),
  .reset(reset)
);
assign F_PC   = dut.core.`F_PC;
assign F_INSN = dut.core.`F_INSN;

assign W_PC          = dut.core.`W_PC;
assign W_ENABLE      = dut.core.`W_ENABLE;
assign W_DESTINATION = dut.core.`W_DESTINATION;
assign W_DATA        = dut.core.`W_DATA;
endmodule
