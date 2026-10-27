# TCPU-16 top-level

`toy_cpu16` integrates the program loader, instruction memory, ALU, PC, and instruction snapshot register. It contains a 16-bit accumulator and a halted flag. Instructions are read from program memory and decoded by the ALU while `run` is asserted and the CPU is not halted.

![TCPU-16 block diagram](./images/toy_cpu16.svg)

## Interface

- `clk`: clock for CPU state, loader, PC, and memory writes.
- `rst_n`: active-low synchronous reset for the CPU state, PC state, instruction snapshots, and loader address.
- `prog_data[7:0]`: byte presented to program memory during a loader write.
- `prog_load`: requests a single write on a sampled rising edge while `run` is low.
- `run`: enables instruction execution unless the CPU has halted; also prevents program loading while high.
- `byte_sel`: chooses the visible accumulator byte.
- `acc_out[7:0]`: low accumulator byte when `byte_sel` is low, high byte when it is high.

## Operation

The loader writes instruction bytes to an 8-word memory. The top-level `pc` selects the memory read address, and the ALU decodes that instruction against the current accumulator. At an execution edge, an accumulator instruction updates the accumulator, a jump instruction controls the PC module, and `HALT` sets the halted flag. The accumulator is reset to zero; the program memory is not reset.

The internal top-level PC register and the PC module's register are distinct state elements, so their updates create delayed instruction addressing and jump behavior. The IR instances capture instruction snapshots for visibility; they are not in the ALU execution path.

## Module connections

- [`prog_loader`](./prog_loader.md) generates memory writes and write addresses.
- [`prog_mem`](./prog_mem.md) stores and supplies instruction bytes.
- [`ALU`](./ALU.md) decodes instructions and calculates results/control signals.
- [`PC`](./PC.md) maintains the jump/increment address.
- [`IR`](./IR.md) captures an instruction snapshot.

The [TCPU-16 documentation](./README.md) describes the instruction set, loading sequence, reset behavior, and timing considerations.
