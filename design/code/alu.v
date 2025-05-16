module alu
(
    input wire signed [31:0] A,
    input wire signed [31:0] B,
    input wire [3:0] ALUSel, 
    output reg [31:0] ans
);

always @(*) begin
    case(ALUSel)
        4'd1 : begin
            //SUB
            ans = A - B;
        end
        4'd2 : begin
            //SHIFT LEFT LOGICAL
            ans = A << B[4:0];
        end
        4'd3 : begin
            //SET LESS THAN
            ans = {{31{1'b0}}, A < B};
        end
        4'd4 : begin
            //SET LESS THAN UNSIGNED 
            ans = {{31{1'b0}}, $unsigned(A) < $unsigned(B)};
        end
        4'd5 : begin
            //XOR
            ans = A ^ B;
        end
        4'd6 : begin
            //ARTHEMETIC SHIFT RIGHT
            ans = A >>> B[4:0];
        end
        4'd7 : begin
            //LOGICAL SHIFT RIGHT
            ans = A >> B[4:0];
        end
        4'd8 : begin
            //OR
            ans = A | B;
        end
        4'd9 : begin
            //AND
            ans = A & B;
        end
        default : begin
            //ADD
            ans = A + B;
        end
    endcase
end

endmodule