module decode (
    input  [7:0]  instr,
    input  [15:0] acc,
    output [2:0]  alu_sel,
    output [15:0] imm,
    output [2:0]  shamt,
    output [2:0]  target,
    output [1:0]  pc_sel,
    output        acc_wr,
    output        halt_en
);

wire [2:0] opcode = instr[7:5];

assign alu_sel = opcode;
assign imm     = {11'b0, instr[4:0]};
assign shamt   = instr[2:0];
assign target  = instr[2:0];
assign acc_wr  = (opcode <= 3'b100);
assign halt_en = (opcode == 3'b111);

wire acc_zero = (acc == 16'h0000);

// pc_sel: 2'b00 = PC+1, 2'b01 = target, 2'b10 = hold
assign pc_sel = halt_en                          ? 2'b10 :
                (opcode == 3'b101)               ? 2'b01 :
                (opcode == 3'b110 && acc_zero)   ? 2'b01 :
                                                   2'b00;

endmodule

