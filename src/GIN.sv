module GIN #(
    parameter int DATA_WIDTH = 64, 
    parameter int ROW_TAG_WIDTH = 4,
    parameter int COL_TAG_WIDTH = 4,
    parameter int NUM_OF_ROWS = 12,
    parameter int NUM_OF_COLS = 14
) (
    input logic link_clk, reset, enable_in,
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [ROW_TAG_WIDTH-1:0] row_tag,
    input logic [COL_TAG_WIDTH-1:0] col_tag,
    
    // 2D Arrays
    //input logic [ROW_TAG_WIDTH-1:0] id_row [0:NUM_OF_ROWS-1],                
    //input logic [COL_TAG_WIDTH-1:0] id_col [0:NUM_OF_ROWS-1][0:NUM_OF_COLS-1], 
    input logic [0:NUM_OF_COLS-1] ready_in [0:NUM_OF_ROWS-1],
    
    input logic se_id, si_id,

    // 2D Outputs
    output logic [DATA_WIDTH-1:0] data_out [0:NUM_OF_ROWS-1][0:NUM_OF_COLS-1],
    output logic [0:NUM_OF_COLS-1] enable_out [0:NUM_OF_ROWS-1], // 2D Enable Signal
    output logic ready_out,
    output logic so_id
);

    // Internal Signals
    logic [DATA_WIDTH-1:0] row_data_out [0:NUM_OF_ROWS-1];
    logic row_enable_out [0:NUM_OF_ROWS-1];
    logic internal_ready [0:NUM_OF_ROWS-1];
    logic [0:NUM_OF_ROWS-1] mcc_ready ;
    logic [0:NUM_OF_COLS-1] xbuses_ready [0:NUM_OF_ROWS-1];
    
    logic [0 : NUM_OF_ROWS*2] soi;
    assign soi[0] = si_id;
    assign so_id = soi[NUM_OF_ROWS*2];
    
    assign  ready_out = & mcc_ready;
    
    // Generate MCC & X_Bus instances
    genvar i;
    generate
        for (i = 0; i < NUM_OF_ROWS; i = i + 1) begin : ROW_MCC_XBUS
    
            assign internal_ready[i] = &xbuses_ready[i];  // ANDing to make sure all row PEs are ready to recieve data
            // MCC instance for row selection
            MCC #( 
                .DATA_WIDTH(DATA_WIDTH),
                .TAG_WIDTH(ROW_TAG_WIDTH)
            ) mcc_inst (
                .data_in(data_in),
                .tag(row_tag),
                .link_clk(link_clk),
                .reset(reset),
                .ready_in(internal_ready[i]),
                .enable_in(enable_in),
                .se_id(se_id),//
                .si_id(soi[i+i]),//
                .ready_out(mcc_ready[i]),
                .enable_out(row_enable_out[i]),
                .data_out(row_data_out[i]),
                .so_id(soi[i+i+1])//
            );
    
            // X_Bus instance for column selection
            X_Bus #( 
                .DATA_WIDTH(DATA_WIDTH),
                .COL_TAG_WIDTH(COL_TAG_WIDTH),
                .NUM_OF_COLS(NUM_OF_COLS)
            ) xbus_inst (
                .data_in(row_data_out[i]),
                .col_tag(col_tag), 
                .ready_in(ready_in[i]),
                .link_clk(link_clk),
                .reset(reset),
                .enable_in(row_enable_out[i]),
                .se_id(se_id),//
                .si_id(soi[i+i+1]),//
                .data_out(data_out[i]),  // Outputs the entire row
                .ready_out(xbuses_ready[i]),
                .enable_out(enable_out[i]),  // Outputs the entire row's enable signals
                .so_id(soi[i+i+2])//
            );
        end
    endgenerate

endmodule