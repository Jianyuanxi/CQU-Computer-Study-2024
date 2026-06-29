`timescale 1ns / 1ps
// ============================================================
// 流水线仿真文件
// 目标：
//   1. 演示流水线加法器计算 1+2+...+100 = 5050
//   2. 第10周期后暂停第2级流水线 2 个周期（stop[1]）
//   3. 第15周期时刷新第3级流水线 1 个周期（reset[2]）
//   4. 同时用非流水线行为模型做对比
// ============================================================

module pipline_sim();

    // 流水线加法器信号
    reg         clk;
    reg         c_in;
    reg  [31:0] cin_a;
    reg  [31:0] cin_b;
    reg  [3:0]  stop;
    reg  [3:0]  reset_pipe;
    wire        c_out;
    wire [31:0] sum_out;

    // 非流水线对比：每个时钟沿直接累加
    reg  [31:0] non_pipe_sum;

    // 实例化流水线加法器
    pipline uut(
        .cin_a(cin_a),
        .cin_b(cin_b),
        .c_in(c_in),
        .clk(clk),
        .stop(stop),
        .reset(reset_pipe),
        .c_out(c_out),
        .sum_out(sum_out)
    );

    // 时钟：周期 10ns
    initial clk = 0;
    always #5 clk = ~clk;

    integer cycle;

    initial begin
        // ---- 初始化 ----
        c_in        = 1'b0;
        cin_a       = 32'd0;
        cin_b       = 32'd0;
        stop        = 4'b0000;
        reset_pipe  = 4'b1111;   // 全局复位一拍
        non_pipe_sum = 32'd0;
        cycle        = 0;

        @(posedge clk); #1;
        reset_pipe = 4'b0000;    // 释放复位

        // ---- 逐周期送入加数 1~100 ----
        // pipline 是单拍加法器（两操作数相加一次输出一次）
        // 这里每周期把"当前加数"送进去，用非流水线行为模拟做对比
        // 流水线有4级延迟，最终 sum_out 在第4拍之后才稳定
        for (cycle = 1; cycle <= 100; cycle = cycle + 1) begin

            cin_a = 32'd0;          // A 固定为 0，B 为当前加数
            cin_b = cycle;          // 每次加一个新数

            // 非流水线：组合逻辑直接累加
            non_pipe_sum = non_pipe_sum + cycle;

            // --- 第10周期：暂停第2级 2 个周期 ---
            if (cycle == 10) begin
                @(posedge clk); #1;
                stop = 4'b0010;          // 拉高 stop[1]，暂停第2级
                @(posedge clk); #1;      // 暂停第1周期
                @(posedge clk); #1;      // 暂停第2周期
                stop = 4'b0000;          // 恢复流水
            end

            // --- 第15周期：刷新第3级 1 个周期 ---
            if (cycle == 15) begin
                reset_pipe = 4'b0100;    // 拉高 reset[2]，刷新第3级
                @(posedge clk); #1;
                reset_pipe = 4'b0000;    // 恢复
            end

            @(posedge clk); #1;
        end

        // 等待流水线最后几级排空（4级延迟）
        repeat(6) @(posedge clk);

        $display("========== 仿真结果 ==========");
        $display("非流水线累加结果: %0d (十六进制: 0x%04X)", non_pipe_sum, non_pipe_sum);
        $display("期望值: 5050 = 0x13BA");
        $display("==============================");

        #20;
        $finish;
    end

endmodule
