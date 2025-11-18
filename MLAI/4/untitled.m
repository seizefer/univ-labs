% 定义参数
NIND = 50;           % 种群个体数目
MAXGEN = 20;         % 最大迭代次数
GGAP = 1;            % 生成新个体的比例
NVAR = 7;            % 决策变量个数
PRECI = 20;          % 二进制表示的精度
RecOpt = 0.7;        % 交叉概率
MUT_OP = 'mut';      % 突变算子
SEL_OP = 'sus';      % 选择算子
XOV_OP = 'xovsp';    % 交叉算子
OBJ_F = @PrG9f;      % 目标函数

% 变量范围及属性设置
FieldD = rep([PRECI, -10, 10, 1, 0, 1, 1]', [1, NVAR]);

% 初始染色体
Chrom = crtbp(NIND, NVAR * PRECI, 2);

gen = 1;  % 当前是第几代

% 记录最佳函数值
Best = zeros(MAXGEN, 1);

% 主循环
while gen <= MAXGEN
    % 将二进制基因转换为实数
    x = bs2rv(Chrom, FieldD);
    
    % 计算目标函数值
    ObjV = OBJ_F(x);
    
    % 记录最佳函数值
    Best(gen) = min(ObjV);
    
    % 选择算子
    FitnV = ranking(ObjV);
    SelCh = select(SEL_OP, Chrom, FitnV, GGAP);
    
    % 交叉算子
    SelCh = recombin(XOV_OP, SelCh, RecOpt);
    
    % 突变算子
    SelCh = mutate(MUT_OP, SelCh, []);
    
    % 将新个体插入原种群
    [Chrom, ObjV] = reins(Chrom, SelCh, 1, 1, ObjV, ObjV);
    
    % 更新代数
    gen = gen + 1;
end

% 输出结果
disp('最佳函数值:');
disp(Best);

% 画图展示收敛趋势
figure;
plot(1:MAXGEN, Best, '-o');
xlabel('代数');
ylabel('最佳函数值');
title('GA收敛趋势');

% 列出统计值
disp('统计值:');
disp(['最佳值: ', num2str(min(Best))]);
disp(['最差值: ', num2str(max(Best))]);
disp(['平均值: ', num2str(mean(Best))]);
disp(['中值: ', num2str(median(Best))]);
