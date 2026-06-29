%% 题目2：细菌增长模型  N(t) = A*exp(b*t)
clear; clc; close all;

t = [0, 1, 2, 3, 4, 5];
N = [2.1, 2.8, 4.0, 5.9, 8.5, 12.1];

%--- 方法1：对数线性化最小二乘 ---
% 两边取 ln：ln(N) = ln(A) + b*t
lnN  = log(N);
p    = polyfit(t, lnN, 1);   % p(1)=b, p(2)=ln(A)
b1   = p(1);
A1   = exp(p(2));
N1   = A1 * exp(b1 * t);     % 拟合值
RSS1 = sum((N - N1).^2);
rel_err = abs(N - N1) ./ N * 100;   % 相对误差 %

fprintf('--- 对数线性化 ---\n');
fprintf('A = %.4f,  b = %.4f\n', A1, b1);
fprintf('RSS = %.6f\n', RSS1);
fprintf('相对误差 %%: '); disp(round(rel_err, 2));

%--- 方法2：非线性最小二乘 lsqcurvefit ---
model   = @(params, t) params(1) * exp(params(2) * t);
opts    = optimset('Display', 'off');
params0 = [A1, b1];   % 以线性化结果作为初值
params  = lsqcurvefit(model, params0, t, N, [], [], opts);
A2  = params(1);  b2 = params(2);
N2  = model(params, t);
RSS2 = sum((N - N2).^2);

fprintf('\n--- 非线性最小二乘 ---\n');
fprintf('A = %.4f,  b = %.4f\n', A2, b2);
fprintf('RSS = %.6f\n', RSS2);

%--- 绘图 ---
t_fine = linspace(0, 5.5, 200);
figure('Name', 'Problem 2');
subplot(1,2,1);
scatter(t, N, 80, 'k', 'filled'); hold on;
plot(t_fine, A1*exp(b1*t_fine), 'b-', 'LineWidth', 2);
plot(t_fine, A2*exp(b2*t_fine), 'r--', 'LineWidth', 2);
legend('观测值','对数线性化','非线性LS');
title('指数拟合对比'); xlabel('t'); ylabel('N(t)'); grid on;
subplot(1,2,2);
scatter(t, lnN, 80, 'k', 'filled'); hold on;
plot(t_fine, log(A1)+b1*t_fine, 'b-', 'LineWidth', 2);
title('线性化：ln(N) = ln(A) + bt'); xlabel('t'); ylabel('ln N'); grid on;
sgtitle('题目2：细菌增长模型');