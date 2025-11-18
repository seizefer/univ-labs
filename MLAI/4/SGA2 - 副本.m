% SGA2.m
function [BestFitness, BestX, MinValues] = SGA2(NIND, MAXGEN, GGAP, NVAR, PRECI, RecOpt, SEL_OP, XOV_OP, MUT_OP, OBJ_F, FieldD)
    % 初始化
    Chrom = crtbp(NIND, NVAR * PRECI, 2);
    gen = 1;
    

     % 存储每一代的最小值
    MinValues = zeros(MAXGEN, 1);


    % 主循环
    while gen <= MAXGEN
        % 将二进制转换为实数得到输入x
        x = bs2rv(Chrom, FieldD);
        
        % 得到目标函数值
        ObjV = feval(OBJ_F, x);
        
        % 选择
        SelCh = select(SEL_OP, Chrom, ObjV, GGAP, 1);
        
        % 交叉
        NewChrom = recombin(XOV_OP, SelCh, RecOpt, 1);
        
        % 突变
        NewChrom = mutate(MUT_OP, NewChrom, FieldD, RecOpt / (NVAR * PRECI), 1);
        
        % 插入种群
        [Chrom, ObjV] = reins(Chrom, NewChrom, 1, 'mi', ObjV, ObjV);
        
        % 更新迭代次数
        gen = gen + 1;
    end
    
    % 将最终的结果转换为实数
    x = bs2rv(Chrom, FieldD);
    
    % 得到最终目标函数值
    ObjV = feval(OBJ_F, x);
    
    % 考虑约束条件
    Penalty = constraintPenalty(x);
    FitnV = ObjV + Penalty;

    % 找到最佳个体
    [BestFitness, minIndex] = min(FitnV);
    BestX = x(minIndex, :);
end
