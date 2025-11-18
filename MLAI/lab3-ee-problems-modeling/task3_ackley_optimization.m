%% Lab 3 - Task 3: 使用遗传算法优化Ackley函数
% Optimizing 10D Ackley Function using Genetic Algorithm
% 使用MATLAB内置的'ga'函数优化10维Ackley函数

clear; close all; clc;

fprintf('Lab 3 - Task 3: 10维Ackley函数优化\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% Ackley函数定义
fprintf('\n步骤1: 定义10维Ackley函数\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% Ackley函数的全局最优值在x=[0,0,...,0]处，最优值为0
fprintf('Ackley函数特性:\n');
fprintf('- 维度: 10维\n');
fprintf('- 搜索范围: [-15, 30]^10\n');
fprintf('- 全局最优点: x = [0, 0, ..., 0]\n');
fprintf('- 全局最优值: f(x*) = 0\n\n');

%% 遗传算法参数设置
fprintf('步骤2: 配置遗传算法参数\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

n_dims = 10; % 决策变量维度
lower_bound = -15 * ones(1, n_dims); % 下界
upper_bound = 30 * ones(1, n_dims);  % 上界

% GA参数配置
ga_options = optimoptions('ga', ...
    'PopulationSize', 100, ...           % 种群大小
    'MaxGenerations', 200, ...           % 最大代数
    'CrossoverFraction', 0.8, ...        % 交叉概率
    'EliteCount', 5, ...                 % 精英个体数量
    'FunctionTolerance', 1e-6, ...       % 函数容忍度
    'Display', 'iter', ...               % 显示迭代信息
    'PlotFcn', {@gaplotbestf, @gaplotbestindiv}); % 绘图函数

fprintf('\n遗传算法参数:\n');
fprintf('- 种群大小: %d\n', ga_options.PopulationSize);
fprintf('- 最大代数: %d\n', ga_options.MaxGenerations);
fprintf('- 交叉概率: %.2f\n', ga_options.CrossoverFraction);
fprintf('- 精英个体数: %d\n\n', ga_options.EliteCount);

%% 运行遗传算法
fprintf('步骤3: 运行遗传算法优化\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

tic; % 开始计时

[x_optimal, f_optimal, exitflag, output] = ga(...
    @ackley10d, ...           % 目标函数
    n_dims, ...               % 变量数量
    [], [], [], [], ...      % 线性约束(无)
    lower_bound, ...          % 下界
    upper_bound, ...          % 上界
    [], ...                   % 非线性约束(无)
    ga_options);              % 选项

elapsed_time = toc; % 结束计时

%% 显示结果
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('优化结果\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

fprintf('\n最优决策变量 x*:\n');
fprintf('  x*(%d) = %12.8f\n', [(1:n_dims)', x_optimal']');

fprintf('\n最优目标函数值:\n');
fprintf('  f(x*) = %.10f\n', f_optimal);

fprintf('\n与全局最优值的距离:\n');
fprintf('  |f(x*) - 0| = %.10f\n', abs(f_optimal));

fprintf('\n优化信息:\n');
fprintf('  退出标志: %d\n', exitflag);
fprintf('  迭代次数: %d\n', output.generations);
fprintf('  函数评估次数: %d\n', output.funccount);
fprintf('  计算时间: %.2f 秒\n', elapsed_time);

if abs(f_optimal) < 0.01
    fprintf('\n结论: 成功找到接近全局最优的解! ✓\n');
elseif abs(f_optimal) < 10
    fprintf('\n结论: 找到较好的解，但距离全局最优还有一定距离。\n');
else
    fprintf('\n结论: 未能找到较好的解，建议调整GA参数。\n');
end

fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 可视化结果
fprintf('\n步骤4: 可视化优化结果\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 绘制最优解的柱状图
figure('Position', [100, 100, 1000, 600]);
subplot(1, 2, 1);
bar(1:n_dims, x_optimal, 'FaceColor', [0.2 0.6 0.8]);
xlabel('Decision Variable Index', 'FontSize', 12);
ylabel('Optimal Value', 'FontSize', 12);
title('Optimal Decision Variables', 'FontSize', 14);
grid on;
hold on;
plot([0, n_dims+1], [0, 0], 'r--', 'LineWidth', 2, 'DisplayName', 'Global Optimum');
legend('Optimal x*', 'Global Optimum (0)', 'Location', 'best');

% 绘制Ackley函数的2D切片（固定其他维度为最优值）
subplot(1, 2, 2);
x_range = linspace(-15, 30, 100);
y_values = zeros(size(x_range));
for i = 1:length(x_range)
    x_temp = x_optimal;
    x_temp(1) = x_range(i); % 只改变第一个维度
    y_values(i) = ackley10d(x_temp);
end
plot(x_range, y_values, 'b-', 'LineWidth', 2);
hold on;
plot(x_optimal(1), f_optimal, 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
plot(0, 0, 'g*', 'MarkerSize', 15, 'LineWidth', 2);
xlabel('x_1 (other dims fixed at optimal)', 'FontSize', 12);
ylabel('f(x)', 'FontSize', 12);
title('Ackley Function Slice', 'FontSize', 14);
legend('Ackley Function', 'Found Optimum', 'Global Optimum', 'Location', 'best');
grid on;

sgtitle('Ackley Function Optimization Results', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'ackley_optimization_results.png');

fprintf('优化结果已保存到图片文件。\n');

%% 10维Ackley函数定义
function y = ackley10d(x)
    % 10维Ackley函数
    %
    % 输入:
    %   x: 决策变量向量 (1x10 或 10x1)
    %
    % 输出:
    %   y: 函数值
    %
    % 函数定义:
    %   f(x) = -a * exp(-b * sqrt(1/n * sum(xi^2)))
    %          - exp(1/n * sum(cos(c*xi)))
    %          + a + exp(1)
    %
    % 其中: a=20, b=0.2, c=2*pi, n=10
    % 全局最优: x*=[0,...,0], f(x*)=0

    % 确保x是列向量
    x = x(:);

    % 参数设置
    n = 10;           % 维度
    a = 20;           % 参数a
    b = 0.2;          % 参数b
    c = 2 * pi;       % 参数c

    % 计算两个求和项
    s1 = sum(x.^2);
    s2 = sum(cos(c * x));

    % 计算Ackley函数值
    y = -a * exp(-b * sqrt(s1 / n)) - exp(s2 / n) + a + exp(1);
end
