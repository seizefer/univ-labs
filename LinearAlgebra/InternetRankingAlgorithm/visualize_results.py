"""
PageRank结果可视化脚本
生成所有实验图表
"""
import numpy as np
import matplotlib.pyplot as plt
import networkx as nx
import pickle

# 设置matplotlib支持中文显示（可选）
plt.rcParams['font.size'] = 12
plt.rcParams['figure.dpi'] = 100

# 加载实验结果
print('Loading experimental results...')
with open('pagerank_results.pkl', 'rb') as f:
    data = pickle.load(f)

A = data['A']
page_names = data['page_names']
ranks_power = data['ranks_power']
history_power = data['history_power']
convergence_error = data['convergence_error']
alpha_values = data['alpha_values']
ranks_alpha = data['ranks_alpha']
iterations_alpha = data['iterations_alpha']
in_degree = data['in_degree']
out_degree = data['out_degree']
sorted_indices = data['sorted_indices']
sorted_ranks = data['sorted_ranks']

n = len(page_names)

print('Generating visualizations...\n')

# 图1: 网络结构图
print('Generating Figure 1: Network Structure...')
fig1 = plt.figure(figsize=(12, 10))
G = nx.DiGraph()

# 添加节点
for i, name in enumerate(page_names):
    G.add_node(i, label=name)

# 添加边
for i in range(n):
    for j in range(n):
        if A[i, j] > 0:
            G.add_edge(j, i)

# 布局
pos = nx.spring_layout(G, k=2, iterations=50, seed=42)

# 根据PageRank调整节点大小和颜色
node_sizes = ranks_power * 10000 + 500
node_colors = ranks_power

# 绘制网络
nx.draw_networkx_edges(G, pos, alpha=0.3, arrows=True,
                       arrowsize=15, width=1.5, edge_color='gray')
nodes = nx.draw_networkx_nodes(G, pos, node_size=node_sizes,
                               node_color=node_colors, cmap='jet',
                               vmin=ranks_power.min(), vmax=ranks_power.max())

# 添加标签
labels = {i: name for i, name in enumerate(page_names)}
nx.draw_networkx_labels(G, pos, labels, font_size=9, font_weight='bold')

plt.colorbar(nodes, label='PageRank Value')
plt.title('Web Page Network Structure with PageRank', fontsize=16, fontweight='bold')
plt.axis('off')
plt.tight_layout()
plt.savefig('figure1_network_structure.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure1_network_structure.png')

# 图2: PageRank排名柱状图
print('Generating Figure 2: PageRank Ranking...')
fig2 = plt.figure(figsize=(14, 6))
bars = plt.bar(range(n), sorted_ranks, color='steelblue', alpha=0.8)

# 添加数值标签
for i, (idx, val) in enumerate(zip(sorted_indices, sorted_ranks)):
    plt.text(i, val + 0.003, f'{val:.4f}', ha='center', va='bottom', fontsize=10)

plt.xticks(range(n), [page_names[idx] for idx in sorted_indices],
           rotation=45, ha='right')
plt.ylabel('PageRank Value', fontsize=14)
plt.title('PageRank Ranking of Web Pages (alpha = 0.85)', fontsize=16, fontweight='bold')
plt.grid(axis='y', alpha=0.3)
plt.ylim(0, max(sorted_ranks) * 1.15)
plt.tight_layout()
plt.savefig('figure2_pagerank_ranking.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure2_pagerank_ranking.png')

# 图3: 收敛曲线
print('Generating Figure 3: Convergence Curve...')
fig3 = plt.figure(figsize=(10, 6))
plt.semilogy(range(1, len(convergence_error) + 1), convergence_error,
             'b-o', linewidth=2, markersize=5, label='Convergence Error')
plt.axhline(y=1e-8, color='r', linestyle='--', linewidth=2,
            label='Tolerance = $10^{-8}$')
plt.xlabel('Iteration Number', fontsize=14)
plt.ylabel('L1 Norm of Difference (log scale)', fontsize=14)
plt.title('Convergence of Power Iteration Method (alpha = 0.85)',
          fontsize=16, fontweight='bold')
plt.legend(fontsize=12)
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('figure3_convergence_curve.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure3_convergence_curve.png')

# 图4: 阻尼因子影响 - 排名变化
print('Generating Figure 4: Damping Factor Effect...')
fig4 = plt.figure(figsize=(12, 7))
top_pages = 5

for i in range(top_pages):
    page_idx = sorted_indices[i]
    plt.plot(alpha_values, ranks_alpha[page_idx, :], '-o',
             linewidth=2, markersize=8, label=page_names[page_idx])

