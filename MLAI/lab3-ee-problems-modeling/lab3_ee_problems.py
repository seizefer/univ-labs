"""
Lab 3 - EE Problems Modeling
EE问题建模

包含三个任务:
1. 微波双工器性能评估
2. 雷达信号处理（光谱图特征提取）
3. 使用遗传算法优化Ackley函数
"""

import numpy as np
import matplotlib.pyplot as plt
from scipy.optimize import differential_evolution
import warnings
warnings.filterwarnings('ignore')


class DiplexerEvaluator:
    """微波双工器性能评估器"""

    def __init__(self):
        self.specs = [
            {'param': 'S11', 'freq_range': [12.5, 12.75], 'threshold': -20},
            {'param': 'S11', 'freq_range': [13.0, 13.25], 'threshold': -20},
            {'param': 'S21', 'freq_range': [12.0, 12.30], 'threshold': -20},
            {'param': 'S21', 'freq_range': [13.0, 13.25], 'threshold': -55},
            {'param': 'S31', 'freq_range': [12.5, 12.75], 'threshold': -55},
            {'param': 'S31', 'freq_range': [13.4, 13.75], 'threshold': -20},
        ]

    def evaluate(self, f, S11_val, S21_val, S31_val):
        """
        评估双工器性能

        参数:
            f: 频率数组 (GHz)
            S11_val: S11参数 (dB)
            S21_val: S21参数 (dB)
            S31_val: S31参数 (dB)

        返回:
            perf: 性能向量 [E1, E2, E3, E4, E5, E6]
        """
        perf = np.zeros(6)
        params = {'S11': S11_val, 'S21': S21_val, 'S31': S31_val}

        for i, spec in enumerate(self.specs):
            # 找到频率范围内的索引
            mask = (f >= spec['freq_range'][0]) & (f <= spec['freq_range'][1])

            if np.any(mask):
                # 计算违反值
                values = params[spec['param']][mask]
                violations = values - spec['threshold']
                perf[i] = max(0, np.max(violations))

        return perf

    def plot_responses(self, f, S11_val, S21_val, S31_val, perf, save_path='diplexer_responses.png'):
        """绘制S参数响应"""
        fig, axes = plt.subplots(3, 1, figsize=(12, 10))

        # S11响应
        axes[0].plot(f, S11_val, 'b-', linewidth=1.5, label='S11')
        axes[0].plot([12.5, 12.75], [-20, -20], 'r--', linewidth=2, label='Spec 1')
        axes[0].plot([13.0, 13.25], [-20, -20], 'r--', linewidth=2, label='Spec 2')
        axes[0].set_xlabel('Frequency (GHz)')
        axes[0].set_ylabel('S11 (dB)')
        axes[0].set_title('S11 Response')
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)

        # S21响应
        axes[1].plot(f, S21_val, 'g-', linewidth=1.5, label='S21')
        axes[1].plot([12.0, 12.3], [-20, -20], 'r--', linewidth=2, label='Spec 1')
        axes[1].plot([13.0, 13.25], [-55, -55], 'r--', linewidth=2, label='Spec 2')
        axes[1].set_xlabel('Frequency (GHz)')
        axes[1].set_ylabel('S21 (dB)')
        axes[1].set_title('S21 Response')
        axes[1].legend()
        axes[1].grid(True, alpha=0.3)

        # S31响应
        axes[2].plot(f, S31_val, 'm-', linewidth=1.5, label='S31')
        axes[2].plot([12.5, 12.75], [-55, -55], 'r--', linewidth=2, label='Spec 1')
        axes[2].plot([13.4, 13.75], [-20, -20], 'r--', linewidth=2, label='Spec 2')
        axes[2].set_xlabel('Frequency (GHz)')
        axes[2].set_ylabel('S31 (dB)')
        axes[2].set_title('S31 Response')
        axes[2].legend()
        axes[2].grid(True, alpha=0.3)

        plt.suptitle('Diplexer S-Parameter Responses', fontsize=14, fontweight='bold')
        plt.tight_layout()
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()


def ackley_10d(x):
    """
    10维Ackley函数

    参数:
        x: 决策变量向量 (10维)

    返回:
        函数值
    """
    n = len(x)
    a = 20
    b = 0.2
    c = 2 * np.pi

    s1 = np.sum(x**2)
    s2 = np.sum(np.cos(c * x))

    y = -a * np.exp(-b * np.sqrt(s1 / n)) - np.exp(s2 / n) + a + np.exp(1)
    return y


