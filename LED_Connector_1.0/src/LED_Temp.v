`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/28/2021 11:04:50 AM
// Design Name: 
// Module Name: LED_Temp
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


module LED_Temp(
    input wire i_clk,
    input wire [7:0] i_PS_LED,
//    input wire [7:0] i_PS_LED_mask,
//    output reg [7:0] o_PS_LED,
    output reg [7:0] o_LED
    );
    
    reg [7:0] r_LED;
    
    initial
    begin
        r_LED = 0;
    end
    
    always @(posedge i_clk)
    begin
        r_LED = i_PS_LED;
        if (r_LED == 'h00)
        begin
            r_LED = 'h87;
        end
    end
    
    always @(*)
    begin
        o_LED = r_LED;
//        o_PS_LED = r_LED;
    end
endmodule
