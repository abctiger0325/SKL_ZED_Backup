/*

 pulse_compression_filter.v
 --------------
 By: Augustas Jackevic
 Date: July 2021

 Module Description:
 -------------------
 This module creates the pulse compression filter. The main blocks that create the filter is the 
 Hilbert transform (hilbert_transform), matched filter (n_tap_complex_fir), and the abs calculation
 (square_root_cal). The matched filter is the convolution operation between the input data and the 
 matched filter impulse response (very over-simplified). Both signals are applied through a hilbert 
 transform filter (removed the negative frequencies) and then convoluted. The hilbert transform is 
 required to avoid aliasing. Due to the hilbert transform, a complex signal is acquired thus a complex 
 FIR filter is utilised for the convolution. 
 
 In this module, the matched filter coefficients are acquired from the MFImpulseCoeff MIF file (coefficients
 are obtained from MATLAB), and the input data is read from the MFInputData MIF file. This data is then applied
 through the hilbert transform module to acquire a complex signal. The coefficients are loaded to the complex
 FIR filter and the data in complex signal is then applied to the FIR filter, with the output being the convelution
 product between the matched filter impulse response coefficients and the applied data in. The abs value is then
 calculated from the complex FIR filter output, using the non-restoring square root algorithm.

*/
`define Data_Size 5000

module pulse_compression_filter #(
	parameter COEFF_LENGTH = 800,
	parameter DATA_LENGTH = 7700,
	parameter HT_COEFF_LENGTH = 27,
	parameter DATA_WIDTH = 12
	// It should be noted the stated parameters must match the values in the MATLAB script.
	// COEFF_LENGTH and DATA_LENGTH must be exactly half the length of the data in the MIF files. This is done so
	// as muiltiplication is easier to do than devisision.
)(
	input clock,
	input enable,
	
	output reg [31:0] MFOutput,
	input [11:0] i_Data
);


// Local parameters for the module read_MIF_file.
localparam COEFF = 1;
localparam DATA_IN = 2;

// Local parameters for the module square_root_cal.
// ABS_DATA_IN_WIDTH is determind by log2[(2^(DATA_WIDTH - 1) - 1)^2 + (2^(DATA_WIDTH - 1) - 1)^2] 
// rounded up even value. ABS_DATA_OUT_WIDTH must be half of ABS_DATA_IN_WIDTH.
localparam ABS_DATA_IN_WIDTH = 84;
localparam ABS_DATA_OUT_WIDTH = 42;


// Enable regs for the instantiated modules.
reg enableMFCoeff;
reg enableMFDataIn;
reg enablecomplexFIRCoeff;
reg enableHT;
reg enableComplexFIRData;
reg enableSquar;

reg [ABS_DATA_IN_WIDTH - 1:0] absInputValue;
wire [ABS_DATA_OUT_WIDTH - 1:0] absOutputValue;


// A reg for informing the complex FIR filter when the data is about to be stopped.
reg stopDataLoadFlag;


// Output ports for the instantiated modules.
wire coeffFinishedFlag;
wire dataInFinishedFlag;
wire signed [DATA_WIDTH - 1:0] coeffMIFOutRe;
wire signed [DATA_WIDTH - 1:0] coeffMIFOutIm;
wire signed [DATA_WIDTH - 1:0] dataMIFOutRe;

wire signed [(DATA_WIDTH * 3) - 1:0] HTOutRe;
wire signed [(DATA_WIDTH * 3) - 1:0] HTOutIm;

wire signed [(DATA_WIDTH * 4) - 1:0] MFOutputRe;
wire signed [(DATA_WIDTH * 4) - 1:0] MFOutputIm;



// FSM
reg [2:0] state;
localparam IDLE = 1;
localparam SET_ENABLE = 2;
localparam STOP = 3;




// Set the initial values of the local parameters.
initial begin

	enableMFCoeff <= 1'd0;
	enableMFDataIn <= 1'd0;
	enablecomplexFIRCoeff <= 1'd0;
	enableHT <= 1'd0;
	enableSquar <= 1'd0;
	
	
	enableComplexFIRData <= 1'd0;
	stopDataLoadFlag <= 1'd0;
	
	absInputValue <= {(ABS_DATA_IN_WIDTH){1'd0}};
	
	
	state <= IDLE;
end




// Instantiating the module read_MIF_file. This is used to read the coefficients from the MFImpulseCoeff.mif file.
read_MIF_file #(
	.LENGTH 				(COEFF_LENGTH),
	.DATA_WIDTH 		(DATA_WIDTH),
	.DATA_TYPE 			(COEFF)

) MFCoeff (
	.clock				(clock),
	.enable				(enableMFCoeff),
	
	.dataFinishedFlag	(coeffFinishedFlag),	
	.outputRe			(coeffMIFOutRe),
	.outputIm			(coeffMIFOutIm)
);




// Instantiating the module read_MIF_file. This is used to read the data in from the MFInputData.mif file. 
read_MIF_file #(
	.LENGTH 				(DATA_LENGTH),
	.DATA_WIDTH 		(DATA_WIDTH),
	.DATA_TYPE 			(DATA_IN)

) MFDataIn (
	.clock				(clock),
	.enable				(enableMFDataIn),
	
	.dataFinishedFlag	(dataInFinishedFlag),	
	.outputRe			(dataMIFOutRe),
	.outputIm			() // This port is ignored as all data is passed through outputRe.
);




// Instantiating the module n_tap_complex_fir. This is used for the main opperation of the matched filter
// between the complex input data and the complex impulse reponse of the matched filter.
n_tap_complex_fir #(
	.LENGTH					(COEFF_LENGTH),
	.DATA_WIDTH 			(DATA_WIDTH)
) coplexFIR (
	.clock					(clock),
	.loadCoeff				(enablecomplexFIRCoeff),
	.coeffSetFlag			(coeffFinishedFlag),
	.loadDataFlag			(enableComplexFIRData),
	.stopDataLoadFlag		(stopDataLoadFlag),
	.dataInRe				(HTOutRe),
	.dataInIm				(HTOutIm),
	.coeffInRe				(coeffMIFOutRe),
	.coeffInIm				(coeffMIFOutIm),
	
	.dataOutRe				(MFOutputRe),
	.dataOutIm				(MFOutputIm)
);




// Instantiating the module hilbert_transform. This is used to aquire a complex signal from a real signal 
// by performing hilbert transform filtering of the data aquired from MFInputData.mif.
 hilbert_transform #(
	.LENGTH 				(HT_COEFF_LENGTH),
	.DATA_WIDTH 		(DATA_WIDTH)
) hilbertTransform (
	.clock				(clock),
	.enable				(enableHT),
	.stopDataInFlag	(),
	.dataIn				(dataMIFOutRe),
	
	.dataOutRe			(HTOutRe),
	.dataOutIm			(HTOutIm)
);






square_root_cal #(
	.INPUT_DATA_WIDTH		(ABS_DATA_IN_WIDTH),
	.OUTPUT_DATA_WIDTH	(ABS_DATA_OUT_WIDTH)
) squr(
	.clock					(clock),
	.enable					(enableSquar),
	.inputData				(absInputValue),
	
	.outputData				(absOutputValue)
);




always @ (posedge clock) begin
	case(state)
		
		// State IDLE. This state waits until enable is set before transistioning to LOAD_COEFF.
		IDLE: begin
			if(enable) begin
				state <= SET_ENABLE;
			end
		end
		
		
		// State LOAD_COEFF. This state enables the majority of the enable regs for the instantiated modules.
		// Since the input data is only 14400 long, after it has read thoes values, the output of this module
		// will be 'don't care bits'/unkown. To prevent that, supply more input data.  
		SET_ENABLE: begin
						
			// When the coefficients have been loaded do the following.
			if(coeffFinishedFlag) begin
			
				enableMFCoeff <= 1'd0;
				enablecomplexFIRCoeff <= 1'd0;
				
				enableMFDataIn <= 1'd1;
				enableHT <= 1'd1;
				enableComplexFIRData <= 1'd1;
				enableSquar <= 1'd1;
				
			end
			
			// Whilst the coefficients are being loaded do the following.
			else begin
				enableMFCoeff <= 1'd1;
				enableMFDataIn <= 1'd1;
				enablecomplexFIRCoeff <= 1'd1;
				enableHT <= 1'd1;
				enableComplexFIRData <= 1'd1;
				enableSquar <= 1'd1;
			end
			
			absInputValue <= (MFOutputRe * MFOutputRe) + (MFOutputIm * MFOutputIm);
			MFOutput <= absOutputValue[41:10];
			if (MFOutput == 'hffffffff) MFOutput <= 0;
		end
		
		
		// State STOP. This is an empty state that is not used in this design.
		STOP: begin
		
		end
		
		
		// State default. This state sets the default values just incase the FSM is in an unknown state.
		default: begin
			enableMFCoeff <= 1'd0;
			enableMFDataIn <= 1'd0;
			enablecomplexFIRCoeff <= 1'd0;
			enableHT <= 1'd0;
			
			
			enableComplexFIRData <= 1'd0;
			stopDataLoadFlag <= 1'd0;
			
			
			state <= IDLE;
		end
		
	endcase
end

endmodule
