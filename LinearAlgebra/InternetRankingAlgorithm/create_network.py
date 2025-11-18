"""
创建12个网页的学术网站链接结构
"""
import numpy as np


def create_network():
    """
    创建网络结构

    返回:
        adjacency_matrix: numpy数组，邻接矩阵，A[i,j]=1表示页面j链接到页面i
        page_names: 列表，网页名称
    """

    # 定义网页名称
    page_names = [
        'Homepage',           # 0
        'CS_Dept',           # 1
        'Math_Dept',         # 2
        'Library',           # 3
        'Course_Portal',     # 4
        'Linear_Algebra',    # 5
        'Data_Science',      # 6
        'Student_Resources', # 7
        'Research',          # 8
        'Faculty',           # 9
        'Admissions',        # 10
        'Alumni'             # 11
    ]

    n = len(page_names)
    adjacency_matrix = np.zeros((n, n), dtype=int)

    # 定义链接关系 (from -> to)
    # Homepage (0) 的出链
    adjacency_matrix[[1, 2, 3, 4, 10], 0] = 1

    # CS_Dept (1) 的出链
    adjacency_matrix[[0, 6, 8, 9], 1] = 1

    # Math_Dept (2) 的出链
    adjacency_matrix[[0, 5, 8, 9], 2] = 1

    # Library (3) 的出链
    adjacency_matrix[[0, 4, 8], 3] = 1

    # Course_Portal (4) 的出链
    adjacency_matrix[[0, 5, 6, 7], 4] = 1

    # Linear_Algebra (5) 的出链
    adjacency_matrix[[2, 4, 6, 7], 5] = 1

    # Data_Science (6) 的出链
    adjacency_matrix[[1, 4, 5, 7], 6] = 1

    # Student_Resources (7) 的出链
    adjacency_matrix[[0, 3, 4], 7] = 1

    # Research (8) 的出链
    adjacency_matrix[[0, 1, 2, 9], 8] = 1

    # Faculty (9) 的出链
    adjacency_matrix[[0, 1, 2, 8], 9] = 1

    # Admissions (10) 的出链
    adjacency_matrix[[0, 1, 2, 11], 10] = 1

    # Alumni (11) 的出链 - Dead End (没有出链)
    # adjacency_matrix[:, 11] = 0  # 已经是0

    print(f'Network created with {n} pages')
    print(f'Total links: {np.sum(adjacency_matrix)}')

    # 打印每个页面的入度和出度
    in_degree = np.sum(adjacency_matrix, axis=1)
    out_degree = np.sum(adjacency_matrix, axis=0)

    print('\nPage Statistics:')
    print(f'{"Page Name":<20} {"In-Degree":>10} {"Out-Degree":>10}')
    print(f'{"-"*20} {"-"*10} {"-"*10}')
    for i in range(n):
        dead_end_label = ' (Dead End)' if out_degree[i] == 0 else ''
        print(f'{page_names[i]:<20} {in_degree[i]:>10} {out_degree[i]:>10}{dead_end_label}')

    return adjacency_matrix, page_names


if __name__ == '__main__':
    # 测试网络创建
    A, names = create_network()
    print(f'\nAdjacency Matrix Shape: {A.shape}')
    print(f'Network Density: {np.sum(A) / (A.shape[0] ** 2):.4f}')
