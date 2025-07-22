module GIN_XBus #(
    parameter int DATA_WIDTH = 64, 
    parameter int COL_TAG_WIDTH = 4,
    parameter int NUM_OF_COLS = 14
) (
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [COL_TAG_WIDTH-1:0] col_tag,

    input logic [0:NUM_OF_COLS-1] ready_in,
    input logic link_clk, reset, enable_in,
    input logic se_id, si_id,

    output logic [DATA_WIDTH-1:0] data_out [0:NUM_OF_COLS-1],
    output logic [0:NUM_OF_COLS-1] enable_out, ready_out,
    output logic so_id
);

    wire [0 : NUM_OF_COLS] soi;
    assign soi[0] = si_id;
    assign so_id = soi[NUM_OF_COLS];
    
    // Generate MCC instances for each column
    genvar i;
    generate
        for (i = 0; i < NUM_OF_COLS; i = i + 1) begin : MCC_INSTANCE
            MCC #(
                .DATA_WIDTH(DATA_WIDTH),
                .TAG_WIDTH(COL_TAG_WIDTH)
            ) mcc_inst (
                .data_in(data_in),
                .tag(col_tag),
                .link_clk(link_clk),
                .reset(reset),
                .ready_in(ready_in[i]),
                .enable_in(enable_in),
                .se_id(se_id),//
                .si_id(soi[i]),//
                .ready_out(ready_out[i]),
                .enable_out(enable_out[i]),
                .data_out(data_out[i]),
                .so_id(soi[i+1])//
            );
        end
    endgenerate

endmodule