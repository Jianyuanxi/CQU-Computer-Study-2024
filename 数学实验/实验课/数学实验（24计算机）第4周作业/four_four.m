clc; clear;

r1 = 0.0145;
r2 = 0.0165;
r3 = 0.0195; 
r5 = 0.0200; 

fprintf('利率：1年%.2f%% 2年%.2f%% 3年%.2f%% 5年%.2f%%\n\n', ...
        r1*100, r2*100, r3*100, r5*100);

best_value = 0;
best_plan = [0,0,0,0];

for x5 = 0:6  
    for x3 = 0:11
        for x2 = 0:16 
            x1 = 33 - 5*x5 - 3*x3 - 2*x2; 
            if x1 >= 0
                total = (1+r1)^(1*x1) * (1+r2)^(2*x2) * ...
                        (1+r3)^(3*x3) * (1+r5)^(5*x5);
                if total > best_value
                    best_value = total;
                    best_plan = [x1, x2, x3, x5];
                end
            end
        end
    end
end

fprintf('最优存款方案：\n');
fprintf('1年期%d次，2年期%d次，3年期%d次，5年期%d次\n', best_plan);
fprintf('\n本金1元，33年后本息和：%.4f元\n', best_value);
fprintf('总收益率：%.2f%%\n', (best_value-1)*100);
fprintf('年均复合收益率：%.4f%%\n\n', (best_value^(1/33)-1)*100);