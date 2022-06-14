`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/12/2022 10:38:57 AM
// Design Name: 
// Module Name: ADC_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module ADC_tb #(
		parameter integer C_S00_AXI_DATA_WIDTH	= 32,
		parameter integer C_S00_AXI_ADDR_WIDTH	= 5,

		// Parameters of Axi Master Bus Interface M00_AXIS
		parameter integer C_M00_AXIS_TDATA_WIDTH	= 16,
		parameter integer C_M00_AXIS_START_COUNT	= 2
    );
    
    reg i_CMOS_Clk = 0;
    reg i_CMOS_Data;
    
    PL_SPI_ADC_MasterStream_v1_0_M00_AXIS # ( 
		.C_M_AXIS_TDATA_WIDTH(C_M00_AXIS_TDATA_WIDTH),
		.C_M_START_COUNT(C_M00_AXIS_START_COUNT)
	) PL_SPI_ADC_MasterStream_v1_0_M00_AXIS_inst (
		.i_CMOS_Clk(i_CMOS_Clk),
//	    .i_CMOS_Data(i_CMOS_Data >> 4),
	    .i_CMOS_Data_MSB(i_CMOS_Data),
//	    .i_CMOS_Data_LSB(i_CMOS_Data[7:0]),
//	    .i_ADC_Work(i_ADC_Work),
        .i_ADC_Work(w_ADC_Work),
	    .o_ADC_Done(w_ADC_Done),
        .INIT_AXI_TXN(m00_axi_init_axi_txn),
        .o_LED(o_LED),
        .i_Mode(i_Mode),
//        .o_Data_Cnt(w_Data_Cnt),
//        .i_Trigger(i_Trigger),
//        .i_Done_Clean(w_Done_Clean),
		.M_AXIS_ACLK(m00_axis_aclk),
		.M_AXIS_ARESETN(s00_axi_aresetn),
		.M_AXIS_TVALID(m00_axis_tvalid),
		.M_AXIS_TDATA(m00_axis_tdata),
		.M_AXIS_TSTRB(m00_axis_tstrb),
		.M_AXIS_TLAST(m00_axis_tlast),
		.M_AXIS_TREADY(m00_axis_tready)
	);
		
	initial begin
	   
	end

    always #5 begin
        i_CMOS_Clk = ~i_CMOS_Clk;
    end

endmodule
