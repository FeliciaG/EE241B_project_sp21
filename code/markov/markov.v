`timescale 1ns/1ps
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

reg [3:0] state;
reg [3:0] next_state;

assign bit_out = bit_in;
assign lane = state;

always @(*) begin
    next_state ={state[2:0], bit_in};
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
	input clk,
	input reset,
	input [5:0] valid,
	input [5:0] bits,
	
	output out_valid,
	output [15:0] out_16
);
	reg [15:0] register;
	reg [3:0] counter;
	wire [3:0] counter_wire;
		
	integer i;
	reg ones;
	always @(posedge clk) begin
		ones = 0;
		for(i=0; i<6; i=i+1) begin
			if (valid[i] & (counter+ones)<15) begin
				register[counter+ones+1] <= bits[i];
				ones = ones + 1;
			end
		end
		counter <= counter_wire;
	end
	assign counter_wire = (counter == 15) ? 0 : (counter + ones);
	assign out_16 = register;
	assign out_valid = (counter == 15);

endmodule

module lfsr16(
    input clk,
    input reset,
    input [15:0] in_bits,
    output out_bit    
);
    reg [15:0] register;
    wire xor_bit;
    assign out_bit = register[0];
    assign xor_bit = ((register[15] ^ register[13]) ^ register[12]) ^ register[10];
    always @(posedge clk) begin
        if (reset) begin
            register <= in_bits;
        end else begin
            register <= {register[15:1] };
        end
    end
endmodule
