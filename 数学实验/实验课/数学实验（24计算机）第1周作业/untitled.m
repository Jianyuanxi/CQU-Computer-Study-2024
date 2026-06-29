targets = [111, 1111, 11111];

for i = 1:length(targets)
    n = targets(i);
    fprintf('=== %d 的因数分解 ===\n', n);
    for a = 2:floor(sqrt(n))
        if mod(n, a) == 0
            b = n / a;
            fprintf('%d × %d = %d\n', a, b, n);
        end
    end
end