`timescale 1ns / 1ps
// ============================================================
// testbench.v -- 累加程序仿真验证
// 检测 sw $1, 0($0)：地址0写入5050 → 打印 "Simulation succeeded"
// 否则在第一次sw时报错失败
// ============================================================
module testbench();

    reg         clk;
    reg         rst;
    wire [31:0] writedata, dataadr;
    wire        memwrite;
    wire [31:0] display_data;

    // 实例化DUT
    top dut(
        .clk(clk), .rst(rst),
        .writedata(writedata),
        .dataadr(dataadr),
        .memwrite(memwrite),
        .display_data(display_data)
    );

    // 复位脉冲
    initial begin
        rst = 1;
        #22;
        rst = 0;
    end

    // 时钟：周期20ns（50MHz）
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 监测 sw 写入：第一次写到地址0、数据5050 即成功
    // sum1to100 程序最终执行 sw $1, 0($0)，将$1=5050写入地址0
    always @(negedge clk) begin
        if (memwrite) begin
            if (dataadr === 32'd0 && writedata === 32'd5050) begin
                $display("================================================");
                $display(" Simulation succeeded ");
                $display(" sum(1+2+...+100) = %0d (0x%h)",
                         writedata, writedata);
                $display("================================================");
                $stop;
            end
            else begin
                $display("================================================");
                $display(" Simulation FAILED ");
                $display(" dataadr=%0d writedata=%0d (0x%h)",
                         dataadr, writedata, writedata);
                $display("================================================");
                $stop;
            end
        end
    end

endmodule
