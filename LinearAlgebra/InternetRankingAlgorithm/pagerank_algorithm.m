function [ranks, iterations] = pagerank_algorithm(adjacency_matrix, damping_factor, tolerance, max_iterations)
    % PageRank算法实现
    % 输入参数:
    %   adjacency_matrix: 邻接矩阵，A(i,j)=1表示页面j链接到页面i
    %   damping_factor: 阻尼因子(通常为0.85)
    %   tolerance: 收敛容差
    %   max_iterations: 最大迭代次数
    % 输出参数:
    %   ranks: 各页面的PageRank值
    %   iterations: 实际迭代次数

    % 获取网页数量
    n = size(adjacency_matrix, 1);

    % 计算每个页面的出链数
    out_degree = sum(adjacency_matrix, 1);

    % 处理dead ends（没有出链的页面）
    % 将没有出链的页面连接到所有页面
    for i = 1:n
        if out_degree(i) == 0
            adjacency_matrix(:, i) = ones(n, 1);
            out_degree(i) = n;
        end
    end

    % 构建转移概率矩阵
    transition_matrix = zeros(n, n);
    for i = 1:n
        for j = 1:n
            if adjacency_matrix(i, j) > 0
                transition_matrix(i, j) = 1 / out_degree(j);
            end
        end
    end

    % 应用阻尼因子构建Google矩阵
    teleportation_matrix = ones(n, n) / n;
    google_matrix = damping_factor * transition_matrix + (1 - damping_factor) * teleportation_matrix;

    % 初始化PageRank向量（均匀分布）
    ranks = ones(n, 1) / n;

    % 幂迭代法求解
    for iteration = 1:max_iterations
        ranks_new = google_matrix * ranks;

        % 归一化
        ranks_new = ranks_new / sum(ranks_new);

        % 检查收敛性
        if norm(ranks_new - ranks, 1) < tolerance
            ranks = ranks_new;
            iterations = iteration;
            fprintf('Converged after %d iterations\n', iteration);
            return;
        end

        ranks = ranks_new;
    end

    iterations = max_iterations;
    fprintf('Reached maximum iterations: %d\n', max_iterations);
end
