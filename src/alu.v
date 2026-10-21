module alu (
    input      [2:0]  alu_sel,
    input      [15:0] acc,
    input      [15:0] imm,
    input      [2:0]  shamt,
    output reg [15:0] acc_n
);

always @(*) begin
    case (alu_sel)
        3'b000:  acc_n = imm;
        3'b001:  acc_n = acc + imm;
        3'b010:  acc_n = acc - imm;
        3'b011:  acc_n = acc << shamt;
        3'b100:  acc_n = acc ^ imm;
        default: acc_n = acc;
    endcase
end

endmodule

