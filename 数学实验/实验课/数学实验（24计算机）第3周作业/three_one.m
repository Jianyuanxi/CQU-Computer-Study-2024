clc; clear; close all;

x0 = 0.5;     
maxIter = 100;  
tol = 1e-8;    

f  = @(x) x.^5 + 5*x.^3 - 2*x + 1;
df = @(x) 5*x.^4 + 15*x.^2 - 2;

gA = @(x) (x.^5 + 5*x.^3 + 1) / 2;

gB = @(x) sign((2*x - x.^5 - 1)/5) .* abs((2*x - x.^5 - 1)/5).^(1/3);

gC = @(x) x - f(x)./df(x);

labels = {'A: x=(x^5+5x^3+1)/2 (实习生1)', ...
          'B: x=((2x-x^5-1)/5)^{1/3} (实习生2)', ...
          'C: Newton法 x-f/f'' (老员工)'};
gFuncs = {gA, gB, gC};

results = cell(3,1);
figure('Position',[100,100,1200,400]);

for i = 1:3
    g = gFuncs{i};
    x = x0;
    history = x;
    converged = false;
    crashed = false;
    
    for k = 1:maxIter
        try
            xNew = g(x);
        catch
            crashed = true; break;
        end
        
        if ~isreal(xNew) || isnan(xNew) || abs(xNew) > 1e6
            crashed = true;
            history(end+1) = xNew; %#ok
            break;
        end
        
        history(end+1) = xNew; %#ok
        
        if abs(xNew - x) < tol
            converged = true;
            break;
        end
        x = xNew;
    end
    
    results{i}.history   = history;
    results{i}.converged = converged;
    results{i}.crashed   = crashed;
    results{i}.final     = history(end);
    
    % 绘图
    subplot(1,3,i);
    iters = 0:length(history)-1;
    vals = min(max(real(history), -20), 20);
    plot(iters, vals, 'b-o','MarkerSize',3,'LineWidth',1.2); hold on;
    xlabel('迭代次数'); ylabel('x_k');
    title(labels{i},'FontSize',9);
    grid on;
    
    if converged
        yline(real(history(end)),'r--','LineWidth',1.5);
        title([labels{i} newline '✓ 收敛 → x≈' num2str(real(history(end)),6)],'FontSize',8,'Color','b');
    elseif crashed
        title([labels{i} newline '✗ 发散/宕机！'],'FontSize',8,'Color','r');
    else
        title([labels{i} newline '? 未收敛'],'FontSize',8,'Color',[0.8 0.4 0]);
    end
end

sgtitle('三种迭代公式收敛性对比（x_0 = 0.5）','FontSize',12,'FontWeight','bold');

fprintf('\n========= 实验报告 =========\n');
fprintf('方程：x^5 + 5x^3 - 2x + 1 = 0，初始值 x0 = %.2f\n\n', x0);

for i = 1:3
    r = results{i};
    fprintf('公式%s：', char('A'+i-1));
    if r.converged
        fprintf('【收敛】迭代%d步，根 ≈ %.10f，残差 = %.2e\n', ...
            length(r.history)-1, real(r.final), abs(f(real(r.final))));
    elseif r.crashed
        fprintf('【发散/宕机】%d步后数值爆炸，末值 = %s\n', ...
            length(r.history)-1, num2str(r.final));
    else
        fprintf('【未收敛】%d步后未达精度，末值 = %.6f\n', ...
            length(r.history)-1, real(r.final));
    end
end

fprintf('\n--- fzero参考根 ---\n');
x_search = linspace(-3,3,300);
f_vals   = f(x_search);
for i = 1:length(x_search)-1
    if f_vals(i)*f_vals(i+1) < 0
        root = fzero(f, (x_search(i)+x_search(i+1))/2);
        fprintf('参考根：x ≈ %.10f，f(x)=%.2e\n', root, f(root));
    end
end