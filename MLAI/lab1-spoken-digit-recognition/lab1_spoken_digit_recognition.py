"""
Lab 1 - Spoken Digit Recognition
语音数字识别实验

使用KNN和SVM算法对Audio MNIST数据集进行分类
包含不同参数的性能对比实验
"""

import os
import sys
import numpy as np
from random import shuffle, seed
from scipy.io import wavfile
import matplotlib.pyplot as plt
import seaborn as sn
from scipy.stats import norm
import warnings
warnings.filterwarnings('ignore')

# 设置随机种子以确保可重复性
seed(42)
np.random.seed(42)

try:
    from librosa import feature
    from librosa.util import fix_length
except ImportError:
    print("请安装librosa: pip install librosa")
    sys.exit(1)

from sklearn.neighbors import KNeighborsClassifier
from sklearn.svm import SVC
from sklearn.metrics import confusion_matrix, f1_score, classification_report
from sklearn.preprocessing import StandardScaler


class SpokenDigitRecognizer:
    """语音数字识别器类"""

    def __init__(self, data_dir="audio_mnist/recordings", data_size=2600):
        """
        初始化识别器

        参数:
            data_dir: 数据集目录路径
            data_size: 音频数据固定长度
        """
        self.data_dir = data_dir
        self.data_size = data_size
        self.train_set = None
        self.test_set = None
        self.train_label = None
        self.test_label = None
        self.scaler = StandardScaler()

    def load_and_split_data(self, test_ratio=0.3):
        """
        加载并分割数据集

        参数:
            test_ratio: 测试集比例
        """
        if not os.path.exists(self.data_dir):
            print(f"警告: 数据集目录 {self.data_dir} 不存在")
            print("请将Audio MNIST数据集放置在正确的目录中")
            return False

        # 读取文件列表
        file_list = [f for f in os.listdir(self.data_dir) if f.endswith('.wav')]
        print(f"找到 {len(file_list)} 个音频文件")

        # 分割数据集
        n = len(file_list)
        shuffle(file_list)
        split_point = int(n * test_ratio)
        test_list = file_list[:split_point]
        train_list = file_list[split_point:]

        print(f"训练集: {len(train_list)} 个样本")
        print(f"测试集: {len(test_list)} 个样本")

        return train_list, test_list

    def extract_features(self, file_list, n_mfcc=20):
        """
        从音频文件中提取MFCC特征

        参数:
            file_list: 文件名列表
            n_mfcc: MFCC系数数量

        返回:
            特征矩阵和标签数组
        """
        labels = []
        datas = []

        for file_name in file_list:
            try:
                # 读取音频文件
                file_path = os.path.join(self.data_dir, file_name)
                sample_rate, data = wavfile.read(file_path)

                # 固定长度
                data = fix_length(data, size=self.data_size)

                # 提取标签（文件名格式: {digitLabel}_{speakerName}_{index}.wav）
                label = int(file_name.split('_')[0])

                # MFCC特征提取
                data = data.astype(float)
                mfcc_features = feature.mfcc(y=data, sr=sample_rate, n_fft=1024, n_mfcc=n_mfcc)

                # 展平为一维向量
                datas.append(mfcc_features.flatten())
                labels.append(label)
            except Exception as e:
                print(f"处理文件 {file_name} 时出错: {e}")
                continue

        return np.stack(datas), np.array(labels, dtype=int)

    def prepare_data(self, n_mfcc=20, test_ratio=0.3):
        """
        准备训练和测试数据

        参数:
            n_mfcc: MFCC系数数量
            test_ratio: 测试集比例
        """
        # 加载并分割数据
        result = self.load_and_split_data(test_ratio)
        if not result:
            return False

        train_list, test_list = result

        # 提取特征
        print(f"\n提取MFCC特征 (n_mfcc={n_mfcc})...")
        self.train_set, self.train_label = self.extract_features(train_list, n_mfcc)
        self.test_set, self.test_label = self.extract_features(test_list, n_mfcc)

        print(f"训练集形状: {self.train_set.shape}")
        print(f"测试集形状: {self.test_set.shape}")

        return True

    def standardize_data(self):
        """数据标准化"""
        # 使用训练集拟合scaler
        self.scaler.fit(self.train_set)

        # 转换训练集和测试集
        self.train_set = self.scaler.transform(self.train_set)
        self.test_set = self.scaler.transform(self.test_set)

        print("数据标准化完成")

    def plot_standardized_distribution(self, save_path=None):
        """绘制标准化后的数据分布"""
        fig, ax = plt.subplots(figsize=(10, 6))

        # 绘制第一个特征的分布
        ax.hist(self.train_set[:, 0], bins=50, density=True, alpha=0.6, label="Data Distribution")

        # 绘制标准正态分布
        x = np.arange(-3, 3, 0.01)
        ax.plot(x, norm.pdf(x, 0, 1.), 'r-', linewidth=2, label="Standard Normal Distribution")

        ax.set_xlabel("Feature Value", fontsize=12)
        ax.set_ylabel("Density", fontsize=12)
        ax.set_title("Standardized Feature Distribution", fontsize=14)
        ax.legend()
        ax.grid(True, alpha=0.3)

        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()

    def train_and_evaluate_knn(self, n_neighbors=5):
        """
        训练并评估KNN模型

        参数:
            n_neighbors: 邻居数量

        返回:
            模型、预测结果、F1分数
        """
        print(f"\n训练KNN模型 (n_neighbors={n_neighbors})...")

        # 创建并训练模型
        knn = KNeighborsClassifier(n_neighbors=n_neighbors, metric="minkowski")
        knn.fit(self.train_set, self.train_label)

        # 预测
        predictions = knn.predict(self.test_set)

        # 评估
        f1 = f1_score(self.test_label, predictions, average="micro")

        print(f"KNN (k={n_neighbors}) F1 Score: {f1:.4f}")

        return knn, predictions, f1

    def train_and_evaluate_svm(self, kernel='rbf', gamma='auto'):
        """
        训练并评估SVM模型

        参数:
            kernel: 核函数类型
            gamma: 核函数系数

        返回:
            模型、预测结果、F1分数
        """
        print(f"\n训练SVM模型 (kernel={kernel})...")

        # 创建并训练模型
        svm = SVC(gamma=gamma, kernel=kernel)
        svm.fit(self.train_set, self.train_label)

        # 预测
        predictions = svm.predict(self.test_set)

        # 评估
        f1 = f1_score(self.test_label, predictions, average="micro")

        print(f"SVM (kernel={kernel}) F1 Score: {f1:.4f}")

        return svm, predictions, f1

    def plot_confusion_matrix(self, predictions, title="Confusion Matrix", save_path=None):
        """
        绘制混淆矩阵

        参数:
            predictions: 预测结果
            title: 图表标题
            save_path: 保存路径
        """
        # 计算混淆矩阵
        cm = confusion_matrix(self.test_label, predictions)

        # 绘图
        plt.figure(figsize=(10, 8))
        sn.heatmap(cm, annot=True, fmt='d', cmap='Blues', cbar=True,
                   xticklabels=range(10), yticklabels=range(10))
        plt.title(title, fontsize=14)
        plt.ylabel("Ground Truth", fontsize=12)
        plt.xlabel("Predicted", fontsize=12)

        if save_path:
            plt.savefig(save_path, dpi=300, bbox_inches='tight')
        plt.show()


