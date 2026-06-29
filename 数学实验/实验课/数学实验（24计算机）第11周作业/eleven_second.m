%% ====== 题目2：法医颅骨面貌三维插值复原 ======
clear; clc; close all;

% 8 个特征点数据
xi = [0,   0,   0,  -45, 45, -20, 20,  0];   % 横向 x
yi = [0, -60,  70,   15, 15, -25, -25, 30];   % 纵向 y
zi = [100, 60, 75,   45, 45,  65,  65, 80];   % 高度 z

%% --- 定义网格 ---
x_range = -60:1:60;
y_range = -70:1:80;
[X, Y] = meshgrid(x_range, y_range);

%% --- 散点插值（griddata，cubic 方法）---
Z = griddata(xi, yi, zi, X, Y, 'cubic');

%% --- 绘制三维曲面 ---
figure('Position', [100, 100, 900, 650]);

% surf 曲面，加伪彩色和光照
surf(X, Y, Z, 'EdgeColor', 'none', 'FaceAlpha', 0.9);
colormap('jet');           % 伪彩色
shading interp;            % 插值着色（更平滑）
colorbar;
title('法医颅骨面貌复原 - 三维人脸曲面');
xlabel('横向 x (mm)'); ylabel('纵向 y (mm)'); zlabel('高度 z (mm)');

% 光照
light('Position', [1, 1, 2], 'Style', 'infinite');
lighting gouraud;
material shiny;

hold on;

% 标出原始 8 个解剖标志点（红色散点，稍高于曲面以便可见）
scatter3(xi, yi, zi + 2, 120, 'r', 'filled', 'MarkerEdgeColor', 'k');

% 标注点的名称
labels = {'鼻尖','下颌','额头','左颧骨','右颧骨','左嘴角','右嘴角','鼻根'};
for k = 1:length(labels)
    text(xi(k)+2, yi(k)+2, zi(k)+8, labels{k}, ...
         'FontSize', 9, 'Color', 'white', 'FontWeight', 'bold');
end

view([-35, 30]);  % 视角
axis tight;
grid on;

%% --- 验证：打印插值点处的 Z 值与原始 Z 的误差 ---
fprintf('\n验证插值精度（原始点处残差）：\n');
fprintf('%-15s %8s %8s %8s\n', '标志点', 'z_原始', 'z_插值', '误差');
fprintf('%s\n', repmat('-',1,45));
for k = 1:length(labels)
    z_check = griddata(xi, yi, zi, xi(k), yi(k), 'cubic');
    fprintf('%-15s %8.2f %8.2f %8.4f\n', labels{k}, zi(k), z_check, zi(k)-z_check);
end