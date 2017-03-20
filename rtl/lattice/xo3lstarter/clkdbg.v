module clkdbg (
	input wire clk_12m,
	output wire clk_dbg
);

assign clk_dbg = clk_12m;

endmodule