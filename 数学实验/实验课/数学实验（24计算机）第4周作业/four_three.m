clc; clear;

objfun = @(x) -(0.201 * x(1)^4 * x(2) * x(3)^2 / 1e7);

nonlcon = @(x) deal([x(1)^2 * x(2) - 675;
                     x(1)^2 * x(3)^2 / 1e7 - 0.419], ...
                    []);

lb = [0; 0; 0];
ub = [36; 5; 125];

x0 = [10; 2; 50];

options = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'sqp');
[x, fval] = fmincon(objfun, x0, [], [], [], [], lb, ub, nonlcon, options);

fprintf('最优目标值 z = %.6f\n\n', -fval);
fprintf('最优解：\n');
fprintf('x1 = %.4f\n', x(1));
fprintf('x2 = %.4f\n', x(2));
fprintf('x3 = %.4f\n', x(3));
fprintf('\n约束验证：\n');
fprintf('675 - x1²·x2 = %.4f (应≥0)\n', 675 - x(1)^2 * x(2));
fprintf('0.419 - x1²·x3²/10⁷ = %.6f (应≥0)\n', 0.419 - x(1)^2 * x(3)^2 / 1e7);
fprintf('\n');