# Instruction register (IR)

The IR is an 8-bit, positive-edge-triggered instruction snapshot. It is intended for visibility and debugging; the CPU's ALU decodes the live program-memory output directly rather than using this register.

![IR block diagram](./images/IR.svg)

## Interface

- `clk`: clock for the register.
- `rst_n`: active-low synchronous reset. When low at a rising edge, the stored instruction is cleared to `8'h00`.
- `i_instr[7:0]`: instruction value to capture.
- `i_execute`: capture enable. When high at a rising edge and reset is inactive, `i_instr` is stored; otherwise the current value is held.
- `o_ir[7:0]`: stored instruction.

The reset has priority over the capture enable. The IR has no independent decode or execution behavior. See the [TCPU-16 documentation](./README.md) for its role in the complete CPU.