def experiment_mfcc_comparison():
    """
    实验1: 比较不同MFCC特征数量的性能
    """
    print("=" * 80)
    print("实验1: 不同MFCC特征数量对比")
    print("=" * 80)

    mfcc_values = [10, 20, 30]
    results = []

    for n_mfcc in mfcc_values:
        print(f"\n{'='*60}")
        print(f"测试 n_mfcc = {n_mfcc}")
        print(f"{'='*60}")

        recognizer = SpokenDigitRecognizer()

        if not recognizer.prepare_data(n_mfcc=n_mfcc):
            print("数据准备失败，跳过此实验")
            continue

        recognizer.standardize_data()

        # 使用固定参数测试KNN和SVM
        _, _, knn_f1 = recognizer.train_and_evaluate_knn(n_neighbors=5)
        _, _, svm_f1 = recognizer.train_and_evaluate_svm(kernel='rbf')

        results.append({
            'n_mfcc': n_mfcc,
            'KNN_F1': knn_f1,
            'SVM_F1': svm_f1
        })

    # 打印对比表格
    print("\n" + "=" * 80)
    print("MFCC特征数量对比结果")
    print("=" * 80)
    print(f"{'n_mfcc':<15} {'KNN F1 Score':<20} {'SVM F1 Score':<20}")
    print("-" * 80)
    for r in results:
        print(f"{r['n_mfcc']:<15} {r['KNN_F1']:<20.4f} {r['SVM_F1']:<20.4f}")
    print("=" * 80)

    return results


