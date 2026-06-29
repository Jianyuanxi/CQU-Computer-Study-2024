%% 题目1：多项式最小二乘拟合
clear; clc; close all;

x = [0, 1, 2, 3, 4, 5, 6];
y = [1.1, 2.3, 2.9, 3.8, 5.1, 5.9, 7.2];

x_fine = linspace(0, 6, 200);   % 绘图用的细密 x
colors  = {'b', 'g', 'r'};
degrees = [1, 2, 3];

figure('Name', 'Problem 1', 'Position', [100 100 1200 380]);

for i = 1:3
    deg = degrees(i);

    % 最小二乘多项式拟合，返回系数从高次到低次
    p      = polyfit(x, y, deg);
    y_pred = polyval(p, x);
    RSS    = sum((y - y_pred).^2);

    fprintf('Degree %d 系数: ', deg); disp(p);
    fprintf('RSS = %.8f\n\n', RSS);

    % 绘图
    subplot(1, 3, i);
    scatter(x, y, 60, 'k', 'filled'); hold on;
    plot(x_fine, polyval(p, x_fine), colors{i}, 'LineWidth', 2);
    title(sprintf('%d次多项式  RSS=%.4f', deg, RSS));
    xlabel('x'); ylabel('y');
    legend('数据点', sprintf('%d次拟合', deg), 'Location', 'northwest');
    grid on;
end

sgtitle('题目1：多项式最小二乘拟合');