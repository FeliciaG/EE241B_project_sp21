`timescale 1ns/1ps
`define NULL 0

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
	
	reg latch_bit;
    trng dut(
		.clk(clk),
		.reset(reset),
		.latch_bit(latch_bit),
		.out_valid(out_valid),
		.out(out)
	);
	
	
	wire done = 0;
	integer data_file;
	integer scan_file;
    initial begin
        $dumpfile("trng_test1.vcd");
        $dumpvars(0, dut);
        
		data_file = $fopen("out_10ms770mv.txt", "r");
		if (data_file == `NULL) begin
			$display("data_file handle was NULL");
			$finish;
		end
		@(posedge clk);
		reset = 1;
		@(posedge clk);
		reset = 0;
		fork
			begin
				repeat (2500) @(posedge clk);
				if (!done) begin
					$display("Failure: Timing out after 10000 cycles");
					$finish();
				end
			end
		join
		
		$finish;
	end
    
    
	reg [31:0]counter;
    always @(posedge clk) begin
        counter <= counter + 1;
        scan_file = $fscanf(data_file, "%d\n", latch_bit);
        if (scan_file == 0) $finish;
        if (out_valid) begin
            $display("%b", out);
            // $display("%d", test_out);
            // $display("step: %d, out_valid: %d, out: %d, 1out_bit: %d ", counter, out_valid, test_out, out_bit);
        end
    end
       
   
endmodule
