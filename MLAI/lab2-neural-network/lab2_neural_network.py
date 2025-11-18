"""
Lab 2 - Neural Network
神经网络实验

使用PyTorch构建前馈神经网络对MNIST手写数字进行分类
"""

import torch
import torchvision
from torch.utils.data import DataLoader
import matplotlib.pyplot as plt
import math
import numpy as np
from scipy.stats import norm
from torch import nn
from tqdm import tqdm
from torch import optim
from torch.nn import functional
import statistics
from sklearn.metrics import confusion_matrix
import seaborn as sns

# 设置随机种子
torch.manual_seed(42)
np.random.seed(42)


class FeedForwardNN(nn.Module):
    """前馈神经网络模型"""

    def __init__(self, input_size=784, hidden_sizes=[128, 128, 256, 256], num_classes=10):
        """
        初始化网络

        参数:
            input_size: 输入维度
            hidden_sizes: 隐藏层维度列表
            num_classes: 输出类别数
        """
        super(FeedForwardNN, self).__init__()

        layers = []
        prev_size = input_size

        # 构建隐藏层
        for hidden_size in hidden_sizes:
            layers.append(nn.Linear(prev_size, hidden_size))
            layers.append(nn.ReLU())
            prev_size = hidden_size

        # 输出层
        layers.append(nn.Linear(prev_size, num_classes))
        layers.append(nn.Softmax(dim=-1))

        self.model = nn.Sequential(*layers)

    def forward(self, x):
        return self.model(x)


def standardize(data, dim):
    """
    标准化数据

    参数:
        data: 输入数据张量
        dim: 标准化的维度

    返回:
        标准化后的数据
    """
    means = data.mean(dim=dim, keepdims=True)
    stds = data.std(dim=dim, keepdims=True)
    stds = torch.maximum(stds, torch.tensor(1.0 / math.sqrt(28 * 28)))
    return (data - means) / stds


def plot_standardized_distribution(data, save_path='standardized_distribution.png'):
    """绘制标准化后的数据分布"""
    fig, ax = plt.subplots(figsize=(10, 6))

    # 绘制数据分布
    ax.hist(data.numpy().flatten(), bins=50, density=True, alpha=0.6,
            label="Data Distribution")

    # 绘制标准正态分布
    x = np.arange(-3, 3, 0.01)
    ax.plot(x, norm.pdf(x, 0, 1.), 'r-', linewidth=2,
            label="Standard Normal Distribution")

    ax.set_xlabel("Feature Value", fontsize=12)
    ax.set_ylabel("Density", fontsize=12)
    ax.set_title("Standardized Feature Distribution", fontsize=14)
    ax.legend()
    ax.grid(True, alpha=0.3)
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()


def train_model(model, train_loader, test_loader, n_epochs, learning_rate):
    """
    训练模型

    参数:
        model: 神经网络模型
        train_loader: 训练数据加载器
        test_loader: 测试数据加载器
        n_epochs: 训练轮数
        learning_rate: 学习率

    返回:
        测试准确率列表、训练损失列表
    """
    optimizer = optim.SGD(model.parameters(), lr=learning_rate)
    testing_accuracy = []
    average_train_loss = []
    highest_accuracy = 0

    for epoch in range(n_epochs):
        model.train()
        batch_loss = []

        # 训练阶段
        pbar = tqdm(train_loader, desc=f"Epoch {epoch + 1}/{n_epochs}")
        correct_train = 0
        total_train = 0

        for data, label in pbar:
            optimizer.zero_grad()

            # 标准化和展平
            x = standardize(data, (-2, -1))
            x = torch.flatten(x, start_dim=1, end_dim=-1)

            # 前向传播
            y = model(x)

            # 计算损失
            loss = functional.cross_entropy(y, label)
            loss.backward()
            optimizer.step()

            # 统计准确率
            _, predicted = torch.max(y, 1)
            total_train += label.size(0)
            correct_train += (predicted == label).sum().item()
            batch_acc = (predicted == label).sum().item() / label.size(0)

            pbar.set_postfix({
                'batch_accuracy': f'{batch_acc:.4f}',
                'loss': f'{loss.item():.4f}'
            })
            batch_loss.append(loss.item())

        # 记录平均训练损失
        average_train_loss.append(statistics.mean(batch_loss))

        # 测试阶段
        model.eval()
        correct_test = 0
        total_test = 0

        with torch.no_grad():
            for data, label in test_loader:
                x = standardize(data, (-2, -1))
                x = torch.flatten(x, start_dim=1, end_dim=-1)
                y = model(x)

                _, predicted = torch.max(y, 1)
                total_test += label.size(0)
                correct_test += (predicted == label).sum().item()

        accu_test = correct_test / total_test
        testing_accuracy.append(accu_test)

        print(f'Epoch {epoch + 1}: Test Accuracy = {accu_test:.4f}, '
              f'Train Loss = {average_train_loss[-1]:.4f}')

        # 保存最佳模型
        if accu_test > highest_accuracy:
            highest_accuracy = accu_test
            torch.save(model.state_dict(), 'checkpoint.pth')

    return testing_accuracy, average_train_loss