def experiment_knn_neighbors():
    """
    实验2: 比较不同KNN邻居数的性能
    """
    print("\n" + "=" * 80)
    print("实验2: 不同KNN邻居数对比")
    print("=" * 80)

    neighbor_values = [3, 5, 7]
    results = []

    # 准备数据（使用n_mfcc=20）
    recognizer = SpokenDigitRecognizer()
    if not recognizer.prepare_data(n_mfcc=20):
        print("数据准备失败")
        return None

    recognizer.standardize_data()

    for n_neighbors in neighbor_values:
        _, predictions, f1 = recognizer.train_and_evaluate_knn(n_neighbors=n_neighbors)

        results.append({
            'n_neighbors': n_neighbors,
            'F1_Score': f1
        })

    # 打印对比表格
    print("\n" + "=" * 80)
    print("KNN邻居数对比结果")
    print("=" * 80)
    print(f"{'n_neighbors':<15} {'F1 Score':<20}")
    print("-" * 80)
    for r in results:
        print(f"{r['n_neighbors']:<15} {r['F1_Score']:<20.4f}")
    print("=" * 80)

    return results


def experiment_svm_kernels():
    """
    实验3: 比较不同SVM核函数的性能
    """
    print("\n" + "=" * 80)
    print("实验3: 不同SVM核函数对比")
    print("=" * 80)

    kernels = ['linear', 'rbf', 'poly']
    results = []

    # 准备数据（使用n_mfcc=20）
    recognizer = SpokenDigitRecognizer()
    if not recognizer.prepare_data(n_mfcc=20):
        print("数据准备失败")
        return None

    recognizer.standardize_data()

    for kernel in kernels:
        _, predictions, f1 = recognizer.train_and_evaluate_svm(kernel=kernel)

        # 绘制混淆矩阵
        recognizer.plot_confusion_matrix(
            predictions,
            title=f"SVM Confusion Matrix (kernel={kernel})",
            save_path=f"svm_{kernel}_confusion_matrix.png"
        )

        results.append({
            'kernel': kernel,
            'F1_Score': f1
        })

    # 打印对比表格
    print("\n" + "=" * 80)
    print("SVM核函数对比结果")
    print("=" * 80)
    print(f"{'Kernel':<15} {'F1 Score':<20}")
    print("-" * 80)
    for r in results:
        print(f"{r['kernel']:<15} {r['F1_Score']:<20.4f}")
    print("=" * 80)

    return results


def main():
    """主函数"""
    print("Lab 1 - 语音数字识别")
    print("=" * 80)

    # 基础实验：使用默认参数
    print("\n基础实验：使用默认参数 (n_mfcc=20, n_neighbors=5, kernel=rbf)")
    print("=" * 80)

    recognizer = SpokenDigitRecognizer()

    # 准备数据
    if not recognizer.prepare_data(n_mfcc=20):
        print("数据集未找到，请确保Audio MNIST数据集在正确的位置")
        print("程序将继续但无法运行实验")
        return

    # 标准化
    recognizer.standardize_data()

    # 绘制标准化分布
    recognizer.plot_standardized_distribution(save_path="standardized_distribution.png")

    # 训练和评估KNN
    knn_model, knn_predictions, knn_f1 = recognizer.train_and_evaluate_knn(n_neighbors=5)
    recognizer.plot_confusion_matrix(
        knn_predictions,
        title="KNN Confusion Matrix (k=5)",
        save_path="knn_confusion_matrix.png"
    )

    # 训练和评估SVM
    svm_model, svm_predictions, svm_f1 = recognizer.train_and_evaluate_svm(kernel='rbf')
    recognizer.plot_confusion_matrix(
        svm_predictions,
        title="SVM Confusion Matrix (kernel=rbf)",
        save_path="svm_confusion_matrix.png"
    )

    # 参数对比实验
    print("\n\n开始参数对比实验...")

    # 实验1: MFCC特征数量对比
    mfcc_results = experiment_mfcc_comparison()

    # 实验2: KNN邻居数对比
    knn_results = experiment_knn_neighbors()

    # 实验3: SVM核函数对比
    svm_results = experiment_svm_kernels()

    print("\n所有实验完成！")


if __name__ == "__main__":
    main()
