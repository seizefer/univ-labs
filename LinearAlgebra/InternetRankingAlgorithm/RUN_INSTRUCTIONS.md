# PageRank算法实验运行指南

## 📋 项目状态
✅ 所有代码已完成并提交到Git
⏸️ 需要在本地运行实验获取结果
⏳ 等待结果后继续生成报告

---

## 🔧 环境准备

### Python环境
需要安装以下Python包：
```bash
pip install numpy pandas matplotlib networkx scipy
```

### MATLAB环境
需要MATLAB R2016b或更高版本，包含以下工具箱：
- Statistics and Machine Learning Toolbox（可选）
- 基础MATLAB即可运行

---

## 🚀 运行步骤

### 方案1：使用Python运行（推荐）

进入项目目录：
```bash
cd LinearAlgebra/InternetRankingAlgorithm
```

**步骤1：运行主实验脚本**
```bash
python3 main_experiment.py
```
这将生成：
- `pagerank_results.csv` - PageRank排名表
- `network_analysis.csv` - 网络结构分析数据
- `pagerank_results.pkl` - 所有实验数据（用于可视化）

**步骤2：运行可视化脚本**
```bash
python3 visualize_results.py
```
这将生成7张图表：
- `figure1_network_structure.png` - 网络结构图
- `figure2_pagerank_ranking.png` - PageRank排名柱状图
- `figure3_convergence_curve.png` - 收敛曲线
- `figure4_damping_factor_effect.png` - 阻尼因子影响
- `figure5_convergence_speed.png` - 收敛速度对比
- `figure6_degree_vs_pagerank.png` - 度数与PageRank关系
- `figure7_pagerank_evolution.png` - PageRank迭代演化

---

### 方案2：使用MATLAB运行

在MATLAB中：
```matlab
cd LinearAlgebra/InternetRankingAlgorithm
main_experiment  % 运行主实验
visualize_results  % 运行可视化
```

这将生成相同的CSV文件和PNG图表，以及：
- `pagerank_results.mat` - MATLAB数据文件

---

## 📤 需要上传的文件

运行完成后，请将以下**所有文件**上传回来：

### 1. 数据文件（必需）
- `pagerank_results.csv`
- `network_analysis.csv`
- `pagerank_results.pkl` 或 `pagerank_results.mat`

### 2. 图表文件（必需 - 全部7张）
- `figure1_network_structure.png`
- `figure2_pagerank_ranking.png`
- `figure3_convergence_curve.png`
- `figure4_damping_factor_effect.png`
- `figure5_convergence_speed.png`
- `figure6_degree_vs_pagerank.png`
- `figure7_pagerank_evolution.png`

### 3. 控制台输出（建议）
- 复制粘贴运行时的控制台输出文本，包括：
  - 网络统计信息
  - 收敛迭代次数
  - PageRank排名结果
  - 相关系数等数值结果

---

## 📊 预期输出示例

运行成功后，控制台应显示类似内容：

```
=== PageRank Algorithm Experiments ===

Experiment 1: Network Creation and Analysis
--------------------------------------------
Network created with 12 pages
Total links: 47

Page Statistics:
Page Name            In-Degree Out-Degree
--------------------  --------- ----------
Homepage                     9          5
CS_Dept                      4          4
...

Experiment 2: Basic PageRank Computation
--------------------------------------------
[Power Iteration Method]
Power Method converged after XX iterations
Final difference: X.XXe-XX

[Eigenvalue Method]
Eigenvalue Method completed
Largest eigenvalue: 1.0000000000
...
```

---

## ✅ 验证清单

上传前请确认：
- [ ] 2个CSV文件已生成
- [ ] 7张PNG图片已生成且能正常打开
- [ ] 控制台输出已保存
- [ ] 所有文件在同一目录下

---

## 🔄 完成后的下一步

上传所有结果文件后，我将：
1. ✍️ 编写**中文工作报告**（简要总结）
2. ✍️ 编写**中文学术报告**（Markdown格式，详细分析）
3. ✍️ 编写**英文学术报告**（LaTeX格式，符合学术规范）
4. 📤 将所有文件提交到Git仓库

---

## ❓ 遇到问题？

### Python运行错误
- 确保已安装所有依赖包
- 检查Python版本 >= 3.7

### MATLAB运行错误
- 确保所有.m文件在当前目录
- 检查MATLAB版本 >= R2016b

### 图片未生成
- 检查是否先运行了`main_experiment`
- 确认`pagerank_results.pkl`或`.mat`文件已生成

---

**准备好后，请运行脚本并上传结果！** 🚀
