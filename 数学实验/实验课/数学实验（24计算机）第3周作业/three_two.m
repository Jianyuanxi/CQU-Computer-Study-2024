clc; clear; close all;

x = [5.764, 6.286, 6.759, 7.168, 7.408];
y = [0.648, 1.202, 1.823, 2.526, 3.360];

M = [x'.^2,  x'.*y',  y'.^2,  x',  y'];
b_vec = -ones(5,1);

coeff = M \ b_vec;  
A = coeff(1); B = coeff(2); C = coeff(3);
D = coeff(4); E = coeff(5); F = 1;

fprintf('圆锥曲线系数：\n');
fprintf('  A=%.6f, B=%.6f, C=%.6f\n', A, B, C);
fprintf('  D=%.6f, E=%.6f, F=%.6f\n', D, E, F);

disc = B^2 - 4*A*C;
fprintf('\n判别式 B^2-4AC = %.6f\n', disc);
if     disc < 0, fprintf('→ 椭圆（或圆）\n');
elseif disc == 0, fprintf('→ 抛物线\n');
else,             fprintf('→ 双曲线\n');
end

residuals = A*x.^2 + B*x.*y + C*y.^2 + D*x + E*y + F;
fprintf('\n各点代入残差：\n');
for i=1:5
    fprintf('  点%d (%.3f,%.3f)：残差=%.2e\n',i,x(i),y(i),residuals(i));
end

figure('Position',[100,100,800,600]);

[xg, yg] = meshgrid(linspace(4, 12, 600), linspace(-2, 8, 600));
Z = A*xg.^2 + B*xg.*yg + C*yg.^2 + D*xg + E*yg + F;
contour(xg, yg, Z, [0 0], 'b-', 'LineWidth', 2.5);
hold on;

plot(x, y, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r', 'LineWidth', 2);

if B ~= 0
    theta = 0.5 * atan2(B, A-C);
else
    theta = 0;
end
fprintf('\n旋转角 θ = %.4f rad = %.2f°\n', theta, rad2deg(theta));

xlabel('x (AU)', 'FontSize', 12);
ylabel('y (AU)', 'FontSize', 12);
title('小行星运行轨道（五点定轨）', 'FontSize', 14, 'FontWeight', 'bold');
legend({'拟合轨道曲线', '观测点'}, 'FontSize', 11, 'Location', 'northwest');
grid on; axis equal;

eq_str = sprintf('%.4fx² + %.4fxy + %.4fy² + %.4fx + %.4fy + 1 = 0', A,B,C,D,E);
text(4.5, 7, eq_str, 'FontSize', 9, 'Color', [0 0 0.8]);

if disc < 0
    fprintf('\n=== 椭圆轨道参数分析 ===\n');
    M33 = [A, B/2, D/2; B/2, C, E/2; D/2, E/2, F];
    M22 = [A, B/2; B/2, C];
    lam22 = eig(M22);      
    lam33 = eig(M33);      
    det_M33 = det(M33);
    
    a_sq = -det_M33 / (lam33(1) * lam33(2) * lam22(1));  %#ok
    
    center_sys = [2*A, B; B, 2*C];
    center_rhs = [-D; -E];
    center = center_sys \ center_rhs;
    fprintf('轨道中心估计：(%.4f, %.4f)\n', center(1), center(2));
    
    theta = 0.5 * atan2(B, A - C);
    fprintf('主轴旋转角：%.4f rad = %.2f°\n', theta, rad2deg(theta));
end