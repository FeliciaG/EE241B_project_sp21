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
	output [15:0] out_16,
	output [5:0] writing
);
	reg [20:0] register;
	reg [4:0] counter;
	wire [4:0] counter_wire;
	wire [4:0] counter_up;
	reg out_valid_reg;
	
	//count number of valid bits	
	reg [2:0] num_valid;
	reg [2:0] num_valid_n;
	reg [5:0] valid_bits;
	reg [5:0] write_bits;
	integer idx;
	always @* begin
		num_valid= {2{1'b0}};
		valid_bits = {5{1'b0}};
		for( idx = 0; idx<6; idx=idx+1) begin
			num_valid = num_valid + valid[idx];
			valid_bits[num_valid-1] = valid[idx] ?  bits[idx] : valid_bits[num_valid-1];
		end
		num_valid_n = 6-num_valid;
		write_bits = {{num_valid_n{1'b0}}, valid_bits}; 
	end
	assign  writing = write_bits;
	
	integer i;
	integer j;
	reg out_16_reg;
	always @(posedge clk) begin
		if (reset == 1) begin
			counter<=0;
			register <= 16'b0;
			out_valid_reg <= 0;
		end
		else if (counter_wire >= 15) begin
			counter <= (|valid) ? (counter_wire + num_valid -15): (counter_wire - 15);
			for (i=15; i<20; i=i+1) begin
				register[i-15] <= register[i+1];
			end
			for (j=0; j<num_valid; j=j+1) begin
				register[counter_wire - 15 + j] <= write_bits[j];
			end
			for (j = counter_wire + num_valid -15; j<21; j=j+1) begin
				register[j] <= 0;
			end
			out_valid_reg <= 0;
		end		
		else begin 		
			for (j=0; j<num_valid; j=j+1) begin
				register[counter_wire + j] <= write_bits[j];
			end
			counter <= (|valid) ? (counter_wire + num_valid) : counter;
			out_valid_reg <= ((|valid) & (counter_wire + num_valid) > 15) ? 1 : 0;
		end
	end
	assign counter_wire = reset? 0 :counter;
	assign counter_up = reset? 0 :counter+5;
	assign out_16 = reset ? 0 :register[15:0];
	assign out_valid = reset ? 0 :out_valid_reg;

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
            register <= {register[15:1], xor_bit };
        end
    end
endmodule
