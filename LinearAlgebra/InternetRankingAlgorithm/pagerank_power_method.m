function [ranks, history, iterations] = pagerank_power_method(adjacency_matrix, alpha, tolerance, max_iter)
    % 使用幂迭代法计算PageRank
    % 输入:
    %   adjacency_matrix: 邻接矩阵
    %   alpha: 阻尼因子 (damping factor)
    %   tolerance: 收敛容差
    %   max_iter: 最大迭代次数
    % 输出:
    %   ranks: PageRank向量
    %   history: 每次迭代的rank值历史
    %   iterations: 实际迭代次数

    n = size(adjacency_matrix, 1);

    % 处理Dead Ends: 将没有出链的页面连接到所有页面
    out_degree = sum(adjacency_matrix, 1);
    A = adjacency_matrix;
    for i = 1:n
        if out_degree(i) == 0
            A(:, i) = ones(n, 1);
            out_degree(i) = n;
        end
    end

    % 构建转移概率矩阵 M
    % M(i,j) = 1/out_degree(j) 如果j链接到i
    M = zeros(n, n);
    for j = 1:n
        for i = 1:n
            if A(i, j) > 0
                M(i, j) = 1 / out_degree(j);
            end
        end
    end

    % 验证M是列随机矩阵
    col_sums = sum(M, 1);
    if max(abs(col_sums - 1)) > 1e-10
        warning('Transition matrix is not column stochastic!');
    end

    % 构建Google矩阵: G = alpha * M + (1 - alpha) * E
    % E是每个元素为1/n的矩阵（传送矩阵）
    E = ones(n, n) / n;
    G = alpha * M + (1 - alpha) * E;

    % 初始化PageRank向量（均匀分布）
    ranks = ones(n, 1) / n;
    history = zeros(n, max_iter + 1);
    history(:, 1) = ranks;

    % 幂迭代法
    for iter = 1:max_iter
        ranks_new = G * ranks;

        % 归一化（理论上不需要，但为了数值稳定性）
        ranks_new = ranks_new / sum(ranks_new);

        % 保存历史
        history(:, iter + 1) = ranks_new;

        % 检查收敛性（使用L1范数）
        diff = norm(ranks_new - ranks, 1);

        if diff < tolerance
            ranks = ranks_new;
            iterations = iter;
            history = history(:, 1:iter+1);
            fprintf('Power Method converged after %d iterations\n', iter);
            fprintf('Final difference: %.2e\n', diff);
            return;
        end

        ranks = ranks_new;
    end

    % 如果达到最大迭代次数
    iterations = max_iter;
    history = history(:, 1:max_iter+1);
    fprintf('Power Method reached maximum iterations: %d\n', max_iter);
    fprintf('Final difference: %.2e\n', norm(history(:, end) - history(:, end-1), 1));
end
