`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/25/2022 01:59:13 PM
// Design Name: 
// Module Name: PL_ADC
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


module PL_ADC(
        input wire i_CMOS_Clk,
        input wire [13:0] i_CMOS_Data,
        output reg [13:0] o_CMOS_Data,
        input wire i_ADC_Work,
        output reg o_ADC_Done
    );
    
    reg r_Work = 0;
    reg [19:0] r_Count = 0;
    
always @(posedge i_CMOS_Clk)
begin
    if (i_ADC_Work)
    begin
        o_ADC_Done = 0;
        r_Work = 1;
//        o_CMOS_Data = i_CMOS_Data;
    end
    
    if (r_Work)
    begin
        o_CMOS_Data = r_Count;
        r_Count = r_Count + 1;
        if (r_Count >= 200000)
        begin
            o_ADC_Done = 1;
            r_Work = 0;
        end
    end
//    else if (r_Work)
//    begin
//        o_ADC_Done = 1;
//        r_Work = 0;
//    end
    
end

initial
begin
    r_Work = 0;
end

endmodule
