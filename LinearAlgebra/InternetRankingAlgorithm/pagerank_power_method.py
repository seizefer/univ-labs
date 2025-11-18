"""
使用幂迭代法计算PageRank
"""
import numpy as np


def pagerank_power_method(adjacency_matrix, alpha=0.85, tolerance=1e-8, max_iter=1000):
    """
    使用幂迭代法计算PageRank

    参数:
        adjacency_matrix: 邻接矩阵
        alpha: 阻尼因子 (damping factor)
        tolerance: 收敛容差
        max_iter: 最大迭代次数

    返回:
        ranks: PageRank向量
        history: 每次迭代的rank值历史
        iterations: 实际迭代次数
    """

    n = adjacency_matrix.shape[0]

    # 处理Dead Ends: 将没有出链的页面连接到所有页面
    out_degree = np.sum(adjacency_matrix, axis=0)
    A = adjacency_matrix.copy().astype(float)

    for i in range(n):
        if out_degree[i] == 0:
            A[:, i] = np.ones(n)
            out_degree[i] = n

    # 构建转移概率矩阵 M
    # M[i,j] = 1/out_degree[j] 如果j链接到i
    M = np.zeros((n, n))
    for j in range(n):
        for i in range(n):
            if A[i, j] > 0:
                M[i, j] = 1.0 / out_degree[j]

    # 验证M是列随机矩阵
    col_sums = np.sum(M, axis=0)
    if np.max(np.abs(col_sums - 1)) > 1e-10:
        print(f'Warning: Transition matrix is not column stochastic!')
        print(f'Max column sum deviation: {np.max(np.abs(col_sums - 1))}')

    # 构建Google矩阵: G = alpha * M + (1 - alpha) * E
    # E是每个元素为1/n的矩阵（传送矩阵）
    E = np.ones((n, n)) / n
    G = alpha * M + (1 - alpha) * E

    # 初始化PageRank向量（均匀分布）
    ranks = np.ones(n) / n
    history = np.zeros((n, max_iter + 1))
    history[:, 0] = ranks

    # 幂迭代法
    for iteration in range(1, max_iter + 1):
        ranks_new = G @ ranks

        # 归一化（理论上不需要，但为了数值稳定性）
        ranks_new = ranks_new / np.sum(ranks_new)

        # 保存历史
        history[:, iteration] = ranks_new

        # 检查收敛性（使用L1范数）
        diff = np.linalg.norm(ranks_new - ranks, 1)

        if diff < tolerance:
            ranks = ranks_new
            iterations = iteration
            history = history[:, :iteration+1]
            print(f'Power Method converged after {iteration} iterations')
            print(f'Final difference: {diff:.2e}')
            return ranks, history, iterations

        ranks = ranks_new

    # 如果达到最大迭代次数
    iterations = max_iter
    history = history[:, :max_iter+1]
    final_diff = np.linalg.norm(history[:, -1] - history[:, -2], 1)
    print(f'Power Method reached maximum iterations: {max_iter}')
    print(f'Final difference: {final_diff:.2e}')

    return ranks, history, iterations


if __name__ == '__main__':
    # 测试
    from create_network import create_network

    print('Testing Power Method...\n')
    A, names = create_network()

    print('\n' + '='*50)
    print('Running PageRank with alpha=0.85')
    print('='*50)

    ranks, history, iters = pagerank_power_method(A, alpha=0.85)

    print(f'\nTop 5 Pages by PageRank:')
    sorted_indices = np.argsort(ranks)[::-1]
    for i in range(5):
        idx = sorted_indices[i]
        print(f'{i+1}. {names[idx]:<20} PageRank = {ranks[idx]:.6f}')
