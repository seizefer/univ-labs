# 学术网站网络结构设计

## 网页节点定义

我们构建一个包含12个网页的虚拟大学网站系统：

1. **Homepage** - 大学主页
2. **CS_Dept** - 计算机科学系
3. **Math_Dept** - 数学系
4. **Library** - 图书馆
5. **Course_Portal** - 课程门户
6. **Linear_Algebra** - 线性代数课程页
7. **Data_Science** - 数据科学课程页
8. **Student_Resources** - 学生资源
9. **Research** - 研究页面
10. **Faculty** - 教师名录
11. **Admissions** - 招生页面
12. **Alumni** - 校友网络

## 链接结构设计思路

### 核心Hub页面
- **Homepage (1)**: 作为中心节点，链接到多个主要部门
- **Course_Portal (5)**: 课程中心，连接各个课程

### 学术层次结构
- 主页 → 各院系
- 院系 → 课程页面
- 课程页面之间相互引用

### 特殊结构
- **Dead End处理**: Alumni页面初始设计为dead end，后续算法会处理
- **循环结构**: 课程之间、院系之间形成引用循环
- **权威页面**: Library和Research被多个页面引用

## 邻接矩阵定义

邻接矩阵 A，其中 A(i,j) = 1 表示网页j有链接指向网页i

### 链接关系表

**Homepage (1) 链接到:**
- CS_Dept (2)
- Math_Dept (3)
- Library (4)
- Course_Portal (5)
- Admissions (11)

**CS_Dept (2) 链接到:**
- Homepage (1)
- Data_Science (7)
- Research (9)
- Faculty (10)

**Math_Dept (3) 链接到:**
- Homepage (1)
- Linear_Algebra (6)
- Research (9)
- Faculty (10)

**Library (4) 链接到:**
- Homepage (1)
- Course_Portal (5)
- Research (9)

**Course_Portal (5) 链接到:**
- Homepage (1)
- Linear_Algebra (6)
- Data_Science (7)
- Student_Resources (8)

**Linear_Algebra (6) 链接到:**
- Math_Dept (3)
- Course_Portal (5)
- Data_Science (7)
- Student_Resources (8)

**Data_Science (7) 链接到:**
- CS_Dept (2)
- Course_Portal (5)
- Linear_Algebra (6)
- Student_Resources (8)

**Student_Resources (8) 链接到:**
- Homepage (1)
- Library (4)
- Course_Portal (5)

**Research (9) 链接到:**
- Homepage (1)
- CS_Dept (2)
- Math_Dept (3)
- Faculty (10)

**Faculty (10) 链接到:**
- Homepage (1)
- CS_Dept (2)
- Math_Dept (3)
- Research (9)

**Admissions (11) 链接到:**
- Homepage (1)
- CS_Dept (2)
- Math_Dept (3)
- Alumni (12)

**Alumni (12) 链接到:**
- (无出链 - Dead End 示例)

## 网络特征分析

### 入度（被多少页面链接）
- Homepage: 预计最高（中心节点）
- Course_Portal: 较高（课程中心）
- Student_Resources: 中等（资源页面）
- Alumni: 最低（终端页面）

### 出度（链接到多少页面）
- Homepage: 5个出链
- Alumni: 0个出链（Dead End）
- 其他页面: 3-4个出链

### 预期PageRank排名
基于链接结构，预期排名前列的页面：
1. Homepage（最多入链）
2. Course_Portal（课程中心）
3. CS_Dept / Math_Dept（院系页面）
4. Research / Faculty（被多个页面引用）

### 线性代数要点
- **稀疏矩阵**: 12×12矩阵，大部分元素为0
- **Dead End处理**: Alumni页面需要特殊处理
- **强连通性**: 除Alumni外，其他页面形成强连通图
