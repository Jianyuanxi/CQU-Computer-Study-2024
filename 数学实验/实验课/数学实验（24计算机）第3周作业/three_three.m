clc; clear; close all;

L  = @(w1,w2) w1.^2 + w2.^2 - 10*cos(2*pi*w1) - 10*cos(2*pi*w2) + 20;

g1 = @(w1) 2*w1 + 20*pi*sin(2*pi*w1);
g2 = @(w2) 2*w2 + 20*pi*sin(2*pi*w2);

rng(42);
n_init = 100;
w1_init = -2 + 4*rand(n_init,1);
w2_init = -2 + 4*rand(n_init,1);

stationary_pts = [];
tol_root = 1e-6;
tol_dup  = 1e-4;

options = optimoptions('fsolve','Display','off','TolFun',1e-12,'TolX',1e-12);

for i = 1:n_init
    try
        sol = fsolve(@(w)[g1(w(1)); g2(w(2))], [w1_init(i); w2_init(i)], options);
        if abs(sol(1))>2.5 || abs(sol(2))>2.5, continue; end
        res = norm([g1(sol(1)); g2(sol(2))]);
        if res > 1e-6, continue; end
        is_dup = false;
        for j = 1:size(stationary_pts,1)
            if norm(sol - stationary_pts(j,:)') < tol_dup
                is_dup = true; break;
            end
        end
        if ~is_dup
            stationary_pts(end+1,:) = sol'; %#ok
        end
    catch
    end
end

fprintf('找到 %d 个不同驻点\n', size(stationary_pts,1));


d2L_dw1 = @(w1) 2 + 40*pi^2*cos(2*pi*w1);
d2L_dw2 = @(w2) 2 + 40*pi^2*cos(2*pi*w2);

n_pts = size(stationary_pts,1);
types  = cell(n_pts,1);
lambda1_all = zeros(n_pts,1);
lambda2_all = zeros(n_pts,1);

fprintf('\n%-5s %-10s %-10s %-12s %-12s %-15s\n','#','w1','w2','λ1','λ2','类型');
fprintf('%s\n', repmat('-',1,65));

for i = 1:n_pts
    w1s = stationary_pts(i,1);
    w2s = stationary_pts(i,2);
    
    lam1 = d2L_dw1(w1s);
    lam2 = d2L_dw2(w2s);
    lambda1_all(i) = lam1;
    lambda2_all(i) = lam2;
    
    if lam1 > 0 && lam2 > 0
        types{i} = '极小值点';
    elseif lam1 < 0 && lam2 < 0
        types{i} = '极大值点';
    else
        types{i} = '鞍点';
    end
    
    fprintf('%-5d %-10.4f %-10.4f %-12.4f %-12.4f %-15s\n', ...
        i, w1s, w2s, lam1, lam2, types{i});
end

figure('Position',[50,50,1100,500]);

subplot(1,2,1);
[W1,W2] = meshgrid(linspace(-2,2,200), linspace(-2,2,200));
LVal = L(W1,W2);

surf(W1, W2, LVal, 'EdgeColor','none','FaceAlpha',0.75);
colormap(parula);
hold on;

h_min=[]; h_sad=[]; h_max=[];
for i = 1:n_pts
    w1s = stationary_pts(i,1);
    w2s = stationary_pts(i,2);
    Lval_pt = L(w1s, w2s);
    
    if strcmp(types{i},'极小值点')
        h = plot3(w1s, w2s, Lval_pt+0.5, 'g^','MarkerSize',10,'MarkerFaceColor','g','LineWidth',1.5);
        if isempty(h_min), h_min=h; end
    elseif strcmp(types{i},'鞍点')
        h = plot3(w1s, w2s, Lval_pt+0.5, 'rv','MarkerSize',10,'MarkerFaceColor','r','LineWidth',1.5);
        if isempty(h_sad), h_sad=h; end
    else
        h = plot3(w1s, w2s, Lval_pt+0.5, 'bs','MarkerSize',8,'MarkerFaceColor','b');
        if isempty(h_max), h_max=h; end
    end
end

xlabel('w_1','FontSize',11); ylabel('w_2','FontSize',11); zlabel('L(w_1,w_2)','FontSize',11);
title('损失函数曲面（Rastrigin变体）','FontSize',12,'FontWeight','bold');
handles = []; labs = {};
if ~isempty(h_min), handles(end+1)=h_min; labs{end+1}='极小值点'; end
if ~isempty(h_sad), handles(end+1)=h_sad; labs{end+1}='鞍点'; end
if ~isempty(h_max), handles(end+1)=h_max; labs{end+1}='极大值点'; end
legend(handles, labs,'Location','northeast','FontSize',9);
view(45,30); colorbar;

subplot(1,2,2);
imagesc(linspace(-2,2,200), linspace(-2,2,200), LVal);
set(gca,'YDir','normal'); colormap(parula); colorbar; hold on;

h_min2=[]; h_sad2=[]; h_max2=[];
for i = 1:n_pts
    w1s = stationary_pts(i,1);
    w2s = stationary_pts(i,2);
    if strcmp(types{i},'极小值点')
        h = plot(w1s, w2s, 'g^','MarkerSize',10,'MarkerFaceColor','g','LineWidth',1.5);
        if isempty(h_min2), h_min2=h; end
    elseif strcmp(types{i},'鞍点')
        h = plot(w1s, w2s, 'rv','MarkerSize',10,'MarkerFaceColor','r','LineWidth',1.5);
        if isempty(h_sad2), h_sad2=h; end
    else
        h = plot(w1s, w2s, 'bs','MarkerSize',8,'MarkerFaceColor','b');
        if isempty(h_max2), h_max2=h; end
    end
end

xlabel('w_1','FontSize',11); ylabel('w_2','FontSize',11);
title('驻点分布俯视图','FontSize',12,'FontWeight','bold');
handles2=[]; labs2={};
if ~isempty(h_min2), handles2(end+1)=h_min2; labs2{end+1}='极小值点'; end
if ~isempty(h_sad2), handles2(end+1)=h_sad2; labs2{end+1}='鞍点'; end
if ~isempty(h_max2), handles2(end+1)=h_max2; labs2{end+1}='极大值点'; end
legend(handles2, labs2,'Location','southeast','FontSize',9);

n_min   = sum(strcmp(types,'极小值点'));
n_saddle= sum(strcmp(types,'鞍点'));
n_max   = sum(strcmp(types,'极大值点'));
fprintf('\n====== 驻点统计 ======\n');
fprintf('极小值点：%d 个\n', n_min);
fprintf('鞍    点：%d 个\n', n_saddle);
fprintf('极大值点：%d 个\n', n_max);
fprintf('合    计：%d 个\n', n_min+n_saddle+n_max);

fprintf('\n=== 关于"动量（Momentum）"机制的说明 ===\n');
fprintf(['在高维非凸损失平面中，梯度下降容易在鞍点附近停滞（梯度极小但非零）。\n'...
         '动量机制引入历史梯度的指数加权平均：v_{t+1} = βv_t + ∇L\n'...
         '在鞍点处，某方向梯度符号持续一致，动量积累后能越过平坦区；\n'...
         '而随机噪声和动量的组合能逃离鞍点，最终收敛到极小值点。\n']);