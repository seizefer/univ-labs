%% parameter setting  

    NIND   = XXX;          % Number of individuals per subpopulations
    MAXGEN = XXX;          % Maximum Number of generations
    GGAP   = 1;            % Generation gap, how many new individuals are created (default 1)
    NVAR   = 7;           % Number of decision variables
    PRECI  = 20;           % Precision of binary representation (default 20)
    RecOpt = 0.7;          % Probability of recombination/crossover (default 0.7)
    Lind   = NVAR*PRECI;   % Length of the individual chromosomes
    Pm     = 0.7/Lind;     % Mutation probability （default 0.7）
    SEL_OP = 'sus';        % Selection operator
    XOV_OP = 'xovsp';      % Crossover operator
    MUT_OP = 'mut';        % Crossover operator
    OBJ_F =  'PrG9f';     % Object function


    
% FieldD的定义，这里假设每个变量都有相同的设置
FieldD = rep([PRECI, -10, 10, 1, 0, 1, 1]', [1, NVAR]);

% Chrom的初始化，利用crtbp生成初始染色体
Chrom = crtbp(NIND, NVAR * PRECI, 2);

% 当前是第几代
gen = 1;

% 将二进制转换为实数得到输入x
x = bs2rv(Chrom, FieldD);

% 得到第一代对应目标函数值
ObjV = feval(OBJ_F, x);

% 记录最佳函数值的初始化，这里假设第一代就是最佳的
BestFitness = min(ObjV);

% 如果需要记录最佳个体，也需要记录对应的x
minIndex = find(ObjV == BestFitness);
BestX = x(minIndex, :);




[BestX, BestFitness, Convergence] = SGA(NIND, MAXGEN, NVAR, PRECI, RecOpt, MUT_OP, SEL_OP, OBJ_F);

disp('Optimal Solution:');
disp(BestX);
disp(['Optimal Value: ', num2str(BestFitness)]);

figure;
plot(1:MAXGEN, Convergence, 'LineWidth', 2);
xlabel('Generation');
ylabel('Objective Function Value');
title('Convergence of SGA');
grid on;




function [BestX, BestFitness, Convergence] = SGA(NIND, MAXGEN, NVAR, PRECI, RecOpt, MUT_OP, SEL_OP, OBJ_F)
    % Initialize population
    Chrom = crtbp(NIND, NVAR * PRECI, 2);

    % Evaluate initial population
    ObjV = feval(OBJ_F, bs2rv(Chrom, rep([PRECI,-10,10,1,0,1,1]', [1,NVAR])));

    % Main loop
    Convergence = zeros(1, MAXGEN);
    for gen = 1:MAXGEN
        % Select individuals for reproduction
        FitnV = ranking(ObjV);
        SelCh = select(SEL_OP, Chrom, FitnV, 1, 1);

        % Recombination
        NewChrom = recombin('xovdp', SelCh, RecOpt, 1);

        % Mutation
        NewChrom = mutate(MUT_OP, NewChrom, [PRECI,-10,10,1,0,1,1], 0.7 / (NVAR * PRECI), 1);

        % Evaluate new population
        ObjVSel = feval(OBJ_F, bs2rv(SelCh, rep([PRECI,-10,10,1,0,1,1]', [1,NVAR])));
        [Chrom, ObjV] = reins(Chrom, NewChrom, 1, 'ascend', ObjV, ObjVSel);

        % Record best individual and convergence
        [~, minIndex] = min(ObjV);
        BestX = bs2rv(Chrom(minIndex, :), rep([PRECI,-10,10,1,0,1,1]', [1,NVAR]));
        BestFitness = ObjV(minIndex);
        Convergence(gen) = BestFitness;
    end
end



