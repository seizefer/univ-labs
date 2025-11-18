% constraintPenalty 函数
function Penalty = constraintPenalty(x)
    % 调用约束函数 PrG9c
    c = PrG9c(x);

    % 计算违反约束的惩罚
    Penalty = sum(max(0, c));
end
