`timescale 1ns/1ns

// 2018 Sean 'furrtek' Gonsalves

module zmc2_dot(
	input CLK_12M,
	input EVEN,
	input LOAD,
	input H,
	input [31:0] CR,
	output reg [3:0] GAD, GBD,
	output reg DOTA, DOTB
);

	reg [31:0] SR;

	always @(negedge CLK_12M)
	begin
		if (LOAD) SR <= CR;
		else if (H) SR <= {SR[29:24], 2'b00, SR[21:16], 2'b00, SR[13:8], 2'b00, SR[5:0], 2'b00};
		else SR <= {2'b00, SR[31:26], 2'b00, SR[23:18], 2'b00, SR[15:10], 2'b00, SR[7:2]};
	end
	
	// Load:			FEDCBA98 76543210 FEDCBA98 76543210
	// Shift H=0:	--FEDCBA --765432 --FEDCBA --765432 --> Two pixels right
	// Shift H=1:  DCBA98-- 543210-- DCBA98-- 543210-- <-- Two pixels left

	always @*
	begin
		case ({EVEN, H})
			3: {GBD, GAD} <= {SR[31], SR[23], SR[15], SR[7], SR[30], SR[22], SR[14], SR[6]};
			2: {GBD, GAD} <= {SR[24], SR[16],  SR[8], SR[0], SR[25], SR[17],  SR[9], SR[1]};
			1: {GBD, GAD} <= {SR[30], SR[22], SR[14], SR[6], SR[31], SR[23], SR[15], SR[7]};
			0: {GBD, GAD} <= {SR[25], SR[17],  SR[9], SR[1], SR[24], SR[16],  SR[8], SR[0]};
		endcase
		
		{DOTA, DOTB} <= {|GAD, |GBD};
	end
	
	// EVEN H  FEDCBA98 76543210 FEDCBA98 76543210
	//   0  0        BA       BA       BA       BA	Reverse shift, X is even
	//   0  1  AB       AB       AB       AB			Normal shift, X is even
	//   1  0        AB       AB       AB       AB	Reverse shift, X is odd
	//   1  1  BA       BA       BA       BA			Normal shift, X is odd
	
endmodule
