

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "PL_SPI_DDS" "NUM_INSTANCES" "DEVICE_ID"  "C_S00_AXI_BASEADDR" "C_S00_AXI_HIGHADDR"
}
