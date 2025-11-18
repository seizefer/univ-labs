% SGA2.m
function [BestFitness, BestX, MinValues] = SGA2(NIND, MAXGEN, GGAP, NVAR, PRECI, RecOpt, SEL_OP, XOV_OP, MUT_OP, OBJ_F, FieldD)
    % 初始化

for run = 1:20

    Chrom = crtbp(NIND, Lind, 2);
    gen = 1;

    % 存储每一代的最小值
    MinValues = zeros(MAXGEN, 1);

    % 主循环
    while gen <= MAXGEN

        % 将二进制转换为实数得到输入x
        x = bs2rv(Chrom, FieldD);

        % 计算目标函数值
        for i = 1:NIND
            ObjV(i,:) = PrG9f(x(i,:));
        end
        
        % 计算适应度，使用 ranking 函数
        FitnV = ranking(ObjV);

        % 存储当前代的最小值
        % MinValues(gen) = min(FitnV);

        % 选择
        SelCh = select(SEL_OP, Chrom, FitnV, GGAP, 1);  % 强制将FitnV转换为列向量

        % 交叉
        NewChrom = recombin(XOV_OP, SelCh, RecOpt, 1);

        % 突变
        NewChrom = mutate(MUT_OP, NewChrom, FieldD, Pm, 1);

        ObjVChild = ObjV;

        %Calculate objective function value
        Phen = bs2rv(SelCh, FieldD);
        for i = 1:NIND
            ObjV(i,:) = PrG9f(Phen(i,:));
        end

        %Elitism
        [Selch, ObjVCh] = reins(Chrom, SelCh, 1, 1, ObjVCh, ObjVSel);

        %Refresh population,replace parent with children
        Chrom = SelCh;

        % 更新迭代次数
        gen = gen + 1;

    end


    All_Best(:, run) = Best;

end

    % 将最终的结果转换为实数
    x = bs2rv(Chrom, FieldD);

    % 得到最终目标函数值
    ObjV = feval(OBJ_F, x);

    
    % 计算最终适应度
    FitnV = ranking(ObjV + Penalty);

    % 找到最佳个体
    [BestFitness, minIndex] = min(FitnV);
    BestX = x(minIndex, :);
end
