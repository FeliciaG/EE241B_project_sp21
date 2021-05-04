module bbs #(parameter W=16, m=253)(    
    input clk,
    input reset,
    input [W-1:0] seed,

    output [W-1:0] out);

    wire gcd_rdy;
    wire res_valid;
    wire seed_valid;
    wire mm_start;
    wire mm_done;
    wire [W-1:0] mm_out;
    wire wen;
    wire store_seed;
    reg [W-1:0] out;
    reg [W-1:0] x_val;

    always@(posedge clk) begin
        if (reset) begin
            out <= 0;
        end else begin
            if (store_seed) begin
                out <= seed;
            end else begin
                out <= wen? mm_out : out;
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
        .clk(clk), .reset(reset), .x_val(out), .start(mm_start),
        .done(mm_done), .out(mm_out)
    );

    bbs_ctrl ctrl(
        .clk(clk), .reset(reset), .mm_done(mm_done),
        .seed_val(seed_valid && res_valid), .gcd_rdy(gcd_rdy),
        .wen(wen), .mm_start(mm_start), .store_seed(store_seed)
    );

endmodule

module bbs_ctrl(
    input clk,
    input reset,
    input mm_done,
    input seed_val,
    input gcd_rdy,

    output reg wen,
    output reg mm_start, 
    output reg store_seed
);

parameter IDLE = 2'd0; //00
parameter SEED = 2'd1; //01
parameter MM_EX = 2'd2; //10
parameter MM_DONE = 2'd3; //11

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
        mm_start = 1'b0;
        store_seed = 1'b0;
    end

    SEED:begin
        if (seed_val) begin
            next_state = MM_EX;
        end else begin
            next_state = SEED;
        end
        wen = 1'b0;
        mm_start = 1'b0;
        store_seed = 1'b1;
    end

    MM_EX:begin
        mm_start = 1'b1;
        store_seed = 1'b0;
        if (mm_done) begin
            wen = 1'b1;
            next_state = MM_DONE;
        end else begin
            wen = 1'b0;
            next_state = MM_EX;
        end
    end

    MM_DONE: begin
        store_seed = 1'b0;
        wen = 1'b0;
        next_state = MM_EX;
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
    input start,
    output done,
    output [W-1:0] out
);
    assign out = x_val * x_val % m;
    reg fake_done;
    always @(posedge clk) begin
        if (reset) begin
            fake_done = 1'b0;
        end else begin
            fake_done = ~fake_done;
        end
    end
    assign done = fake_done;

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