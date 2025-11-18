# MLAI Labs - Machine Learning & AI实验

本仓库包含UESTC 3036课程的四个机器学习实验，每个实验都包含完整的MATLAB和Python实现。

## 项目结构

```
univ-labs/
├── MLAI/
│   ├── lab1-spoken-digit-recognition/      # Lab 1: 语音数字识别
│   ├── lab2-neural-network/                # Lab 2: 神经网络
│   ├── lab3-ee-problems-modeling/          # Lab 3: EE问题建模
│   ├── lab4-genetic-algorithm/             # Lab 4: 遗传算法
│   └── .old/                                # 原始文件备份
└── README.md
```

## 实验概述

### Lab 1: Spoken Digit Recognition (语音数字识别)
- **主题**: 使用KNN和SVM进行语音数字识别
- **数据集**: Audio MNIST (3000个语音样本)
- **关键技术**: MFCC特征提取、Z-score标准化
- **代码**: Python + MATLAB双语言实现

### Lab 2: Neural Network (神经网络)
- **主题**: 使用前馈神经网络进行手写数字识别
- **数据集**: MNIST (60000训练+10000测试)
- **关键技术**: PyTorch深度学习框架、反向传播
- **代码**: Python (PyTorch) + MATLAB (Deep Learning Toolbox)

### Lab 3: EE Problems Modeling (EE问题建模)
- **主题**: 电子工程问题建模与优化
- **任务**:
  - Task 1: 微波双工器性能评估
  - Task 2: 雷达信号处理
  - Task 3: Ackley函数优化
- **代码**: MATLAB + Python双语言实现

### Lab 4: Genetic Algorithm (遗传算法)
- **主题**: 使用遗传算法解决约束优化问题
- **问题**: G9约束优化问题(7维)
- **关键技术**: 遗传算法、惩罚函数法
- **代码**: MATLAB (GA Toolbox) + Python (scipy.optimize)

## 运行说明

### Python环境要求
```bash
pip install numpy scipy matplotlib scikit-learn torch torchvision librosa seaborn tqdm
```

### MATLAB要求
- MATLAB R2020a或更高版本
- Deep Learning Toolbox (Lab 2)
- Optimization Toolbox (Lab 3, Lab 4)
- Signal Processing Toolbox (Lab 3)

## 报告文档

每个实验包含三份报告：
1. **WORK_REPORT_CN.md** - 中文工作报告（简短工作描述）
2. **REPORT_CN.md** - 中文学术报告（详细实验报告）
3. **REPORT_EN.tex** - 英文学术报告（LaTeX格式，Overleaf兼容）

## 代码特点

- ✅ 双语言实现（Python + MATLAB）
- ✅ 完整的实验pipeline
- ✅ 详细的中文注释
- ✅ 结果可视化
- ✅ 参数对比实验
- ✅ 错误处理机制

## 作者

- 姓名: [Your Name]
- 学号: [Your ID]
- 课程: UESTC 3036 Machine Learning & AI
- 学期: 2023-2024 Fall

## 许可证

本项目仅用于学术学习目的。