def plot_training_history(accuracy, losses, save_path='training_history.png'):
    """绘制训练历史"""
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))

    # 绘制准确率
    epochs = range(1, len(accuracy) + 1)
    ax1.plot(epochs, accuracy, 'b-o', linewidth=2, markersize=6)
    ax1.set_xlabel('Epochs', fontsize=12)
    ax1.set_ylabel('Test Accuracy', fontsize=12)
    ax1.set_title('Test Accuracy vs Epochs', fontsize=14)
    ax1.grid(True, alpha=0.3)

    # 绘制损失
    ax2.plot(epochs, losses, 'r-o', linewidth=2, markersize=6)
    ax2.set_xlabel('Epochs', fontsize=12)
    ax2.set_ylabel('Train Loss', fontsize=12)
    ax2.set_title('Train Loss vs Epochs', fontsize=14)
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()


def plot_confusion_matrix_nn(model, test_loader, save_path='confusion_matrix.png'):
    """绘制混淆矩阵"""
    model.eval()
    predicted_labels = []
    true_labels = []

    with torch.no_grad():
        for data, label in test_loader:
            data = standardize(data, dim=(-2, -1))
            data = torch.flatten(data, start_dim=1, end_dim=-1)
            output = model(data)
            _, predicted = torch.max(output, 1)
            predicted_labels.extend(predicted.tolist())
            true_labels.extend(label.tolist())

    # 计算混淆矩阵
    cm = confusion_matrix(true_labels, predicted_labels)

    # 绘图
    plt.figure(figsize=(10, 8))
    sns.heatmap(cm, annot=True, fmt='d', cmap='Blues', cbar=True)
    plt.ylabel('True Label', fontsize=12)
    plt.xlabel('Predicted Label', fontsize=12)
    plt.title('Confusion Matrix', fontsize=14)
    plt.savefig(save_path, dpi=300, bbox_inches='tight')
    plt.show()

    return cm


def tensor_transformation_demo():
    """张量变换演示"""
    print("=" * 80)
    print("Task 1: 张量变换演示")
    print("=" * 80)

    t = torch.tensor([2, 3, 5])
    print(f"原始张量形状: {t.shape}, 值: {t}")

    # 方法1: 使用repeat
    t1 = t.repeat(10, 1)
    print(f"\n方法1 - repeat(): 形状 {t1.shape}")
    print(f"说明: repeat()复制张量内容，创建新的内存空间")

    # 方法2: 使用expand + reshape
    t2 = t.unsqueeze(0).expand(10, -1)
    print(f"\n方法2 - expand(): 形状 {t2.shape}")
    print(f"说明: expand()不复制数据，只是创建视图，内存效率更高")

    print("\n差异总结:")
    print("- repeat()会实际复制数据，占用更多内存")
    print("- expand()创建数据视图，不复制数据，更高效")
    print("=" * 80)


def why_softmax():
    """解释为什么需要softmax"""
    print("\n" + "=" * 80)
    print("Task 2: 为什么需要Softmax作为最后的激活函数")
    print("=" * 80)
    print("\n原因:")
    print("1. 概率解释: Softmax将原始输出转换为概率分布，所有输出和为1")
    print("2. 多分类任务: 对于10个数字的分类，softmax输出每个类别的概率")
    print("3. 数值稳定: Softmax处理了指数运算，使得训练更稳定")
    print("4. 与交叉熵损失配合: 使梯度计算更简洁高效")
    print("\n示例:")
    raw_output = torch.tensor([2.0, 1.0, 0.1])
    softmax_output = torch.softmax(raw_output, dim=0)
    print(f"原始输出: {raw_output.numpy()}")
    print(f"Softmax输出: {softmax_output.numpy()}")
    print(f"输出总和: {softmax_output.sum().item():.4f}")
    print("=" * 80)


