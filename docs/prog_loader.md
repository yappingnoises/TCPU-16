# Program loader

The loader converts a sampled `i_prog_load` rising edge into a one-cycle memory write request and advances its 3-bit write address. It only accepts a load edge while the CPU's `i_run` input is low.

![Program loader block diagram](./images/prog_loader.svg)

## Interface

- `clk`: clock for the edge history and load-address counter.
- `rst_n`: active-low synchronous reset for the load-address counter. The edge-history register is not reset.
- `i_prog_load`: high requests a write only on a sampled low-to-high transition.
- `i_run`: suppresses the write request while high.
- `o_load_addr[2:0]`: current write address; this is the address used for an accepted load pulse.
- `o_write_en`: one-cycle write enable, asserted for an accepted pulse.

On an accepted edge, the program memory writes at the current address while the loader increments its address counter on the same rising edge. Holding `i_prog_load` high does not generate additional writes; it must be sampled low before it can create another rising-edge pulse. The address counter wraps after eight writes.

For predictable operation, reset the loader and ensure `i_prog_load` is sampled low before loading the first byte. Since the edge-history register is not reset and the write enable is not gated by reset, keep `i_prog_load` low during reset. See [loading a program](./README.md#loading-a-program).
