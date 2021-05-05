module bbs_top #(parameter W=16, m=253)(    
    input clk,
    input reset,
    input [W-1:0] seed,
    input reseed,
    output out_bit,
    output out_valid,
    // for debugging
    output [W-1:0] out);

    wire gcd_rdy;
    wire res_valid;
    wire seed_valid;
    wire [W-1:0] mm_out;
    wire wen;
    wire store_seed;
    reg [W-1:0] out_reg;
    reg [W-1:0] x_val;

    assign out = out_reg;
    assign out_bit = out_reg[0];
    always@(posedge clk) begin
        if (reset) begin
            out_reg <= 0;
        end else begin
            if (store_seed) begin
                out_reg <= seed;
            end else begin
                out_reg <= wen? mm_out : out_reg;
            end
        end
    end

    seed_val#(W) seed_v(
        .clk(clk), .reset(reset), .seed(seed), .m(m),
        .gcd_rdy(gcd_rdy), 
        // .test_out(test_out),
        .result_valid(res_valid), .seed_valid(seed_valid)
    );

    montgomery_mult#(.W(W), .m(m)) mm(
        .clk(clk), .reset(reset), .x_val(out_reg), .out(mm_out)
    );

    bbs_ctrl ctrl(
        .clk(clk), .reset(reset), .out_valid(out_valid), .reseed(reseed),
        .seed_val(seed_valid && res_valid), .gcd_rdy(gcd_rdy),
        .wen(wen),  .store_seed(store_seed)
    );

endmodule

module bbs_ctrl(
    input clk,
    input reset,
    input seed_val,
    input gcd_rdy,
    input reseed,
    output out_valid,
    output reg wen,
    output reg store_seed
);

parameter IDLE = 2'd0; //00
parameter SEED = 2'd1; //01
parameter MM = 2'd2;
parameter RESEED = 2'd3;
// parameter MM_EX = 2'd2; //10
// parameter MM_DONE = 2'd3; //11

assign out_valid = state == MM || state == RESEED;
reg  [1:0] state;
reg  [1:0] next_state;

always @(*) begin
    case (state)
    IDLE: begin
        if (gcd_rdy) begin
            next_state = SEED;
        end else begin
            next_state = IDLE;
        end
        wen = 1'b0;
        store_seed = 1'b0;
    end

    SEED:begin
        if (seed_val) begin
            next_state = MM;
        end else begin
            next_state = SEED;
        end
        wen = 1'b0;
        store_seed = 1'b1;
    end

    MM:begin
        wen = 1'b1;
        store_seed = 1'b0;
        if (reset) begin
            next_state = IDLE;
        end else if (reseed) begin
            next_state = RESEED;
        end else begin
            next_state = MM;
        end
    end

    RESEED:begin
        if (seed_val) begin
            next_state = MM;
            store_seed = 1'b1;
        end else begin
            next_state = RESEED;
            store_seed = 1'b0;
        end
        wen = 1'b1;
    end
    endcase
end

always@(posedge clk) begin
    if (reset) begin
        state <= IDLE;
    end else begin
        state <= next_state;
    end
end
endmodule

module montgomery_mult #(parameter W=16, m=253)(
    input clk,
    input [W-1:0] x_val,
    input reset,
    output [W-1:0] out
);
    wire [31:0] extended_x = {16'b0, x_val};
    assign out = (extended_x * extended_x) % m;

endmodule

module seed_val #(parameter W=16)(    
    input clk,
    input reset,
    input [W-1:0] seed,
    input [W-1:0] m,

    // output [W-1:0] test_out,
    output gcd_rdy,
    output result_valid,
    output seed_valid);

    wire [W-1:0] gcd_result;
    wire result_val;
    gcdGCDUnit_rtl#(W) gcd( 
    .clk              (clk),
    .reset            (reset),

    .operands_bits_A  (seed),
    .operands_bits_B  (m),  
    .operands_val     (1'b1),
    .operands_rdy     (gcd_rdy),

    .result_bits_data (gcd_result), 
    .result_val       (result_val),
    .result_rdy       (1'b1)
    );
    assign result_valid = result_val;
    assign test_out =  gcd_result; 
    assign seed_valid = gcd_result == 1? 1'b1:1'b0;
endmodule