def main():
    """主函数"""
    print("Lab 2 - 神经网络实验")
    print("=" * 80)

    # Task 1: 张量变换
    tensor_transformation_demo()

    # Task 2: Softmax解释
    why_softmax()

    # 数据加载
    print("\n加载MNIST数据集...")
    batch_size_train = 128
    batch_size_test = 128

    train_loader = DataLoader(
        torchvision.datasets.MNIST('./data/', train=True, download=True,
                                   transform=torchvision.transforms.ToTensor()),
        batch_size=batch_size_train, shuffle=True)

    test_loader = DataLoader(
        torchvision.datasets.MNIST('./data/', train=False, download=True,
                                   transform=torchvision.transforms.ToTensor()),
        batch_size=batch_size_test, shuffle=True)

    # 查看数据示例
    print("\n查看数据示例...")
    examples = iter(test_loader)
    example_data, example_labels = next(examples)
    print(f"数据批次形状: {example_data.shape}")

    # 绘制样本图片
    fig, axes = plt.subplots(nrows=2, ncols=3, figsize=(10, 7))
    for index_row, row_axes in enumerate(axes):
        for index_col, ax in enumerate(row_axes):
            i = index_row * 3 + index_col
            ax.imshow(example_data[i].numpy().squeeze(), cmap="Greys")
            ax.set_title(f"Label: {example_labels[i]}")
            ax.axis('off')
    plt.tight_layout()
    plt.savefig('mnist_samples.png', dpi=300, bbox_inches='tight')
    plt.show()

    # 数据标准化示例
    example_data_standardized = standardize(example_data, dim=(-2, -1))
    plot_standardized_distribution(example_data_standardized[0])

    # Task 3 & 4: 训练模型并绘制曲线
    print("\n" + "=" * 80)
    print("Task 3 & 4: 训练模型 (学习率=0.5, 20轮)")
    print("=" * 80)

    model = FeedForwardNN()
    accuracy, losses = train_model(model, train_loader, test_loader,
                                    n_epochs=20, learning_rate=0.5)

    # 绘制训练历史
    plot_training_history(accuracy, losses, 'training_history_lr0.5.png')

    # Task 5: 绘制混淆矩阵
    print("\n" + "=" * 80)
    print("Task 5: 绘制混淆矩阵")
    print("=" * 80)

    model.load_state_dict(torch.load('checkpoint.pth'))
    cm = plot_confusion_matrix_nn(model, test_loader, 'confusion_matrix_lr0.5.png')

    # Task 6: 不同学习率对比
    print("\n" + "=" * 80)
    print("Task 6: 不同学习率对比")
    print("=" * 80)

    learning_rates = [0.02, 0.1, 0.5]
    results = []

    for lr in learning_rates:
        print(f"\n训练模型 (学习率={lr})...")
        model_temp = FeedForwardNN()
        acc, loss = train_model(model_temp, train_loader, test_loader,
                                n_epochs=20, learning_rate=lr)
        results.append({'lr': lr, 'accuracy': acc, 'loss': loss})
        plot_training_history(acc, loss, f'training_history_lr{lr}.png')

    # 对比绘图
    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 5))

    for res in results:
        epochs = range(1, len(res['accuracy']) + 1)
        ax1.plot(epochs, res['accuracy'], '-o', label=f"LR={res['lr']}")
        ax2.plot(epochs, res['loss'], '-o', label=f"LR={res['lr']}")

    ax1.set_xlabel('Epochs', fontsize=12)
    ax1.set_ylabel('Test Accuracy', fontsize=12)
    ax1.set_title('Test Accuracy Comparison', fontsize=14)
    ax1.legend()
    ax1.grid(True, alpha=0.3)

    ax2.set_xlabel('Epochs', fontsize=12)
    ax2.set_ylabel('Train Loss', fontsize=12)
    ax2.set_title('Train Loss Comparison', fontsize=14)
    ax2.legend()
    ax2.grid(True, alpha=0.3)

    plt.tight_layout()
    plt.savefig('learning_rate_comparison.png', dpi=300, bbox_inches='tight')
    plt.show()

    print("\n所有实验完成！")


if __name__ == "__main__":
    main()
