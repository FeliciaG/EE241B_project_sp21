`timescale 1ns/1ps

module trng_tester();
    reg clk;
    reg reset;
    reg [5:0] valid;
    reg [5:0] bits;

    wire out_valid;
    wire out;
    initial clk = 0;
    initial reset =0;
    always #(10) clk <= ~clk;


    trng dut(
		.clk(clk),
		.reset(reset),
		.latch_bit,
		.out_valid(out_valid)
		.out(out)
	);

    initial begin
        $dumpfile("trng_test.vcd");
        $dumpvars(0, dut);
        $display("start sim");
        @(posedge clk);
        reset = 1;
		#1;
        @(posedge clk) begin
			reset = 0;
            bits = 6'b0;
            valid = 6'b0;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);

        @(posedge clk) begin
            bits =  6'b111111;
            valid = 6'b011111;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b, writing: %b", bits, out_valid, out, writing);

        @(posedge clk) begin
            bits =  6'b010001;
            valid = 6'b100111;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);

        @(posedge clk) begin
            bits =  6'b010101;
            valid = 6'b110111;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);
		
		@(posedge clk) begin
            bits =  6'b110101;
            valid = 6'b110111;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);
        
        @(posedge clk) begin
            bits =  6'b110101;
            valid = 6'b100110;
        end
        #1;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);
        #20;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);
        #20;
        $display("in: %b, out_valid: %b, out: %b", bits, out_valid, out);
        #20 $finish();
    end

endmodule