plt.xlabel('Damping Factor (alpha)', fontsize=14)
plt.ylabel('PageRank Value', fontsize=14)
plt.title('Effect of Damping Factor on Top Pages', fontsize=16, fontweight='bold')
plt.legend(fontsize=11, loc='best')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('figure4_damping_factor_effect.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure4_damping_factor_effect.png')

# 图5: 阻尼因子与收敛速度
print('Generating Figure 5: Convergence Speed...')
fig5 = plt.figure(figsize=(10, 6))
bars = plt.bar(alpha_values, iterations_alpha, color='coral', alpha=0.8, width=0.08)

# 添加数值标签
for alpha, iters in zip(alpha_values, iterations_alpha):
    plt.text(alpha, iters + 1, str(iters), ha='center', va='bottom',
             fontsize=12, fontweight='bold')

plt.xlabel('Damping Factor (alpha)', fontsize=14)
plt.ylabel('Number of Iterations to Converge', fontsize=14)
plt.title('Convergence Speed vs Damping Factor', fontsize=16, fontweight='bold')
plt.grid(axis='y', alpha=0.3)
plt.ylim(0, max(iterations_alpha) * 1.15)
plt.tight_layout()
plt.savefig('figure5_convergence_speed.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure5_convergence_speed.png')

# 图6: 入度/出度与PageRank的关系
print('Generating Figure 6: Degree vs PageRank...')
fig6, (ax1, ax2) = plt.subplots(1, 2, figsize=(16, 6))

# 子图1: 入度 vs PageRank
ax1.scatter(in_degree, ranks_power, s=150, c='steelblue', alpha=0.7, edgecolors='black')
for i in range(n):
    ax1.text(in_degree[i] + 0.1, ranks_power[i], page_names[i], fontsize=9)

# 拟合线
z = np.polyfit(in_degree, ranks_power, 1)
p = np.poly1d(z)
x_fit = np.linspace(in_degree.min(), in_degree.max(), 100)
ax1.plot(x_fit, p(x_fit), 'r--', linewidth=2, label='Linear Fit')

corr_in = np.corrcoef(in_degree, ranks_power)[0, 1]
ax1.set_xlabel('In-Degree', fontsize=14)
ax1.set_ylabel('PageRank Value', fontsize=14)
ax1.set_title(f'In-Degree vs PageRank (Corr = {corr_in:.4f})',
              fontsize=14, fontweight='bold')
ax1.grid(True, alpha=0.3)
ax1.legend()

# 子图2: 出度 vs PageRank
ax2.scatter(out_degree, ranks_power, s=150, c='coral', alpha=0.7, edgecolors='black')
for i in range(n):
    ax2.text(out_degree[i] + 0.1, ranks_power[i], page_names[i], fontsize=9)

# 拟合线
z = np.polyfit(out_degree, ranks_power, 1)
p = np.poly1d(z)
x_fit = np.linspace(out_degree.min(), out_degree.max(), 100)
ax2.plot(x_fit, p(x_fit), 'r--', linewidth=2, label='Linear Fit')

corr_out = np.corrcoef(out_degree, ranks_power)[0, 1]
ax2.set_xlabel('Out-Degree', fontsize=14)
ax2.set_ylabel('PageRank Value', fontsize=14)
ax2.set_title(f'Out-Degree vs PageRank (Corr = {corr_out:.4f})',
              fontsize=14, fontweight='bold')
ax2.grid(True, alpha=0.3)
ax2.legend()

plt.tight_layout()
plt.savefig('figure6_degree_vs_pagerank.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure6_degree_vs_pagerank.png')

# 图7: PageRank值的迭代演化
print('Generating Figure 7: PageRank Evolution...')
fig7 = plt.figure(figsize=(12, 7))

selected_pages = [sorted_indices[0], sorted_indices[5], sorted_indices[11]]
colors = ['red', 'green', 'blue']

for i, (page_idx, color) in enumerate(zip(selected_pages, colors)):
    iterations = range(history_power.shape[1])
    plt.plot(iterations, history_power[page_idx, :],
             color=color, linewidth=2, label=page_names[page_idx])

plt.xlabel('Iteration Number', fontsize=14)
plt.ylabel('PageRank Value', fontsize=14)
plt.title('Evolution of PageRank Values During Iteration',
          fontsize=16, fontweight='bold')
plt.legend(fontsize=12, loc='best')
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('figure7_pagerank_evolution.png', dpi=300, bbox_inches='tight')
plt.close()
print('Saved: figure7_pagerank_evolution.png')

print('\n=== All visualizations completed ===')
print('Total figures generated: 7')
