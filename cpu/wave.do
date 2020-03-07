onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group Global /cpu_tb/clk
add wave -noupdate -expand -group Global /cpu_tb/dut/reset
add wave -noupdate -expand -group Global -radix hexadecimal /cpu_tb/dut/pc_curr
add wave -noupdate -expand -group Global -radix hexadecimal /cpu_tb/dut/pc_next
add wave -noupdate -expand -group Instructions -radix hexadecimal /cpu_tb/dut/ftch_inst
add wave -noupdate -expand -group Instructions -radix hexadecimal /cpu_tb/dut/decd_inst
add wave -noupdate -expand -group Instructions -radix hexadecimal /cpu_tb/dut/exec_inst
add wave -noupdate -expand -group Instructions -radix hexadecimal /cpu_tb/dut/wrbk_inst
add wave -noupdate -expand -group Instructions -radix hexadecimal /cpu_tb/dut/memw_inst
add wave -noupdate -expand -group Registers -radix unsigned /cpu_tb/dut/read_regA
add wave -noupdate -expand -group Registers -radix decimal /cpu_tb/dut/data_regA
add wave -noupdate -expand -group Registers -radix unsigned /cpu_tb/dut/read_regB
add wave -noupdate -expand -group Registers -radix decimal /cpu_tb/dut/data_regB
add wave -noupdate -expand -group Registers -radix unsigned /cpu_tb/dut/write_reg
add wave -noupdate -expand -group Registers -radix decimal /cpu_tb/dut/reg_write_value
add wave -noupdate -expand -group Registers /cpu_tb/dut/reg_write_en
add wave -noupdate -expand -group Memory -radix hexadecimal /cpu_tb/dut/mem_access_addr
add wave -noupdate -expand -group Memory /cpu_tb/dut/read_mem_data
add wave -noupdate -expand -group Memory /cpu_tb/dut/write_mem_data
add wave -noupdate -expand -group Memory /cpu_tb/dut/mem_write_en
add wave -noupdate -expand -group Control /cpu_tb/dut/decd_ctrl
add wave -noupdate -expand -group Control /cpu_tb/dut/exec_ctrl
add wave -noupdate -expand -group Control /cpu_tb/dut/memw_ctrl
add wave -noupdate -expand -group Control /cpu_tb/dut/wrbk_ctrl
add wave -noupdate /cpu_tb/dut/alu_output
add wave -noupdate -group CPSR /cpu_tb/dut/N_flag
add wave -noupdate -group CPSR /cpu_tb/dut/Z_flag
add wave -noupdate -group CPSR /cpu_tb/dut/C_flag
add wave -noupdate -group CPSR /cpu_tb/dut/V_flag
add wave -noupdate -group CPSR /cpu_tb/dut/update_CPSR
add wave -noupdate -group CPSR /cpu_tb/dut/N_flag_temp
add wave -noupdate -group CPSR /cpu_tb/dut/Z_flag_temp
add wave -noupdate -group CPSR /cpu_tb/dut/C_flag_temp
add wave -noupdate -group CPSR /cpu_tb/dut/V_flag_temp
add wave -noupdate /cpu_tb/dut/cm/clk
add wave -noupdate /cpu_tb/dut/cm/reset
add wave -noupdate /cpu_tb/dut/cm/addr
add wave -noupdate /cpu_tb/dut/cm/inst
add wave -noupdate /cpu_tb/dut/cm/scaled_addr
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {45452 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 165
configure wave -valuecolwidth 85
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ns} {88879 ns}
