# TCPU-16 Documentation

This documentation describes the behavior implemented by the Verilog in [`src/`](../src/). It covers the top-level interface, the instruction set, the datapath and control flow, and details that matter when loading or running a program.

## What the design contains

TCPU-16 is a small, single-accumulator processor. Instructions are 8 bits wide, the accumulator is 16 bits wide, and the program memory has eight 8-bit locations in the top-level configuration.

The top-level module, [`toy_cpu16`](../src/toy_cpu16.v), connects these modules:

| Module | Responsibility |
| --- | --- |
| [`prog_loader`](../src/prog_loader.v) | Turns a `prog_load` pulse into a program-memory write and advances the load address. |
| [`prog_mem`](../src/prog_mem.v) | Stores 8-bit instructions; writes are clocked and reads are combinational. |
| [`ALU`](../src/ALU.v) | Decodes the current instruction and computes an accumulator result, jump, or halt. |
| [`PC`](../src/PC.v) | Holds a 3-bit program counter and increments or loads a jump address when enabled. |
| [`IR`](../src/IR.v) | Captures the current instruction during execution for visibility/debugging. |

The [top-level block diagram](./images/toy_cpu16.svg) and [module notes](./toy_cpu16.md) provide additional views.

## Top-level interface

| Port | Direction | Meaning |
| --- | --- | --- |
| `clk` | input | Clock for the sequential state. |
| `rst_n` | input | Active-low, synchronous reset for the CPU, PC, IR, and loader address counter. |
| `prog_data[7:0]` | input | Instruction byte to write when the loader asserts its write enable. |
| `prog_load` | input | A sampled high pulse requests one program-memory write. |
| `run` | input | Enables execution while high, unless the CPU has halted. |
| `byte_sel` | input | Selects which accumulator byte appears at `acc_out`. |
| `acc_out[7:0]` | output | `acc[7:0]` when `byte_sel` is low; `acc[15:8]` when it is high. |

There are no top-level outputs for the PC, full accumulator, instruction, or halted state. `acc_out` is only an 8-bit view of the 16-bit accumulator.

## Instruction set architecture

Each instruction is one byte. Its three most significant bits select the operation, and its five least significant bits hold that operation's immediate value or address. The ISA has eight operations, selected by opcode values from `000` through `111`.

Opcode `000` is **LOAD**. It replaces the accumulator with the unsigned immediate, zero-extended to 16 bits. Opcode `001` is **ADD**, which adds that zero-extended immediate to the accumulator. Opcode `010` is **SUB**, which subtracts it. These arithmetic operations keep only the low 16 result bits, so overflow and underflow wrap modulo 65536.

Opcode `011` is **SHL**. It shifts the accumulator left by the amount in the three least significant immediate bits; the two upper immediate bits are ignored. Opcode `100` is **XOR**, which bitwise-XORs the accumulator with the zero-extended immediate.

Opcode `101` is **JUMP** and always branches to the address in the three least significant immediate bits. Opcode `110` is **JUMPZ** and branches to that same three-bit address only if the accumulator is zero. Because program memory has eight words, a 3-bit jump address selects any location from 0 to 7. Opcode `111` is **HALT**; it sets the CPU's halted state, and its immediate bits have no effect.

For example, the byte `0x05` means `LOAD 5`, and `0xA3` means `JUMP 3`. The CPU has no carry, sign, or overflow flags.

## Execution and state

The program memory's read output is combinational and is addressed by the top-level `pc`. The ALU decodes that instruction directly; it does not use a previously captured instruction. On a rising edge where `execute = run & ~halted` is true, the top-level:

1. Copies the PC module's current value into its memory-address register.
2. Captures the current instruction in the top-level `ir` and the `IR` module's debug register.
3. Writes the ALU result to the accumulator if the instruction is an accumulator operation.
4. Updates the halted flag from the ALU's halt result.

The PC module advances or takes a jump on that same edge. When execution is disabled, these CPU registers hold their values. The `IR` module and top-level `ir` are not used by the ALU; both are instruction snapshots for visibility.

Reset is active-low and synchronous: the reset values take effect on a rising clock edge while `rst_n` is low. It sets the accumulator and both PC registers to zero, clears the instruction snapshots, and clears the halted flag. Program memory is not reset.

### PC timing note

There are two PC registers: the top-level `pc`, which addresses memory, and `current_pc` inside `PC`. The top-level copies the PC module's current registered output while that module independently updates its own register on the same edge. Consequently, these registers are not a single shared PC state: with continuous execution, instruction address 0 is presented for an extra execution edge initially. When a jump is taken, the PC module loads the target while the top-level captures the PC module's old value; the memory address changes to the target on a later edge, so an instruction from the sequential path can be executed before the target is presented. Keep this in mind when writing programs that depend on exact instruction timing.

## Loading a program

The loader uses `prog_load`, `i_run`, and its 3-bit address counter:

- A write is requested when `prog_load` is high, its previously sampled value was low, and `run` is low.
- The write uses the current load address and `prog_data`; the address counter increments on that clock edge.
- Holding `prog_load` high does not repeatedly write. Drive it low for at least one rising edge before pulsing it high for the next byte.
- The address counter resets to zero, but program memory contents do not. Loading fewer than eight bytes leaves the other locations unchanged or uninitialized.
- The counter is 3 bits, so after eight accepted pulses it wraps to address zero.

For reliable first use, apply reset and sample `prog_load` low on a rising edge before the first load pulse. The loader's edge-history register is not reset. Also, the write enable is not itself gated by reset; avoid requesting a load while resetting.

## Running and halting

After loading, deassert `prog_load` and assert `run`. Execution is enabled on each rising edge while `run` is high and the internal halted flag is clear. Deasserting `run` pauses the CPU; it does not reset the PC, accumulator, or halted state.

Executing `HALT` sets the internal halted flag. Since that flag gates `execute`, the CPU then remains halted even if `run` stays high. The flag is cleared only by reset; there is no separate resume or clear-halt input.

## Implementation limits and cautions

- The top-level instantiates an 8-word, 8-bit program memory. Both the load and execution addresses are 3 bits, so the implemented address space is eight locations.
- The memory has no initialization or reset. Reading a location before writing it produces an unknown value in simulation.
- The memory read is asynchronous (combinational), while writes occur on rising clock edges.
- `run` suppresses new execution but does not prevent program loading; loading is separately suppressed when `run` is high.
- `prog_load` is treated as a synchronous sampled signal, not as an asynchronous input handshake. Ensure it meets the clock's setup and hold requirements.
- The `prog_mem` module exposes `WIDTH` and `WORD_SIZE` parameters, but its address ports remain fixed at 3 bits. The top-level uses the default eight-word depth and 8-bit width.

## Module-specific pages

- [ALU](./ALU.md)
- [IR](./IR.md)
- [PC](./PC.md)
- [Program loader](./prog_loader.md)
- [Program memory](./prog_mem.md)
- [Top-level CPU](./toy_cpu16.md)
