# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## 项目概述

计算机组成原理实验4 —— 五级流水线 MIPS 微处理器（Verilog HDL），支持 FPGA 上板（Nexys4 DDR）和 Vivado 仿真。

## 目录结构

```
实验4/
├── files/          # 第1版（基础流水线）
├── files_2/        # 第2版（增加显示模块、hazard等）
├── files_final/    # 最终版（完整流水线 + 前推 + 暂停 + 上板）
│   ├── inst_ram.mem    # 行为级仿真的指令存储器初始化文件
│   └── sum1to100.coe   # Block Memory IP 用的 COE 初始化文件
├── sim/            # 早期仿真 testbench
├── coe/            # 额外测试程序 COE 文件
│   ├── mipstest.coe      # 标准功能验证程序（sw写入7到地址84）
│   └── sum1to100.coe     # 1+2+...+100=5050 累加程序
└── docs/           # 实验指导书和报告模板
```

## 支持的工具链

- **仿真**: Vivado Simulator（Vivado 自带）
- **上板**: Vivado + Nexys4 DDR 开发板（100MHz 板载时钟，Xilinx Artix-7）
- 上板需要创建两个 Block Memory IP：`inst_ram`（Single Port ROM, 32-bit×256）和 `data_ram`（Single Port RAM, 32-bit×256）

## 核心架构

五级流水线 MIPS CPU，支持 9 条指令：`add, sub, and, or, slt, addi, lw, sw, beq, j`。

### 三大顶层模块（`mips.v` 中实例化）

| 模块 | 文件 | 职责 |
|------|------|------|
| `controller` | `controller.v` + `maindec.v` + `aludec.v` | ID 阶段译码，控制信号逐级流水传递 |
| `datapath` | `datapath.v` + `regfile.v` + `alu.v` 等 | 五级流水线数据通路 |
| `hazard` | `hazard.v` | 数据前推（forwardAE/BE）+ load-use 暂停（lwstall） |

### 流水线阶段与寄存器类型

| 阶段间寄存器 | 所用 D 触发器 | 特殊控制 |
|-------------|-------------|---------|
| PC 寄存器 | `flopenr` | `en=~stallF`（load-use 时 PC 暂停） |
| IF/ID | `flopenrc` | `en=~stallD`, `clear=flushD`（分支/跳转冲刷） |
| ID/EX | `floprc` | `clear=flushE_total`（lwstall 气泡 + 分支冲刷） |
| EX/MEM | `flopr` | 无特殊控制 |
| MEM/WB | `flopr` | 无特殊控制 |

### 关键设计决策

1. **beq 判断在 EX 阶段**（非 ID 阶段），因此 branch 信号流过 ID/EX 寄存器后在 EX 阶段与 ALU zero 信号组合产生 pcsrcE
2. **寄存器堆下降沿写**：解决 WB→ID 读后写一致性（下一条指令 ID 阶段上升沿可读到新写入值）
3. **flushE 合成**：`flushE_total = flushE_hazard（lwstall气泡）| flushD（分支/跳转冲刷）`，必须同时清掉 ID/EX，否则 beq 后的"延迟槽"指令会错误执行
4. **sw 数据路径**：srcb2E 为前推后的 rt 值，直接写回 data_ram；不经过 ALU 运算结果路径
5. **前推优先级**：MEM 前推（2'b10）> WB 前推（2'b01）> 无前推（2'b00）

### 两级顶层

- **`top.v`**（仿真顶层）：实例化 `mips` + 行为级 `imem`/`dmem`（用 `$readmemh` 加载 `inst_ram.mem`）。`display_data` 实时暴露 `dmem.mem[0]` 供波形观察。
- **`board_top.v`**（上板顶层）：实例化 `mips` + Block Memory IP（`inst_ram`/`data_ram`）+ `clk_div`（100→25MHz）+ `display`（锁存 sw 写入地址0 的数据，显示在数码管）。

## 仿真运行

在 Vivado 中：

1. 添加 `files_final/` 下所有 `.v` 文件为设计源
2. 添加 `files_final/testbench.v`（或 `sim/testbench.v`）为仿真源
3. 确保 `top.v` 中 `$readmemh` 路径指向正确的 `.mem` 文件（默认 `C:/coe/inst_ram.mem`，可改为相对路径或本地路径）
4. 运行行为仿真（Run Behavioral Simulation）

**测试程序预期**：
- `sum1to100`：testbench 检测 `sw $1, 0($0)` 写入 `dataadr=0, writedata=5050 (0x13BA)`
- `mipstest`：testbench 检测 `sw $2, 84($0)` 写入 `dataadr=84, writedata=7`

### 切换测试程序

- **仿真（行为级）**：修改 `top.v` 中 `$readmemh` 的文件路径，或替换 `files_final/inst_ram.mem` 内容
- **上板（Block Memory IP）**：在 Vivado 中修改 Block Memory IP 的 COE 文件路径

### inst_ram.mem 格式

每行一个 32 位十六进制指令（不含 `0x` 前缀），由 MARS/MIPSasm 等汇编器生成。与 `.coe` 格式的区别：`.mem` 是纯指令列表；`.coe` 需要 `memory_initialization_radix` 和 `memory_initialization_vector` 头部声明。
