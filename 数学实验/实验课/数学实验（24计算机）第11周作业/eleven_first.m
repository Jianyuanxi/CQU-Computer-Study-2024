%% ====== 题目1：人口数据插值 ======
clear; clc; close all;

% 原始数据
years = [2010, 2012, 2014, 2016, 2018];
pop   = [502,  515,  528,  540,  553];   % 单位：万人
x_target = 2015;  % 需要估计的年份

%% --- (1) 线性插值 ---
% 2015 在 2014 和 2016 之间
x1 = 2014; x2 = 2016;
y1 = 528;  y2 = 540;
pop_linear = y1 + (y2 - y1) / (x2 - x1) * (x_target - x1);
fprintf('线性插值估计 2015 年人口：%.4f 万人\n', pop_linear);

%% --- (2) 二次插值（Lagrange，取2014前后共3点）---
% 选 2012, 2014, 2016 三点做二次插值
xi2 = [2012, 2014, 2016];
yi2 = [515, 528, 540];
pop_quad = lagrange_interp(xi2, yi2, x_target);
fprintf('二次插值估计 2015 年人口：%.4f 万人\n', pop_quad);

%% --- (3) 三次插值（Lagrange，取4点）---
% 选 2012, 2014, 2016, 2018 四点做三次插值
xi3 = [2012, 2014, 2016, 2018];
yi3 = [515, 528, 540, 553];
pop_cubic = lagrange_interp(xi3, yi3, x_target);
fprintf('三次插值估计 2015 年人口：%.4f 万人\n', pop_cubic);

%% --- 用 MATLAB 内置 interp1 验证 ---
pop_interp1_linear = interp1(years, pop, x_target, 'linear');
pop_interp1_cubic  = interp1(years, pop, x_target, 'cubic');
pop_interp1_spline = interp1(years, pop, x_target, 'spline');
fprintf('\nMatlab interp1 验证：\n');
fprintf('  linear : %.4f 万人\n', pop_interp1_linear);
fprintf('  cubic  : %.4f 万人\n', pop_interp1_cubic);
fprintf('  spline : %.4f 万人\n', pop_interp1_spline);

%% --- 绘图对比 ---
x_fine = 2010:0.1:2018;
y_linear = interp1(years, pop, x_fine, 'linear');
y_spline = interp1(years, pop, x_fine, 'spline');

figure;
plot(years, pop, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', 'k'); hold on;
plot(x_fine, y_linear, 'b-', 'LineWidth', 1.5);
plot(x_fine, y_spline, 'r--', 'LineWidth', 1.5);
plot(x_target, pop_linear, 'bs', 'MarkerSize', 10, 'MarkerFaceColor', 'b');
plot(x_target, pop_cubic,  'r^', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
legend('原始数据', '分段线性插值', 'Spline 插值', ...
       sprintf('线性插值=%.2f', pop_linear), ...
       sprintf('三次插值=%.2f', pop_cubic), ...
       'Location', 'NorthWest');
xlabel('年份'); ylabel('人口（万人）');
title('人口数据插值对比');
grid on;

%% ====== 辅助函数：Lagrange 插值 ======
function y = lagrange_interp(xi, yi, x)
    n = length(xi);
    y = 0;
    for i = 1:n
        L = 1;
        for j = 1:n
            if j ~= i
                L = L * (x - xi(j)) / (xi(i) - xi(j));
            end
        end
        y = y + yi(i) * L;
    end
end