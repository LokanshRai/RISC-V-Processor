module register_file
(
    input wire clock,
    input wire [4:0] addr_rs1,
    input wire [4:0] addr_rs2,
    input wire [4:0] addr_rd,
    input wire [31:0] data_rd,
    output reg [31:0] data_rs1,
    output reg [31:0] data_rs2,
    input wire write_enable
);

integer i;
(* ram_style = "block" *) reg [31:0] reg_data [0:31];

initial begin
    for (i = 0; i < 32; i = i + 1) begin
        reg_data[i] = 0;
    end
    reg_data[2] = `ADDR_START + `MEM_DEPTH;
end

always @(posedge clock) begin
    data_rs1 <= reg_data[addr_rs1];
    data_rs2 <= reg_data[addr_rs2];

    if (write_enable) begin
        if (addr_rd != 0) 
            reg_data[addr_rd] <= data_rd;
    end
end

endmodule
