# ALU

The combinational ALU decodes the instruction supplied by the CPU and produces either a new accumulator value, a jump request, or a halt request. It does not store state; the top-level CPU decides when to write the result and update its state.

![ALU block diagram](./images/ALU.svg)

## Interface

- `i_instr[7:0]`: instruction currently being decoded.
- `i_acc[15:0]`: current accumulator value.
- `o_acc[15:0]`: computed accumulator value. For instructions that do not write the accumulator, this remains equal to `i_acc`.
- `o_acc_wr`: high for `LOAD`, `ADD`, `SUB`, `SHL`, and `XOR`; low for control-flow instructions.
- `o_jump_en`: high for `JUMP`, and for `JUMPZ` when the accumulator is zero.
- `o_jump_addr[2:0]`: low three bits of the instruction immediate, used as the jump target.
- `o_halted`: high for `HALT`.

## Operation

The instruction's upper three bits select an operation, and its lower five bits contain an immediate value or address. `LOAD` zero-extends the immediate into the accumulator. `ADD` and `SUB` use 16-bit unsigned arithmetic, so overflow and underflow wrap modulo 65536. `SHL` shifts left by the immediate's low three bits; the upper two immediate bits do not affect the shift. `XOR` zero-extends the immediate before applying XOR.

`JUMP` always requests a jump. `JUMPZ` requests one only when `i_acc` is exactly zero. Both instructions use the immediate's low three bits as the destination. `HALT` requests that the CPU set its halted state; the ALU itself does not remember that request.

All outputs receive defaults on every combinational evaluation, avoiding inferred latches. See the [TCPU-16 documentation](./README.md) for the complete instruction set and CPU timing.
