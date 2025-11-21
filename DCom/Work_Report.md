# 工作报告 - 数字通信调制解调实验

## 工作概述

本次工作完成了数字通信实验Lab 1的全部编程和分析任务，主要涉及BPSK和QPSK两种相移键控调制技术。

## 完成的工作

### 1. MATLAB程序开发

创建了完整的实验程序 `Lab1_Modulation.m`，实现以下功能：

**BPSK部分**:
- 生成10000个随机二进制比特
- 实现BPSK调制（映射：0→+1, 1→-1）
- 添加复高斯白噪声（AWGN）
- 实现最小距离检测解调
- 计算并绘制BER vs SNR曲线
- 使用MATLAB内置函数`pskmod/pskdemod`的替代实现

**QPSK部分**:
- 实现π/4相位QPSK星座调制
- 不同SNR下的接收星座图可视化
- QPSK解调和BER计算
- BPSK与QPSK性能对比分析

### 2. 生成的图表

程序自动生成以下图表：
- `Task1_1_BPSK_First10.png`: BPSK接收信号前10符号
- `Task1_3_BPSK_BER.png`: BPSK的BER vs SNR曲线
- `Task2_1_QPSK_Constellation.png`: QPSK调制星座图
- `Task2_2_QPSK_SNR_Comparison.png`: 不同SNR下QPSK接收星座
- `Task2_3_QPSK_BER.png`: QPSK的BER vs SNR曲线
- `Task2_4_BER_Comparison.png`: BPSK与QPSK性能对比

### 3. 实验答案文档

完成了所有8个任务的答案，包括：
- Task 1.1-1.4 (BPSK相关)
- Task 2.1-2.4 (QPSK相关)

每个答案包含题目复述、结果说明和原理解释。

### 4. 学术报告

撰写了LaTeX格式的学术报告，包含：
- 实验原理介绍
- 系统模型描述
- 实验结果分析
- 结论与讨论

## 关键技术点

1. **噪声建模**: 使用 $N_0 = 1/10^{SNR_{dB}/10}$ 计算噪声功率
2. **BPSK调制**: $s = -2(b-0.5)$，将{0,1}映射到{+1,-1}
3. **QPSK星座**: 使用π/4, 3π/4, 5π/4, 7π/4四个相位点
4. **BER计算**: $BER = \frac{\text{错误比特数}}{\text{总比特数}}$

## 文件结构

```
DCom/
├── Lab1_Modulation.m      # 主程序
├── Lab_Answers.md         # 题目答案
├── Work_Report.md         # 本工作报告
└── Lab1_Report.tex        # LaTeX学术报告
```

## 备注

- 所有代码注释使用中文
- 代码变量名、图表标题使用英文
- 程序可直接在MATLAB中运行，自动生成所有图表
