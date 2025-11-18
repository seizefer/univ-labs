function [ranks, eigenvalue, computation_time] = pagerank_eigenvalue_method(adjacency_matrix, alpha)
    % 使用特征值分解方法计算PageRank
    % 输入:
    %   adjacency_matrix: 邻接矩阵
    %   alpha: 阻尼因子
    % 输出:
    %   ranks: PageRank向量
    %   eigenvalue: 主特征值（应该接近1）
    %   computation_time: 计算时间（秒）

    tic; % 开始计时

    n = size(adjacency_matrix, 1);

    % 处理Dead Ends
    out_degree = sum(adjacency_matrix, 1);
    A = adjacency_matrix;
    for i = 1:n
        if out_degree(i) == 0
            A(:, i) = ones(n, 1);
            out_degree(i) = n;
        end
    end

    % 构建转移概率矩阵 M
    M = zeros(n, n);
    for j = 1:n
        for i = 1:n
            if A(i, j) > 0
                M(i, j) = 1 / out_degree(j);
            end
        end
    end

    % 构建Google矩阵
    E = ones(n, n) / n;
    G = alpha * M + (1 - alpha) * E;

    % 求解特征值和特征向量
    % PageRank是特征值为1的特征向量
    [V, D] = eig(G);

    % 找到最大特征值（应该是1或接近1）
    eigenvalues = diag(D);
    [eigenvalue, idx] = max(real(eigenvalues));

    % 提取对应的特征向量
    ranks = real(V(:, idx));

    % 归一化为概率分布（确保和为1且为正）
    ranks = abs(ranks);
    ranks = ranks / sum(ranks);

    computation_time = toc; % 结束计时

    fprintf('Eigenvalue Method completed\n');
    fprintf('Largest eigenvalue: %.10f\n', eigenvalue);
    fprintf('Computation time: %.6f seconds\n', computation_time);

    % 验证特征值问题: G * v = lambda * v
    residual = norm(G * ranks - eigenvalue * ranks);
    fprintf('Eigenvalue equation residual: %.2e\n', residual);
end
