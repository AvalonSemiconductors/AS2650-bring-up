`default_nettype none
`timescale 1ns/100ps

module tb(
	input clk,
	input rst_n,
	
	input wbs_stb_i,
	input wbs_cyc_i,
	input wbs_we_i,
	input [31:0] wbs_dat_i,
	input [31:0] wbs_adr_i,
	output wbs_ack_o,
	output [31:0] wbs_dat_o
);

wire [37:0] io_in;
wire [37:0] io_out;
wire [37:0] io_oeb;

assign io_in[0] = rst_n;
assign io_in[4:1] = 4'h8;
assign io_in[28:13] = 0;
assign io_in[36:30] = 0;

wire ROM_CS = io_out[27];
wire SCLK = io_out[35];
wire SDO = io_out[36];
wire SDI;
assign io_in[37] = SDI;
wire flag = io_out[2];
wire OEb = io_out[15];
wire WEb = io_out[16];
wire IOD = io_out[17];
wire IOC = io_out[18];
wire [7:0] bus_out = io_out[12:5];

assign io_in[29] = SCLK;

reg [15:0] addr_latch = 0;

wire LE_LO = io_out[13];
wire LE_HI = io_out[14];

wire test;
assign #0.001 test = clk;

always @(negedge (LE_LO & test)) addr_latch[7:0] <= bus_out;
always @(negedge (LE_HI & test)) addr_latch[15:8] <= bus_out;

wire [15:0] curr_addr = {LE_HI ? bus_out : addr_latch[15:8], LE_LO ? bus_out : addr_latch[7:0]};

reg [7:0] RAM [65535:0];

assign io_in[12:5] = RAM[addr_latch] & {8{~OEb}} & io_oeb[12:5];

wire web_actual = (WEb | ~test);
always @(posedge web_actual) begin
	RAM[addr_latch] <= bus_out;
end

/*initial begin
		$display("Tracing...");
		$dumpfile("tb.vcd");
		$dumpvars(0, tb);
end*/

reg flag_edge = 0;
reg tracing = 0;
always @(posedge clk) begin
	flag_edge <= flag;
	if(!flag_edge && flag) begin
		if(tracing) begin
			$finish;
		end else begin
			tracing <= 1;
	`ifdef TRACE_ON
			$display("Tracing...");
			$dumpfile("tb.vcd");
			$dumpvars(0, tb);
	`endif
		end
	end
end


user_project_wrapper uprj(
	.wb_clk_i(clk),
	.wb_rst_i(!rst_n),
	.wbs_stb_i(wbs_stb_i),
	.wbs_cyc_i(wbs_cyc_i),
	.wbs_we_i(wbs_we_i),
	.wbs_sel_i(4'b0000),
	.wbs_dat_i(wbs_dat_i),
	.wbs_adr_i(wbs_adr_i),
	.wbs_ack_o(wbs_ack_o),
	.wbs_dat_o(wbs_dat_o),
	.la_data_in(64'h0000000000000000),
	.la_oenb(64'hFFFFFFFFFFFFFFFF),
	.io_in(io_in),
	.io_out(io_out),
	.io_oeb(io_oeb),
	.user_clock2(clk)
);

spiflash spiflash(
	.csb(ROM_CS),
	.clk(SCLK),
	.io0(SDO),
	.io1(SDI),
	.io2(),
	.io3()
);

endmodule
