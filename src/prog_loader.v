module prog_loader (
    input        clk,
    input        rst_n,
    input  [7:0] prog_data,
    input        prog_load,
    input        run,
    output       write_en,
    output [2:0] write_addr,
    output [7:0] write_data
);

reg       pl_q;
reg [2:0] load_addr;

always @(posedge clk)
    pl_q <= prog_load;

wire load_pulse = prog_load & ~pl_q & ~run;

always @(posedge clk)
    if (!rst_n)
        load_addr <= 3'b000;
    else if (load_pulse)
        load_addr <= load_addr + 1;

assign write_en   = load_pulse;
assign write_addr = load_addr;
assign write_data = prog_data;

endmodule
