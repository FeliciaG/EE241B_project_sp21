module trng (
    input clk,
    input reset,

    output out
);
endmodule

module markov16(
    input clk,
    input reset,
    input bit_in,
    output [3:0] lane,
    output bit_out
);
assign bit_out = bit_in;
assign lane = state;
reg [3:0] state;
reg [3:0] next_state;
always @(*) begin
    next_state ={state[2:0], in};
end

always@(posedge clk) begin
    if (reset) begin
        state <= 4'b0;
        next_state <= 4'b0;
    end else begin
        state <= next_state;
    end
end
endmodule

module fifo16(

);

endmodule

module lfsr16(
    input clk,
    input reset,
    input [15:0] in_bits,
    output out_bit    
);
    reg [15:0] register;
    reg xor_bit;
    assign out_bit = register[0];
    assign xor_bit = ((register[15] ^ register[13]) ^ register[12]) ^ register[10];
    always @(posedge clk) begin
        if (reset) begin
            register <= in_bits;
        end else begin
            register <= {register[15:1], }
        end
    end
endmodule