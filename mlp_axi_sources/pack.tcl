variable dispScriptFile [file normalize [info script]]
proc getScriptDirectory {} {
    variable dispScriptFile
    set scriptFolder [file dirname $dispScriptFile]
    return $scriptFolder
}

set sdir [getScriptDirectory]
cd [getScriptDirectory]

# STEP#1: Define project and configuration file directories
set resultDir ..\/..\/result\/MLP
set releaseDir ..\/..\/release\/MLP
set ipDir ..\/ip
file mkdir $resultDir
file mkdir $releaseDir
file mkdir $ipDir
create_project pkg_mlp ..\/..\/result\/MLP -part xc7z010clg400-1 -force

# STEP#2: Include all source files in project
add_files -norecurse ..\/hdl\/mlp.vhd
add_files -norecurse ..\/hdl\/mem_subsystem.vhd
add_files -norecurse ..\/hdl\/bram.vhd
add_files -norecurse ..\/hdl\/axi_mlp_v1_0_S00_AXIS.vhd
add_files -norecurse ..\/hdl\/axi_mlp_v1_0_S00_AXI.vhd
add_files -norecurse ..\/hdl\/axi_mlp_v1_0.vhd
add_files -fileset constrs_1 ..\/xdc\/mlp_constraints.xdc
update_compile_order -fileset sources_1

# STEP#3: Run synthesis
# launch_runs synth_1
# wait_on_run synth_1
# puts "* Synthesis done! *"

# STEP#4: Run implementation and configuration file generation
# set_property STEPS.WRITE_BITSTREAM.TCL.PRE [pwd]\/pre_write_bitstream.tcl [get_runs impl_1]
# launch_runs impl_1 -to_step write_bitstream
# wait_on_run impl_1
# puts "* Implementation done! *"

# STEP#5: Copy configuration file to release directory
#file copy -force ..\/..\/result\/MLP\/pkg_mlp.runs\/impl_1\/MLP_IP_v1_0.bit ..\/..\/release\/MLP\/MLP.bit 

# STEP#6: Package IP core
update_compile_order -fileset sources_1
ipx::package_project -root_dir $ipDir -vendor xilinx.com -library user -taxonomy /UserIP -force

set_property vendor FTN [ipx::current_core]
set_property name MLP_IP [ipx::current_core]
set_property display_name MLP_IP_v1_0 [ipx::current_core]
set_property description {MLP number classificator} [ipx::current_core]
set_property company_url http://www.fnt.uns.ac.rs [ipx::current_core]
set_property vendor_display_name FTN [ipx::current_core]
set_property taxonomy {/Embedded_Processing/AXI_Peripheral /UserIP} [ipx::current_core]
set_property supported_families {zynq Production} [ipx::current_core]

ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_DATA_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXI_ADDR_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "C_S00_AXIS_TDATA_WIDTH" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "WADDR" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "ACC_WDATA" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "IMG_LEN" -component [ipx::current_core]]
ipgui::remove_param -component [ipx::current_core] [ipgui::get_guiparamspec -name "LAYER_NUM" -component [ipx::current_core]]
set_property widget {textEdit} [ipgui::get_guiparamspec -name "WDATA" -component [ipx::current_core] ]
set_property value_validation_type range_long [ipx::get_user_parameters WDATA -of_objects [ipx::current_core]]
set_property value_validation_range_minimum 18 [ipx::get_user_parameters WDATA -of_objects [ipx::current_core]]
set_property value_validation_range_maximum 32 [ipx::get_user_parameters WDATA -of_objects [ipx::current_core]]

set_property core_revision 2 [ipx::current_core]
ipx::create_xgui_files [ipx::current_core]
ipx::update_checksums [ipx::current_core]
ipx::save_core [ipx::current_core]
set_property  ip_repo_paths $ipDir [current_project]
update_ip_catalog
ipx::check_integrity -quiet [ipx::current_core]
# ipx::archive_core {..\/..\/MLP_IP_v1_0_1.0.zip} [ipx::current_core]
close_project