class AckleyOptimizer:
    """Ackley函数优化器"""

    def __init__(self, n_dims=10, bounds=(-15, 30)):
        self.n_dims = n_dims
        self.bounds = [bounds] * n_dims

    def optimize(self, method='differential_evolution', **kwargs):
        """
        优化Ackley函数

        参数:
            method: 优化方法
            **kwargs: 优化器参数

        返回:
            result: 优化结果
        """
        print("=" * 80)
        print(f"使用{method}优化10维Ackley函数")
        print("=" * 80)

        if method == 'differential_evolution':
            # 使用差分进化算法（类似遗传算法）
            result = differential_evolution(
                ackley_10d,
                self.bounds,
                maxiter=kwargs.get('maxiter', 200),
                popsize=kwargs.get('popsize', 15),
                seed=42,
                disp=True
            )
        else:
            raise ValueError(f"Unknown method: {method}")

        return result

    def plot_results(self, result, save_path='ackley_optimization_results.png'):
        """可视化优化结果"""
        fig, axes = plt.subplots(1, 2, figsize=(14, 6))

        # 绘制最优解
        axes[0].bar(range(1, self.n_dims + 1), result.x, color='steelblue', alpha=0.7)
        axes[0].axhline(y=0, color='r', linestyle='--', linewidth=2, label='Global Optimum')
        axes[0].set_xlabel('Decision Variable Index', fontsize=12)
        axes[0].set_ylabel('Optimal Value', fontsize=12)
        axes[0].set_title('Optimal Decision Variables', fontsize=14)
        axes[0].legend()
        axes[0].grid(True, alpha=0.3)

        # 绘制Ackley函数切片
        x_range = np.linspace(-15, 30, 100)
        y_values = []
        for val in x_range:
            x_temp = result.x.copy()
            x_temp[0] = val
            y_values.append(ackley_10d(x_temp))

        axes[1].plot(x_range, y_values, 'b-', linewidth=2, label='Ackley Function')
        axes[1].plot(result.x[0], result.fun, 'ro', markersize=10, label='Found Optimum')
        axes[1].plot(0, 0, 'g*', markersize=15, label='Global Optimum')
        axes[1].set_xlabel('x₁ (other dims fixed at optimal)', fontsize=12)
        axes[1].set_ylabel('f(x)', fontsize=12)
        axes[1].set_title('Ackley Function Slice', fontsize=14)
        axes[1].legend()
        axes[1].grid(True, alpha=0.3)

        plt.suptitle('Ackley Function Optimization Results', fontsize=16, fontweight='bold')
        plt.tight_layout()
        plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()


def task1_diplexer_evaluation():
    """Task 1: 微波双工器性能评估"""
    print("\n" + "=" * 80)
    print("Task 1: 微波双工器性能评估")
    print("=" * 80)

    # 创建模拟数据（实际应从.mat文件加载）
    f = np.linspace(12, 14, 1000)
    S11_val = -25 + 10 * np.random.rand(len(f))
    S21_val = -30 + 15 * np.random.rand(len(f))
    S31_val = -40 + 20 * np.random.rand(len(f))

    # 评估性能
    evaluator = DiplexerEvaluator()
    perf = evaluator.evaluate(f, S11_val, S21_val, S31_val)

    # 显示结果
    print("\n性能评估结果:")
    print("-" * 80)
    print(f"E1 (S11 @ 12.5-12.75 GHz, threshold=-20dB): {perf[0]:.4f} dB")
    print(f"E2 (S11 @ 13-13.25 GHz, threshold=-20dB):    {perf[1]:.4f} dB")
    print(f"E3 (S21 @ 12-12.3 GHz, threshold=-20dB):     {perf[2]:.4f} dB")
    print(f"E4 (S21 @ 13-13.25 GHz, threshold=-55dB):    {perf[3]:.4f} dB")
    print(f"E5 (S31 @ 12.5-12.75 GHz, threshold=-55dB):  {perf[4]:.4f} dB")
    print(f"E6 (S31 @ 13.4-13.75 GHz, threshold=-20dB):  {perf[5]:.4f} dB")
    print("-" * 80)

    if np.all(perf == 0):
        print("\n结论: 所有规范都得到满足! ✓")
    else:
        print(f"\n结论: 存在规范违反，最大违反值: {np.max(perf):.4f} dB")

    # 绘制响应
    evaluator.plot_responses(f, S11_val, S21_val, S31_val, perf)


def task3_ackley_optimization():
    """Task 3: 使用遗传算法优化Ackley函数"""
    print("\n" + "=" * 80)
    print("Task 3: 10维Ackley函数优化")
    print("=" * 80)

    print("\nAckley函数特性:")
    print("- 维度: 10维")
    print("- 搜索范围: [-15, 30]^10")
    print("- 全局最优点: x = [0, 0, ..., 0]")
    print("- 全局最优值: f(x*) = 0")

    # 优化
    optimizer = AckleyOptimizer(n_dims=10, bounds=(-15, 30))
    result = optimizer.optimize(method='differential_evolution', maxiter=200, popsize=15)

    # 显示结果
    print("\n" + "=" * 80)
    print("优化结果")
    print("=" * 80)
    print("\n最优决策变量 x*:")
    for i, val in enumerate(result.x):
        print(f"  x*({i+1}) = {val:12.8f}")

    print(f"\n最优目标函数值:")
    print(f"  f(x*) = {result.fun:.10f}")

    print(f"\n与全局最优值的距离:")
    print(f"  |f(x*) - 0| = {abs(result.fun):.10f}")

    print(f"\n优化信息:")
    print(f"  函数评估次数: {result.nfev}")
    print(f"  优化成功: {result.success}")

    if abs(result.fun) < 0.01:
        print("\n结论: 成功找到接近全局最优的解! ✓")
    elif abs(result.fun) < 10:
        print("\n结论: 找到较好的解，但距离全局最优还有一定距离。")
    else:
        print("\n结论: 未能找到较好的解，建议调整优化参数。")

    print("=" * 80)

    # 可视化
    optimizer.plot_results(result)


def main():
    """主函数"""
    print("Lab 3 - EE问题建模")
    print("=" * 80)

    # Task 1: 微波双工器性能评估
    task1_diplexer_evaluation()

    # Task 3: Ackley函数优化
    task3_ackley_optimization()

    print("\n所有任务完成！")


if __name__ == "__main__":
    main()
