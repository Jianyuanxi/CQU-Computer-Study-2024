# ============================================================
# nexys4ddr.xdc -- Nexys4 DDR 引脚约束
# ============================================================

# 时钟（100MHz, E3）
set_property PACKAGE_PIN E3 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]
create_clock -period 10.000 -name sys_clk [get_ports clk]

# 复位：BTNC按钮（N17）—— 高有效
set_property PACKAGE_PIN N17 [get_ports rst]
set_property IOSTANDARD LVCMOS33 [get_ports rst]

# 数码管段选 seg[6:0] = {g,f,e,d,c,b,a}
set_property PACKAGE_PIN L3  [get_ports {seg[0]}]
set_property PACKAGE_PIN N1  [get_ports {seg[1]}]
set_property PACKAGE_PIN L5  [get_ports {seg[2]}]
set_property PACKAGE_PIN L4  [get_ports {seg[3]}]
set_property PACKAGE_PIN K3  [get_ports {seg[4]}]
set_property PACKAGE_PIN M2  [get_ports {seg[5]}]
set_property PACKAGE_PIN L6  [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]

# 数码管位选 an[7:0]
set_property PACKAGE_PIN N6  [get_ports {an[0]}]
set_property PACKAGE_PIN M6  [get_ports {an[1]}]
set_property PACKAGE_PIN M3  [get_ports {an[2]}]
set_property PACKAGE_PIN N5  [get_ports {an[3]}]
set_property PACKAGE_PIN N2  [get_ports {an[4]}]
set_property PACKAGE_PIN N4  [get_ports {an[5]}]
set_property PACKAGE_PIN L1  [get_ports {an[6]}]
set_property PACKAGE_PIN M1  [get_ports {an[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
