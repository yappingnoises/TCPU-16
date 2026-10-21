module prog_mem (
    input        clk,
    input        write_en,
    input  [2:0] write_addr,
    input  [7:0] write_data,
    input  [2:0] read_addr,
    output [7:0] instr
);

reg [7:0] mem [0:7];

assign instr = mem[read_addr];

always @(posedge clk)
    if (write_en)
        mem[write_addr] <= write_data;

endmodule

