clc; clear;

f = -[193, 191, 187, 186, 180, 185]';

A = [
     0   0   0   0  -1  -1; 
     0   0  -1   0  -1   0;
     1   1   0   0   0   0; 
     0   1   0   0   0   1; 
     0   0   0   1   0   1 
];
b = [-1; -1; 1; 1; 1];

Aeq = [1 1 1 1 1 1];
beq = 3;

lb = zeros(6,1);
ub = ones(6,1);
intcon = 1:6;

[x, fval] = intlinprog(f, intcon, A, b, Aeq, beq, lb, ub);

fprintf('最优目标值 z = %.0f\n', -fval);
fprintf('最优解：x = [%d %d %d %d %d %d]\n', x);