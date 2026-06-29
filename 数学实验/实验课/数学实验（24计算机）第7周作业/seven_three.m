%% 题目3：城市人口拟合与短期预测（成都市 2014-2023）
clear; clc; close all;

years = 2014:2023;
pop   = [1442.0, 1465.8, 1483.0, 1604.7, 1633.0, ...
         1658.1, 2093.8, 2119.2, 2126.8, 2140.3];

% 令 t = year-2014，避免数值过大影响计算精度
t_all = 0:9;
t_tr  = t_all(1:7);    N_tr = pop(1:7);   % 训练：2014-2020
t_val = t_all(8:10);   N_val = pop(8:10);  % 验证：2021-2023

t_fine = linspace(-0.3, 10, 300);

%--- 模型A：线性 ---
pA    = polyfit(t_tr, N_tr, 1);
fitA  = polyval(pA, t_tr);
predA = polyval(pA, t_val);

%--- 模型B：指数（对数线性化）---
pB    = polyfit(t_tr, log(N_tr), 1);
A_B   = exp(pB(2));  b_B = pB(1);
fitB  = A_B * exp(b_B * t_tr);
predB = A_B * exp(b_B * t_val);

%--- 模型C：二次多项式 ---
pC    = polyfit(t_tr, N_tr, 2);
fitC  = polyval(pC, t_tr);
predC = polyval(pC, t_val);

%--- 计算误差 ---
function [rss, rmse, r2] = metrics(actual, pred)
    res  = actual - pred;
    rss  = sum(res.^2);
    rmse = sqrt(mean(res.^2));
    ss_tot = sum((actual - mean(actual)).^2);
    r2   = 1 - rss/ss_tot;
end

[rA_tr,mA_tr,r2A] = metrics(N_tr, fitA);
[rA_v, mA_v,  ~]  = metrics(N_val, predA);
[rB_tr,mB_tr,r2B] = metrics(N_tr, fitB);
[rB_v, mB_v,  ~]  = metrics(N_val, predB);
[rC_tr,mC_tr,r2C] = metrics(N_tr, fitC);
[rC_v, mC_v,  ~]  = metrics(N_val, predC);

fprintf('模型\tR²\tRMSE训练\tRMSE验证\n');
fprintf('线性\t%.4f\t%.2f\t%.2f\n',   r2A, mA_tr, mA_v);
fprintf('指数\t%.4f\t%.2f\t%.2f\n',   r2B, mB_tr, mB_v);
fprintf('二次\t%.4f\t%.2f\t%.2f\n',   r2C, mC_tr, mC_v);

%--- 绘图 ---
figure('Name', 'Problem 3', 'Position', [100 100 900 420]);
scatter(years(1:7),  N_tr,  80, 'k',  'filled'); hold on;
scatter(years(8:10), N_val, 80, 'r',  'filled', 'Marker', '^');
plot(t_fine+2014, polyval(pA,t_fine),            'b-',  'LineWidth',1.8);
plot(t_fine+2014, A_B*exp(b_B*t_fine),           'g--', 'LineWidth',1.8);
plot(t_fine+2014, polyval(pC,t_fine),            'r:',  'LineWidth',2);
xline(2020.5, '--k', '训练/验证分割线');
xlim([2013 2025]); ylim([1200 3000]);
legend('训练数据','验证数据','线性','指数','二次多项式', 'Location','northwest');
xlabel('年份'); ylabel('常住人口（万）');
title('成都市人口拟合与预测对比'); grid on;