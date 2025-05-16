module branch_comparator
(
    input wire [31:0] dataA,
    input wire [31:0] dataB,
    input wire BrUn,
    output reg BrLT,
    output reg BrEq
);

always @(*)begin
    if (BrUn) begin //we preform a unsigned comparison
        BrEq = $unsigned(dataA) == $unsigned(dataB);
        BrLT = $unsigned(dataA) < $unsigned(dataB);
    end else begin //we preform a signed comparison
        BrEq = $signed(dataA) == $signed(dataB);
        BrLT = $signed(dataA) < $signed(dataB);
    end
end

endmodule