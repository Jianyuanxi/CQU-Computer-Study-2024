clc; clear; close all;
rng(42); 

n = 200;
mu    = [72, 68, 75];
sigma = [12, 14, 10];
courses = {'数学', '英语', '编程'};

scores = zeros(n, 3);
for i = 1:3
    raw = mu(i) + sigma(i) * randn(n, 1);
    scores(:, i) = max(0, min(100, raw));
end

figure(1);
colors = {[0.2 0.5 0.8], [0.8 0.4 0.2], [0.3 0.7 0.4]};
for i = 1:3
    subplot(1, 3, i);
    histogram(scores(:,i), 15, 'FaceColor', colors{i}, 'EdgeColor', 'white');
    title([courses{i} ' 成绩分布']);
    xlabel('分数'); ylabel('人数');
    xlim([0 100]); grid on;
end
sgtitle('各课程成绩直方图');

figure(2);
boxplot(scores, courses);
title('三门课程成绩箱线图');
ylabel('分数');
grid on;

total = sum(scores, 2);
figure(3);
plot(1:n, sort(total), 'b-o', 'LineWidth', 1.5, 'MarkerSize', 3);
title('学生总分折线图（升序排列）');
xlabel('学生编号（排序后）'); ylabel('总分');
grid on;

fprintf('===== 各课程统计量 =====\n');
fprintf('%-6s %8s %8s %8s %8s\n', '课程','均值','标准差','最高分','最低分');
for i = 1:3
    fprintf('%-6s %8.2f %8.2f %8.2f %8.2f\n', ...
        courses{i}, mean(scores(:,i)), std(scores(:,i)), ...
        max(scores(:,i)), min(scores(:,i)));
end

total = sum(scores, 2);
cnt(1) = sum(total >= 270);                 
cnt(2) = sum(total >= 240 & total < 270);   
cnt(3) = sum(total >= 210 & total < 240);     
cnt(4) = sum(total >= 180 & total < 210);    
cnt(5) = sum(total < 180);                    
labels = {'优秀(≥270)', '良好(240-269)', '中等(210-239)', '及格(180-209)', '不及格(<180)'};

figure(4);
subplot(1, 2, 1);
bar(cnt, 'FaceColor', 'flat', 'CData', ...
    [0.2 0.7 0.3; 0.3 0.6 0.9; 1 0.85 0.2; 1 0.55 0.1; 0.85 0.2 0.2]);
set(gca, 'XTickLabel', labels, 'XTickLabelRotation', 20, 'FontSize', 8);
title('成绩等级人数分布（柱状图）');
ylabel('人数'); grid on;

subplot(1, 2, 2);
pie(cnt, labels);
title('成绩等级人数分布（饼图）');