"""
Lab 4 - Genetic Algorithm for Constrained Optimization
基于遗传算法的约束优化 - G9问题

使用遗传算法优化G9约束优化问题
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import differential_evolution
from deap import base, creator, tools, algorithms
import random


class G9Problem:
    """G9约束优化问题"""

    def __init__(self, penalty_factor=10000):
        self.n_vars = 7
        self.bounds = [(-10, 10)] * self.n_vars
        self.penalty_factor = penalty_factor
        self.global_optimum = 680.63

    def objective(self, x):
        """目标函数"""
        f = ((x[0]-10)**2 + 5*(x[1]-12)**2 + x[2]**4 + 3*(x[3]-11)**2 +
             10*x[4]**6 + 7*x[5]**2 + x[6]**4 - 4*x[5]*x[6] - 10*x[5] - 8*x[6])
        return f

    def constraints(self, x):
        """约束函数 g(x) <= 0"""
        g = np.zeros(4)
        g[0] = 2*x[0]**2 + 3*x[1]**4 + x[2] + 4*x[3]**2 + 5*x[4] - 127
        g[1] = 7*x[0] + 3*x[1] + 10*x[2]**2 + x[3] - x[4] - 282
        g[2] = 23*x[0] + x[1]**2 + 6*x[5]**2 - 8*x[6] - 196
        g[3] = 4*x[0]**2 + x[1]**2 - 3*x[0]*x[1] + 2*x[2]**2 + 5*x[5] - 11*x[6]
        return g

    def penalized_objective(self, x):
        """带惩罚的目标函数"""
        f_obj = self.objective(x)
        g = self.constraints(x)

        # 计算约束违反
        violation = np.sum(np.maximum(0, g))

        # 惩罚函数
        f_penalized = f_obj + self.penalty_factor * violation

        return f_penalized

    def check_constraints(self, x):
        """检查约束是否满足"""
        g = self.constraints(x)
        return np.all(g <= 0)


class GeneticAlgorithmOptimizer:
    """遗传算法优化器"""

    def __init__(self, problem, pop_size=200, max_gen=300,
                 crossover_prob=0.8, mutation_prob=0.2):
        self.problem = problem
        self.pop_size = pop_size
        self.max_gen = max_gen
        self.crossover_prob = crossover_prob
        self.mutation_prob = mutation_prob

    def optimize_scipy(self):
        """使用SciPy的differential_evolution进行优化"""
        result = differential_evolution(
            self.problem.penalized_objective,
            self.problem.bounds,
            maxiter=self.max_gen,
            popsize=int(self.pop_size / len(self.problem.bounds)),
            seed=None,
            disp=False
        )
        return result

    def run_multiple_times(self, n_runs=20, verbose=True):
        """运行多次优化"""
        print("=" * 80)
        print("运行遗传算法优化G9问题")
        print("=" * 80)

        print(f"\n参数设置:")
        print(f"- 种群大小: {self.pop_size}")
        print(f"- 最大代数: {self.max_gen}")
        print(f"- 运行次数: {n_runs}")
        print(f"- 惩罚系数: {self.problem.penalty_factor}")

        results = []
        all_x = []
        constraints_satisfied = []

        print(f"\n开始{n_runs}次优化实验...")
        print("-" * 80)

        for run in range(n_runs):
            if verbose:
                print(f"运行 {run+1}/{n_runs}...", end=" ")

            result = self.optimize_scipy()

            # 检查约束
            satisfied = self.problem.check_constraints(result.x)
            constraints_satisfied.append(satisfied)

            results.append(result.fun)
            all_x.append(result.x)

            if verbose:
                status = "✓" if satisfied else "✗"
                print(f"最优值: {result.fun:.4f} (约束: {status})")

        return np.array(results), np.array(all_x), np.array(constraints_satisfied)


def main():
    """主函数"""
    print("Lab 4 - 遗传算法优化G9约束问题")
    print("=" * 80)

    # 问题定义
    print("\n问题定义:")
    print("-" * 80)
    print("- 决策变量: 7维")
    print("- 搜索范围: [-10, 10]^7")
    print("- 约束条件: 4个不等式约束")
    print("- 全局最优值: 680.63")

    # 创建问题实例
    problem = G9Problem(penalty_factor=10000)

    # 创建优化器
    optimizer = GeneticAlgorithmOptimizer(
        problem,
        pop_size=200,
        max_gen=300,
        crossover_prob=0.8,
        mutation_prob=0.2
    )

    # 运行20次优化
    results, all_x, constraints_satisfied = optimizer.run_multiple_times(n_runs=20)

    # 统计分析
    print("\n" + "=" * 80)
    print("统计结果 (20次运行)")
    print("=" * 80)

    print("\n最终结果统计:")
    print("-" * 80)
    print(f"最佳值:   {np.min(results):.4f}")
    print(f"最差值:   {np.max(results):.4f}")
    print(f"平均值:   {np.mean(results):.4f}")
    print(f"中值:     {np.median(results):.4f}")
    print(f"标准差:   {np.std(results):.4f}")
    print(f"全局最优: 680.63")
    print(f"距离:     {abs(np.median(results) - 680.63):.4f}")
    print(f"\n约束满足情况: {np.sum(constraints_satisfied)}/20 次运行满足所有约束")

    # 打印详细结果表
    print("\n" + "-" * 80)
    print(f"{'Run':<6} {'Final Value':<15} {'Constraints':<15}")
    print("-" * 80)
    for i in range(len(results)):
        status = "✓" if constraints_satisfied[i] else "✗"
        print(f"{i+1:<6} {results[i]:<15.4f} {status:<15}")
    print("=" * 80)

    # 可视化
    visualize_results(results, problem.global_optimum)

    print("\n优化完成！结果已保存。")


def visualize_results(results, global_optimum):
    """可视化优化结果"""
    fig, axes = plt.subplots(1, 2, figsize=(14, 6))

    # 结果分布直方图
    axes[0].hist(results, bins=15, color='steelblue', edgecolor='black', alpha=0.7)
    axes[0].axvline(x=global_optimum, color='r', linestyle='--', linewidth=2,
                    label=f'Global Optimum ({global_optimum})')
    axes[0].set_xlabel('Objective Function Value', fontsize=12)
    axes[0].set_ylabel('Frequency', fontsize=12)
    axes[0].set_title('Distribution of Final Results (20 Runs)', fontsize=14)
    axes[0].legend()
    axes[0].grid(True, alpha=0.3)

    # 箱线图
    bp = axes[1].boxplot([results], labels=['Final Results'], patch_artist=True)
    bp['boxes'][0].set_facecolor('lightblue')
    axes[1].axhline(y=global_optimum, color='r', linestyle='--', linewidth=2,
                    label=f'Global Optimum ({global_optimum})')
    axes[1].set_ylabel('Objective Function Value', fontsize=12)
    axes[1].set_title('Box Plot of Final Results', fontsize=14)
    axes[1].legend()
    axes[1].grid(True, alpha=0.3, axis='y')

    plt.suptitle('G9 Function Optimization Results', fontsize=16, fontweight='bold')
    plt.tight_layout()
    plt.savefig('results_distribution.png', dpi=300, bbox_inches='tight')
    plt.show()

    # 统计摘要图
    fig, ax = plt.subplots(figsize=(10, 6))

    stats = {
        'Best': np.min(results),
        'Worst': np.max(results),
        'Mean': np.mean(results),
        'Median': np.median(results),
        'Global Opt': global_optimum
    }

    colors = ['green', 'red', 'blue', 'orange', 'purple']
    bars = ax.bar(stats.keys(), stats.values(), color=colors, alpha=0.7, edgecolor='black')

    # 添加数值标签
    for bar in bars:
        height = bar.get_height()
        ax.text(bar.get_x() + bar.get_width()/2., height,
                f'{height:.2f}',
                ha='center', va='bottom', fontsize=11, fontweight='bold')

    ax.set_ylabel('Objective Function Value', fontsize=12)
    ax.set_title('Statistical Summary of Optimization Results', fontsize=14)
    ax.grid(True, alpha=0.3, axis='y')

    plt.tight_layout()
    plt.savefig('statistics_summary.png', dpi=300, bbox_inches='tight')
    plt.show()


if __name__ == "__main__":
    # 设置随机种子
    np.random.seed(42)
    random.seed(42)

    main()
