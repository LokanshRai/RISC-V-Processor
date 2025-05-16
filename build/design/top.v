module top(
    input wire clk,
    input wire rst,
    output wire [127:0] TRACE_tdata,
    output wire TRACE_tvalid,
    input wire TRACE_tready,
    output wire TRACE_tlast,
    input wire[63:0] MEM_tdata,
    input wire MEM_tvalid,
    output wire MEM_tready,
    input wire MEM_tlast
);
  (* gated_clock = "yes" *) wire gated_clock;
  reg[3:0] clock_started;
  reg[127:0] skid_buffer;
  reg        filled;
  reg        tready_reg;
  localparam TRACE_CAP = 10240;
  reg[31:0] trace_cap = 0;
  (* dont_touch = "true" *) wire[31:0] waddr = MEM_tdata[31:0];
  (* dont_touch = "true" *) wire[31:0] wdata = MEM_tdata[63:32];
  wire read_write_2;
  (* mark_debug = "true" *) reg rst_reg;
  assign read_write_2 = MEM_tvalid;
  assign gated_clock = clock_started[2] && clk;
  design_wrapper dut(
    .clock(gated_clock),
    .reset(rst)
  );

  always @(posedge clk) begin
    rst_reg <= !rst;
    // the MEM and TRACE should not be asserted at the same cycle
    if(rst) begin
      trace_cap <= TRACE_CAP;
      clock_started <= 4'b1111;
    end else begin
      if(TRACE_tvalid && TRACE_tready && trace_cap > 0) begin
        trace_cap <= trace_cap - 32'h1;
      end
      if(TRACE_tready == 0) begin
        clock_started <= 0;
      end else begin
        clock_started <= (clock_started << 1) | 1;
      end
      tready_reg <= TRACE_tready;
    end
  end

  always @(posedge clk) begin
    if(TRACE_tvalid && !TRACE_tready) begin
      skid_buffer <={dut.core.`W_ENABLE, dut.core.`W_DESTINATION, dut.core.`W_DATA, dut.core.`W_PC};
      filled <= 1;
    end else if(filled && TRACE_tready && TRACE_tvalid) begin
      filled <= 0;
    end
  end

  assign TRACE_tdata = filled ? skid_buffer : {dut.core.`W_ENABLE, dut.core.`W_DESTINATION, dut.core.`W_DATA, dut.core.`W_PC};
  assign TRACE_tvalid = rst_reg && trace_cap != 0 && clock_started[0] ;
  assign TRACE_tlast = trace_cap == 1;
  assign MEM_tready = 1;

  assign dut.core.`IMEMORY.address_2    = waddr;
  assign dut.core.`IMEMORY.data_in_2    = wdata;
  assign dut.core.`IMEMORY.read_write_2 = read_write_2;
  assign dut.core.`DMEMORY.address_2    = waddr;
  assign dut.core.`DMEMORY.data_in_2    = wdata;
  assign dut.core.`DMEMORY.read_write_2 = read_write_2;

  // Uncomment the following code for hardware probes
  // (* mark_debug = "true" *) wire[31:0] F_PC;   assign F_PC = dut.core.`W_PC;

endmodule
