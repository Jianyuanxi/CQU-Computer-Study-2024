function root = newton_sqrt(x0)
x = x0;
while true
    x_new = (x + 2/x) / 2;
    if abs(x_new - x) < 1e-5
        break;
    end
    x = x_new;
end
root = x_new;
fprintf('方程 x^2-2=0 的根为: %.10f\n', root);
end