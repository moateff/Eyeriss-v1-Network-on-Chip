module GIN_MCC #(
    parameter int DATA_WIDTH = 64, 
    parameter int TAG_WIDTH = 4
) (
    input logic [DATA_WIDTH-1:0] data_in,
    input logic [TAG_WIDTH-1:0] tag,
    input logic ready_in, link_clk, reset, enable_in,
    input logic se_id, si_id,

    output logic [DATA_WIDTH-1:0] data_out,
    output logic ready_out, enable_out,
    output logic so_id
);

    // Internal signals
    logic equal_tag, enable_mid;
    logic [TAG_WIDTH-1:0] q_id;
    
    // Combinational logic
    assign equal_tag = (q_id == tag);
    assign ready_out = ready_in | (!equal_tag);
    assign enable_mid = enable_in & ready_in & equal_tag;
    assign enable_out = enable_mid;
    assign data_out = enable_mid ? data_in : {DATA_WIDTH{1'b0}};
    
    lp_configure_dff_Nbits #(.N(TAG_WIDTH)) u_lp_configure_dff_Nbits (
        .clk(link_clk),
        .reset(reset),
        .se(se_id),
        .si(si_id),
        .q(q_id),
        .so(so_id)
    );

endmodule