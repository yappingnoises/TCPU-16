# Program memory

`prog_mem` is a parameterized array of instruction words. In the top-level CPU it is configured as eight words of eight bits each. Writes occur on rising clock edges; reads are combinational and reflect the word selected by `i_read_addr`.

![Program memory block diagram](./images/prog_mem.svg)

## Parameters

- `WIDTH` (default 8): number of bits in each stored word.
- `WORD_SIZE` (default 8): number of words in the array.

## Interface

- `clk`: write clock.
- `i_write_en`: enables a write at the rising edge.
- `i_write_addr[2:0]`: address of the word to write.
- `i_read_addr[2:0]`: address of the word to read.
- `i_write_data[WIDTH-1:0]`: data stored when a write is enabled.
- `o_read_data[WIDTH-1:0]`: combinational output for the selected read address.

The memory has no reset or initialization in this RTL. Until a location is written, its simulation value is unknown. The address ports are fixed at three bits even when the parameters are changed, so the top-level configuration is the intended eight-location use. See [program loading](./README.md#loading-a-program).
