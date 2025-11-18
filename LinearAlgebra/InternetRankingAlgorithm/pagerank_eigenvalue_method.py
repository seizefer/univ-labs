"""
使用特征值分解方法计算PageRank
"""
import numpy as np
import time


def pagerank_eigenvalue_method(adjacency_matrix, alpha=0.85):
    """
    使用特征值分解方法计算PageRank

    参数:
        adjacency_matrix: 邻接矩阵
        alpha: 阻尼因子

    返回:
        ranks: PageRank向量
        eigenvalue: 主特征值（应该接近1）
        computation_time: 计算时间（秒）
    """

    start_time = time.time()

    n = adjacency_matrix.shape[0]

    # 处理Dead Ends
    out_degree = np.sum(adjacency_matrix, axis=0)
    A = adjacency_matrix.copy().astype(float)

    for i in range(n):
        if out_degree[i] == 0:
            A[:, i] = np.ones(n)
            out_degree[i] = n

    # 构建转移概率矩阵 M
    M = np.zeros((n, n))
    for j in range(n):
        for i in range(n):
            if A[i, j] > 0:
                M[i, j] = 1.0 / out_degree[j]

    # 构建Google矩阵
    E = np.ones((n, n)) / n
    G = alpha * M + (1 - alpha) * E

    # 求解特征值和特征向量
    # PageRank是特征值为1的特征向量
    eigenvalues, eigenvectors = np.linalg.eig(G)

    # 找到最大特征值（应该是1或接近1）
    idx = np.argmax(np.real(eigenvalues))
    eigenvalue = np.real(eigenvalues[idx])

    # 提取对应的特征向量
    ranks = np.real(eigenvectors[:, idx])

    # 归一化为概率分布（确保和为1且为正）
    ranks = np.abs(ranks)
    ranks = ranks / np.sum(ranks)

    computation_time = time.time() - start_time

    print('Eigenvalue Method completed')
    print(f'Largest eigenvalue: {eigenvalue:.10f}')
    print(f'Computation time: {computation_time:.6f} seconds')

    # 验证特征值问题: G * v = lambda * v
    residual = np.linalg.norm(G @ ranks - eigenvalue * ranks)
    print(f'Eigenvalue equation residual: {residual:.2e}')

    return ranks, eigenvalue, computation_time


if __name__ == '__main__':
    # 测试
    from create_network import create_network

    print('Testing Eigenvalue Method...\n')
    A, names = create_network()

    print('\n' + '='*50)
    print('Running PageRank with alpha=0.85')
    print('='*50)

    ranks, eigenval, comp_time = pagerank_eigenvalue_method(A, alpha=0.85)

    print(f'\nTop 5 Pages by PageRank:')
    sorted_indices = np.argsort(ranks)[::-1]
    for i in range(5):
        idx = sorted_indices[i]
        print(f'{i+1}. {names[idx]:<20} PageRank = {ranks[idx]:.6f}')
