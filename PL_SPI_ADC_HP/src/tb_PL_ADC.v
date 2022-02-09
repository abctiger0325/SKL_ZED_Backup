`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01/26/2022 03:46:48 PM
// Design Name: 
// Module Name: tb_PL_ADC
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


module tb_PL_ADC(

    );
    reg clk = 0;
    wire [13:0] data;
    reg trg = 0;
    
    
    always #1 clk = ~clk;
    PL_ADC ADC (
        .i_CMOS_Clk(clk),
        .i_CMOS_Data(),
        .o_CMOS_Data(data),
        .i_ADC_Work(trg),
        .o_ADC_Done()
    );
    
    initial
    begin
        trg = 0;
        #5 
        trg = 1;
        #10 
        trg = 0;
    end
endmodule
