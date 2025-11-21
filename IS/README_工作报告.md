# 信息安全实验工作报告

## 项目概述

本报告总结了信息安全（UESTC4036）课程三个实验的完成情况。实验内容涵盖古典密码学和区块链技术两个主要领域。

---

## 一、Lab1：古典密码学（MATLAB & Python）

### 1.1 完成的任务

#### Task 1：GUID密钥计算
- **功能**：根据两个组员的GUID计算Caesar密码的密钥k
- **算法**：将两个GUID相加，然后反复将各位数字相加，直到结果≤25
- **结果**：k = 9（基于GUID 2720906 和 2720746）
- **文件**：`t1.m`（MATLAB）、`t1.py`（Python）

#### Task 2：Caesar密码加密与暴力破解
- **功能**：
  - 实现Caesar密码加密函数
  - 实现暴力破解函数，尝试所有26种可能的k值
- **加密公式**：$C = (p + k) \mod 26$
- **解密公式**：$p = (C - k) \mod 26$
- **文件**：`t2.m`（MATLAB）、`t2.py`（Python）

#### Task 3：频率分析破解
- **功能**：利用英文字母频率特性破解Caesar密码
- **原理**：英文中'e'出现频率最高（约12.7%），假设密文中最高频字母对应'e'
- **文件**：`t3.m`（MATLAB）、`t3.py`（Python）

#### Task 4：Playfair密码矩阵生成
- **功能**：根据关键词生成5×5的Playfair密码矩阵
- **特点**：I和J视为同一字母，先填入关键词（去重），再按字母表顺序填入剩余字母
- **测试关键词**：Security、Wang、Zhang
- **文件**：`t4.m`（MATLAB）、`t4.py`（Python）

---

## 二、Lab2：区块链基础（Python）

### 2.1 完成的任务

#### Task 1：简单区块链
- **功能**：创建基础区块链数据结构
- **实现**：
  - 生成10个区块，每个包含index和data
  - 实现log_block()和print_block_data()方法
  - 使用类封装所有功能
- **文件**：`Task1.py`

#### Task 2-3：带哈希的区块链
- **功能**：实现具有SHA-256哈希功能的区块链
- **区块结构**：
  - index：区块索引
  - timestamp：时间戳
  - data：交易数据
  - proof：工作量证明
  - previous_hash：前一区块哈希
- **关键方法**：
  - create_genesis_block()：创建创世区块
  - add_block()：添加新区块
  - hash()：计算SHA-256哈希
  - get_previous_block()：获取最后区块
- **文件**：`blockchain.py`

---

## 三、Lab3：区块链挖矿（Python）

### 3.1 完成的任务

#### 工作量证明(PoW)挖矿系统
- **功能**：实现完整的PoW挖矿机制
- **核心算法**：
  - proof_of_work()：不断尝试nonce值直到哈希满足难度要求
  - is_valid_proof()：验证哈希是否以指定数量的0开头
  - is_chain_valid()：验证整个区块链的完整性
- **难度设置**：difficulty=4（哈希需以"0000"开头）
- **文件**：`BlockChainLab3.py`

---

## 四、代码改进工作

### 4.1 添加的中文注释
为所有代码文件添加了详细的中文注释，包括：
- 文件头部功能说明
- 函数docstring（参数、返回值说明）
- 关键算法步骤注释
- 理论原理解释

### 4.2 Python版本实现
为Lab1的4个MATLAB程序编写了对应的Python版本：
- `t1.py`：密钥计算
- `t2.py`：加密与暴力破解
- `t3.py`：频率分析破解
- `t4.py`：Playfair矩阵生成

---

## 五、文件清单

### Lab1 文件
| 文件名 | 语言 | 功能 |
|--------|------|------|
| t1.m / t1.py | MATLAB/Python | GUID密钥计算 |
| t2.m / t2.py | MATLAB/Python | Caesar加密与暴力破解 |
| t3.m / t3.py | MATLAB/Python | 频率分析破解 |
| t4.m / t4.py | MATLAB/Python | Playfair矩阵生成 |

### Lab2 文件
| 文件名 | 语言 | 功能 |
|--------|------|------|
| Task1.py | Python | 简单区块链 |
| blockchain.py | Python | 带哈希的区块链 |

### Lab3 文件
| 文件名 | 语言 | 功能 |
|--------|------|------|
| BlockChainLab3.py | Python | PoW挖矿系统 |

---

## 六、运行说明

### MATLAB代码运行
```matlab
% 在MATLAB命令窗口中运行
run('t1.m')
run('t2.m')
run('t3.m')
run('t4.m')
```

### Python代码运行
```bash
# Lab1
python IS/Lab1/t1.py
python IS/Lab1/t2.py
python IS/Lab1/t3.py
python IS/Lab1/t4.py

# Lab2
python IS/Lab2/Task1.py
python IS/Lab2/blockchain.py

# Lab3
python IS/Lab3/BlockChainLab3.py
```

---

## 七、学习心得

通过这三个实验，我深入理解了：

1. **古典密码学**：Caesar密码虽然简单，但展示了替换密码的基本原理；频率分析是破解单表替换密码的有效方法；Playfair密码通过双字母替换提高了安全性。

2. **区块链技术**：区块链通过哈希链接实现数据不可篡改；工作量证明机制确保了去中心化共识；难度调节平衡了安全性和效率。

3. **编程实践**：MATLAB适合数值计算和算法原型设计；Python更适合系统实现和实际应用；良好的代码注释对于理解和维护至关重要。

---

*报告生成日期：2024年*
