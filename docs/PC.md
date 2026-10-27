# Program counter (PC)

The PC module stores a 3-bit address. On each enabled rising clock edge it either loads a requested jump target or increments by one. The 3-bit value wraps from address 7 back to address 0.

![PC block diagram](./images/PC.svg)

## Interface

- `clk`: clock for the PC register.
- `rst_n`: active-low synchronous reset. When low at a rising edge, the PC is cleared to zero.
- `i_en`: update enable. When low, the stored PC is held.
- `i_jump_en`: selects a jump when `i_en` is high.
- `i_jump_addr[2:0]`: address loaded when both `i_en` and `i_jump_en` are high.
- `o_pc[2:0]`: current registered address.

Reset has priority over the enable. With the enable high, a jump takes priority over incrementing. The top-level CPU contains another PC register that addresses program memory and copies this module's output; they update independently on the same edge. This produces a cycle of address delay and affects jump timing. See the [PC timing note](./README.md#pc-timing-note) for details.
