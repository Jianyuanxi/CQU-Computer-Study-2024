x = linspace(-10, 10, 1000);
y1 = sin(x);
y2 = cos(x);
y3 = exp(-x) .* sin(2*x);

figure(1);
plot(x, y1, 'r-',  'LineWidth', 2); hold on;
plot(x, y2, 'b--', 'LineWidth', 2);
plot(x, y3, 'g-.', 'LineWidth', 2); hold off;
title('三函数曲线对比（同一坐标系）');
xlabel('x');
ylabel('y');
legend('y_1 = sin(x)', 'y_2 = cos(x)', 'y_3 = e^{-x}sin(2x)');
grid on;
xlim([-10, 10]);
ylim([-3, 3]);

figure(2);

subplot(3, 1, 1);
plot(x, y1, 'r-', 'LineWidth', 2);
title('y_1 = sin(x)');
xlabel('x'); ylabel('y');
xlim([-10, 10]); grid on;

subplot(3, 1, 2);
plot(x, y2, 'b--', 'LineWidth', 2);
title('y_2 = cos(x)');
xlabel('x'); ylabel('y');
xlim([-10, 10]); grid on;

subplot(3, 1, 3);
plot(x, y3, 'g-.', 'LineWidth', 2);
title('y_3 = e^{-x}sin(2x)');
xlabel('x'); ylabel('y');
xlim([-10, 10]); 
ylim([-3, 3]);
grid on;

sgtitle('三函数分图展示（subplot）');