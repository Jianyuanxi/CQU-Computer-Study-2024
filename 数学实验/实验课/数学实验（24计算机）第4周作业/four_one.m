clc; clear;
f = -[2, 9, 10, 7, 1, 3, 4, 2, 8, 4, 2, 5]';

Aeq = [
    1 1 1 1 0 0 0 0 0 0 0 0; 
    0 0 0 0 1 1 1 1 0 0 0 0;
    0 0 0 0 0 0 0 0 1 1 1 1;
    1 0 0 0 1 0 0 0 1 0 0 0;
    0 1 0 0 0 1 0 0 0 1 0 0;
    0 0 1 0 0 0 1 0 0 0 1 0;
    0 0 0 1 0 0 0 1 0 0 0 1
];
beq = [9; 5; 7; 3; 8; 4; 6];

lb = zeros(12, 1);

options = optimoptions('linprog', 'Display', 'off');
[x, fval] = linprog(f, [], [], Aeq, beq, lb, [], options);

fprintf('最优目标值 z = %.2f\n\n', -fval);

fprintf('最优运输方案：\n');
fprintf('       销地1  销地2  销地3  销地4\n');
X = reshape(x, 4, 3)';
for i = 1:3
    fprintf('产地%d: ', i);
    fprintf('%6.2f ', X(i,:));
    fprintf('\n');
end
fprintf('\n');