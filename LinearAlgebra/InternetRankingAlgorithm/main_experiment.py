"""
PageRank算法主实验脚本
本脚本执行所有实验并保存结果
"""
import numpy as np
import pandas as pd
import pickle
from create_network import create_network
from pagerank_power_method import pagerank_power_method
from pagerank_eigenvalue_method import pagerank_eigenvalue_method


def main():
    print('=== PageRank Algorithm Experiments ===\n')

    # 实验1: 创建网络并分析结构
    print('Experiment 1: Network Creation and Analysis')
    print('-' * 44)
    A, page_names = create_network()
    n = len(page_names)

    # 实验2: 基础PageRank计算（alpha = 0.85）
    print('\n\nExperiment 2: Basic PageRank Computation')
    print('-' * 44)
    alpha = 0.85
    tolerance = 1e-8
    max_iter = 1000

    # 幂迭代法
    print('\n[Power Iteration Method]')
    ranks_power, history_power, iter_power = pagerank_power_method(
        A, alpha, tolerance, max_iter)

    # 特征值方法
    print('\n[Eigenvalue Method]')
    ranks_eigen, eigenval, time_eigen = pagerank_eigenvalue_method(A, alpha)

    # 比较两种方法的结果
    print('\n[Comparison of Two Methods]')
    diff_methods = np.max(np.abs(ranks_power - ranks_eigen))
    print(f'Maximum difference between methods: {diff_methods:.2e}')

    # 实验3: PageRank排名结果
    print('\n\nExperiment 3: PageRank Ranking Results')
    print('-' * 44)

    # 排序并显示
    sorted_indices = np.argsort(ranks_power)[::-1]
    sorted_ranks = ranks_power[sorted_indices]

    print(f'\n{"Rank":<5} {"Page Name":<20} {"PageRank":>15} {"Percentage":>12}')
    print(f'{"-"*5} {"-"*20} {"-"*15} {"-"*12}')
    for i in range(n):
        print(f'{i+1:<5} {page_names[sorted_indices[i]]:<20} '
              f'{sorted_ranks[i]:>15.6f} {sorted_ranks[i]*100:>11.2f}%')

    # 保存排名结果到CSV文件
    results_df = pd.DataFrame({
        'Rank': range(1, n+1),
        'PageName': [page_names[idx] for idx in sorted_indices],
        'PageRank': sorted_ranks,
        'Percentage': sorted_ranks * 100
    })
    results_df.to_csv('pagerank_results.csv', index=False)
    print('\nResults saved to: pagerank_results.csv')

    # 实验4: 阻尼因子影响分析
    print('\n\nExperiment 4: Damping Factor Sensitivity Analysis')
    print('-' * 44)

    alpha_values = [0.5, 0.75, 0.85, 0.95]
    ranks_alpha = np.zeros((n, len(alpha_values)))
    iterations_alpha = np.zeros(len(alpha_values), dtype=int)

    for i, alpha_test in enumerate(alpha_values):
        print(f'Testing alpha = {alpha_test:.2f}... ', end='')
        ranks_temp, _, iter_temp = pagerank_power_method(
            A, alpha_test, tolerance, max_iter)
        ranks_alpha[:, i] = ranks_temp
        iterations_alpha[i] = iter_temp

    print(f'\n{"Alpha":<8} {"Iterations":>12}')
    print(f'{"-"*8} {"-"*12}')
    for i, alpha_val in enumerate(alpha_values):
        print(f'{alpha_val:<8.2f} {iterations_alpha[i]:>12}')

    # 实验5: 收敛性分析
    print('\n\nExperiment 5: Convergence Analysis')
    print('-' * 44)

    # 使用alpha=0.85的收敛历史
    convergence_error = np.zeros(history_power.shape[1] - 1)
    for i in range(len(convergence_error)):
        convergence_error[i] = np.linalg.norm(
            history_power[:, i+1] - history_power[:, i], 1)

    print('Convergence rate analysis:')
    print(f'Iteration {1:5d}: Error = {convergence_error[0]:.2e}')
    if len(convergence_error) >= 10:
        print(f'Iteration {10:5d}: Error = {convergence_error[9]:.2e}')
    if len(convergence_error) >= 20:
        print(f'Iteration {20:5d}: Error = {convergence_error[19]:.2e}')
    print(f'Final iteration {iter_power}: Error = {convergence_error[iter_power-1]:.2e}')

    # 实验6: 网络结构分析
    print('\n\nExperiment 6: Network Structure Analysis')
    print('-' * 44)

    in_degree = np.sum(A, axis=0)
    out_degree = np.sum(A, axis=1)

    # 计算相关系数
    corr_in = np.corrcoef(in_degree, ranks_power)[0, 1]
    corr_out = np.corrcoef(out_degree, ranks_power)[0, 1]

    print(f'Correlation between In-Degree and PageRank: {corr_in:.4f}')
    print(f'Correlation between Out-Degree and PageRank: {corr_out:.4f}')

    # 保存网络分析结果
    network_analysis_df = pd.DataFrame({
        'PageName': page_names,
        'InDegree': in_degree,
        'OutDegree': out_degree,
        'PageRank': ranks_power
    })
    network_analysis_df.to_csv('network_analysis.csv', index=False)
    print('\nNetwork analysis saved to: network_analysis.csv')

    # 保存所有数据到pickle文件供可视化使用
    print('\n\nSaving all results to pickle file...')
    results_data = {
        'A': A,
        'page_names': page_names,
        'ranks_power': ranks_power,
        'ranks_eigen': ranks_eigen,
        'history_power': history_power,
        'convergence_error': convergence_error,
        'alpha_values': alpha_values,
        'ranks_alpha': ranks_alpha,
        'iterations_alpha': iterations_alpha,
        'in_degree': in_degree,
        'out_degree': out_degree,
        'sorted_indices': sorted_indices,
        'sorted_ranks': sorted_ranks
    }

    with open('pagerank_results.pkl', 'wb') as f:
        pickle.dump(results_data, f)
    print('All results saved to: pagerank_results.pkl')

    print('\n=== All Experiments Completed ===')


if __name__ == '__main__':
    main()
