import csv

clk_period = 4e-6;
delay = 2100e-9;

fileo = open(r"outputs_10ms700.txt", "w+")
time = delay
row_write = 0
linewrite = 0
with open('outputs/out_10ms700mv.csv') as csv_file:
	csv_reader = csv.reader(csv_file, delimiter=',')
	
	line_count = 0
	for row in csv_reader:
		if line_count == 0:
			line_count += 1
		else:
			while(time < float(row[0])):
				fileo.write(str(row_write))
				linewrite += 1
				time = time + clk_period
				if (linewrite == 24):
					fileo.write("\n")
					linewrite = 0
			row_write = int(row[1])
			line_count += 1
			
fileo.close()
			
	
			
