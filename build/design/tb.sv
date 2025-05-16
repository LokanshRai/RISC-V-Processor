module tb;

	logic clk = 0;
	logic rst = 1;

  logic        MEM_tvalid;
  logic        MEM_tlast;
  logic[63:0]  MEM_tdata;
  logic        TRACE_tvalid;
  logic[127:0] TRACE_tdata;
  logic        TRACE_tlast;

  logic         W_ENABLE;
  logic[4:0]    W_DESTINATION;
  logic[31:0]   W_DATA;
  logic[31:0]   W_PC;

  assign {W_ENABLE, W_DESTINATION, W_DATA, W_PC} = TRACE_tdata;

	overlay_top_design_0 inst (
		.clk          (clk),
		.rst          (rst),
		.MEM_tdata    (MEM_tdata),
		.MEM_tvalid   (MEM_tvalid),
		.MEM_tlast    (MEM_tlast),
		.TRACE_tready (1),
    .TRACE_tvalid (TRACE_tvalid),
    .TRACE_tdata  (TRACE_tdata),
    .TRACE_tlast  (TRACE_tlast)
	);

  logic[31:0] memory[0:`MEM_DEPTH / 4 - 1];

	initial begin
    $readmemh(`MEM_PATH, memory);
		forever clk = #1 clk ^ 1;
	end

  logic[31:0] counter = 32'h01000000;
  logic glbl_ready = 0;
  assign MEM_tlast = counter == (`LINE_COUNT - 1) * 4 + 32'h01000000;
  always @(posedge clk) begin
    MEM_tvalid <= 0;
    if(glbl_ready) begin
      if(counter < `LINE_COUNT * 4 + 32'h01000000) begin
        MEM_tvalid <= 1;
        MEM_tdata  <= {memory[(counter - 32'h01000000) >> 2], counter};
        counter <= counter + 32'h4;
      end else begin
        MEM_tvalid <= 0;
        rst <= 0;
      end
    end
    if(MEM_tlast) begin
      $display("Final transfer at %x", counter);
    end
  end


  always @(posedge clk) begin
  end

  // initial begin
  //   __trace_fd = $fopen(`TRACE_FILE, "w");
  // end

	initial begin
		$display("Simulation started.");
    glbl_ready = 0;
    #200ns;
    glbl_ready = 1;
	end

  always @(posedge clk) begin
    // W stage trace dump
    if(TRACE_tvalid) begin
      // $fwrite(__trace_fd, "[W] %x %x %x %x\n",
      $display("[W] %x %x %x %x",
        W_PC,
        W_ENABLE,
        W_DESTINATION,
        W_DATA);
    end
  end

endmodule
