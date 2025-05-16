module memory
(
    input wire clock,
    input wire read_write,
    input wire [31:0] address,
    input wire [31:0] data_in,
    input wire is_unsigned,
    input wire [1:0] access_size,
    output reg [31:0] mem_data_out,
    input wire WMSelBypass,
    input wire [31:0] w_data_out,
    output wire [31:0] bypass_data
);

wire [31:0] raw_data_out;

reg is_unsigned_delayed = 0;
reg [1:0] access_size_delayed = 0;
reg read_write_delayed = 0;

// W/M Bypass Mux
assign bypass_data = (WMSelBypass == 1) ? w_data_out : data_in;

// Calculate delayed signals
always @(posedge clock) begin
    is_unsigned_delayed <= is_unsigned;
    access_size_delayed <= access_size;
    read_write_delayed <= read_write;
end

// dmemory read correct access size
always @(*) begin
    if (read_write_delayed)
        // Probabily don't need to check for read_write
        mem_data_out = 32'd0;
    else begin
        case(access_size_delayed)
            // Byte
            2'd0 : begin
                if (is_unsigned_delayed) begin
                    mem_data_out = {{24{1'b0}},
                                    raw_data_out[7:0]};
                end else begin
                    mem_data_out = {{24{raw_data_out[7]}},
                                    raw_data_out[7:0]};
                end
            end
            // Half-word
            2'd1 : begin
                if (is_unsigned_delayed) begin
                    mem_data_out = {{16{1'b0}},
                                    raw_data_out[15:0]};
                end else begin
                    mem_data_out = {{16{raw_data_out[15]}},
                                    raw_data_out[15:0]};
                end
            end 
            // Word
            2'd2 : mem_data_out = raw_data_out;
            default : mem_data_out = 32'd0;
        endcase
    end
end

dmemory dmemory1(
    .clock(clock),
    .read_write(read_write),
    .address(address),
    .access_size(access_size),
    .data_in(bypass_data),
    .data_out(raw_data_out)
);

endmodule