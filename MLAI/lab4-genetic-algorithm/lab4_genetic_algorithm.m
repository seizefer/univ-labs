%% Lab 4 - Genetic Algorithm for Constrained Optimization
% 基于遗传算法的约束优化 - G9问题
% 使用MATLAB优化工具箱的ga函数优化G9约束问题

clear; close all; clc;

fprintf('Lab 4 - 遗传算法优化G9约束问题\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 问题定义
fprintf('\n问题定义:\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');
fprintf('- 决策变量: 7维\n');
fprintf('- 搜索范围: [-10, 10]^7\n');
fprintf('- 约束条件: 4个不等式约束\n');
fprintf('- 全局最优值: 680.63\n\n');

%% GA参数设置
fprintf('遗传算法参数设置:\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 基本参数
n_vars = 7;                          % 决策变量数量
lb = -10 * ones(1, n_vars);          % 下界
ub = 10 * ones(1, n_vars);           % 上界

% GA参数
pop_size = 200;                      % 种群大小
max_generations = 300;               % 最大代数
elite_count = 10;                    % 精英个体数
crossover_fraction = 0.8;            % 交叉概率
penalty_factor = 10000;              % 惩罚系数

fprintf('- 种群大小: %d\n', pop_size);
fprintf('- 最大代数: %d\n', max_generations);
fprintf('- 精英个体数: %d\n', elite_count);
fprintf('- 交叉概率: %.2f\n', crossover_fraction);
fprintf('- 惩罚系数: %d\n', penalty_factor);
fprintf('\n参数选择说明:\n');
fprintf('  1. 种群大小设为200，足够大以保持多样性\n');
fprintf('  2. 最大代数300代，保证充分收敛\n');
fprintf('  3. 精英个体数10个，保留优秀基因\n');
fprintf('  4. 交叉概率0.8，平衡探索和利用\n');
fprintf('  5. 惩罚系数10000，确保约束得到满足\n\n');

%% 配置GA选项
options = optimoptions('ga', ...
    'PopulationSize', pop_size, ...
    'MaxGenerations', max_generations, ...
    'EliteCount', elite_count, ...
    'CrossoverFraction', crossover_fraction, ...
    'Display', 'off', ...
    'PlotFcn', []);

%% 运行20次优化
fprintf('开始运行20次优化实验...\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

n_runs = 20;
all_best = zeros(n_runs, max_generations);  % 存储每次运行每代的最优值
final_results = zeros(n_runs, 1);            % 存储每次运行的最终结果
final_x = zeros(n_runs, n_vars);             % 存储每次运行的最优解
constraints_satisfied = zeros(n_runs, 1);    % 记录约束是否满足

for run = 1:n_runs
    fprintf('运行 %d/%d...\n', run, n_runs);

    % 创建输出函数来记录每代最优值
    current_run_best = zeros(max_generations, 1);
    options.OutputFcn = @(options, state, flag) outputFcnGA(options, state, flag, current_run_best);

    % 运行GA
    [x_opt, f_opt, exitflag, output] = ga(...
        @(x) G9_penalized(x, penalty_factor), ...  % 带惩罚的目标函数
        n_vars, ...
        [], [], [], [], ...  % 线性约束
        lb, ub, ...          % 边界
        [], ...              % 非线性约束（已在目标函数中处理）
        options);

    % 检查约束是否满足
    [~, constraints] = G9_penalized(x_opt, penalty_factor);
    constraints_satisfied(run) = all(constraints <= 0);

    % 存储结果
    final_results(run) = f_opt;
    final_x(run, :) = x_opt;
    all_best(run, :) = current_run_best;

    if constraints_satisfied(run)
        fprintf('  最优值: %.4f (约束满足 ✓)\n', f_opt);
    else
        fprintf('  最优值: %.4f (约束违反 ✗)\n', f_opt);
    end
end

%% 统计分析
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('统计结果 (20次运行)\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

% 计算每代的统计值
global_best = min(all_best, [], 1);
global_worst = max(all_best, [], 1);
global_mean = mean(all_best, 1);
global_median = median(all_best, 1);

% 最终结果统计
fprintf('\n最终结果统计:\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');
fprintf('最佳值:   %.4f\n', min(final_results));
fprintf('最差值:   %.4f\n', max(final_results));
fprintf('平均值:   %.4f\n', mean(final_results));
fprintf('中值:     %.4f\n', median(final_results));
fprintf('标准差:   %.4f\n', std(final_results));
fprintf('全局最优: 680.63\n');
fprintf('距离:     %.4f\n', abs(median(final_results) - 680.63));
fprintf('\n约束满足情况: %d/%d 次运行满足所有约束\n', sum(constraints_satisfied), n_runs);

% 创建结果表格
fprintf('\n'); fprintf(repmat('-', 1, 80)); fprintf('\n');
fprintf('%-6s %-15s %-15s\n', 'Run', 'Final Value', 'Constraints');
fprintf(repmat('-', 1, 80)); fprintf('\n');
for i = 1:n_runs
    if constraints_satisfied(i)
        status = '✓';
    else
        status = '✗';
    end
    fprintf('%-6d %-15.4f %-15s\n', i, final_results(i), status);
end
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 可视化结果
fprintf('\n绘制收敛趋势图...\n');

% 图1: 收敛趋势
figure('Position', [100, 100, 1200, 600]);
plot(1:max_generations, global_median, 'r-', 'LineWidth', 2, 'DisplayName', 'Median');
hold on;
plot(1:max_generations, global_best, 'g-', 'LineWidth', 2, 'DisplayName', 'Best');
plot(1:max_generations, global_worst, 'b-', 'LineWidth', 2, 'DisplayName', 'Worst');
plot(1:max_generations, global_mean, 'c-', 'LineWidth', 2, 'DisplayName', 'Mean');
plot([1, max_generations], [680.63, 680.63], 'k--', 'LineWidth', 2, 'DisplayName', 'Global Optimum');

xlabel('Generation', 'FontSize', 12);
ylabel('Objective Function Value', 'FontSize', 12);
title('Convergence Trend (20 Runs)', 'FontSize', 14);
legend('show', 'Location', 'best');
grid on;
saveas(gcf, 'convergence_trend.png');

% 图2: 最终结果分布
figure('Position', [100, 100, 1000, 600]);
subplot(1, 2, 1);
histogram(final_results, 15, 'FaceColor', [0.2 0.6 0.8], 'EdgeColor', 'k');
hold on;
plot([680.63, 680.63], ylim, 'r--', 'LineWidth', 2, 'DisplayName', 'Global Optimum');
xlabel('Objective Function Value', 'FontSize', 12);
ylabel('Frequency', 'FontSize', 12);
title('Distribution of Final Results', 'FontSize', 14);
legend('Final Values', 'Global Optimum');
grid on;

subplot(1, 2, 2);
boxplot(final_results, 'Labels', {'Final Results'});
hold on;
plot([0.5, 1.5], [680.63, 680.63], 'r--', 'LineWidth', 2);
ylabel('Objective Function Value', 'FontSize', 12);
title('Box Plot of Final Results', 'FontSize', 14);
grid on;

sgtitle('G9 Function Optimization Results', 'FontSize', 16, 'FontWeight', 'bold');
saveas(gcf, 'results_distribution.png');

fprintf('优化完成！结果已保存。\n');

%% 函数定义

function [f, constraints] = G9_penalized(x, penalty_factor)
    % G9约束优化问题（带惩罚函数）
    %
    % 输入:
    %   x: 决策变量向量 (7维)
    %   penalty_factor: 惩罚系数
    %
    % 输出:
    %   f: 惩罚后的目标函数值
    %   constraints: 约束违反值向量

    % 目标函数
    f_obj = (x(1)-10)^2 + 5*(x(2)-12)^2 + x(3)^4 + 3*(x(4)-11)^2 + ...
            10*x(5)^6 + 7*x(6)^2 + x(7)^4 - 4*x(6)*x(7) - 10*x(6) - 8*x(7);

    % 约束条件 g(x) <= 0
    g = zeros(4, 1);
    g(1) = 2*x(1)^2 + 3*x(2)^4 + x(3) + 4*x(4)^2 + 5*x(5) - 127;
    g(2) = 7*x(1) + 3*x(2) + 10*x(3)^2 + x(4) - x(5) - 282;
    g(3) = 23*x(1) + x(2)^2 + 6*x(6)^2 - 8*x(7) - 196;
    g(4) = 4*x(1)^2 + x(2)^2 - 3*x(1)*x(2) + 2*x(3)^2 + 5*x(6) - 11*x(7);

    % 计算约束违反
    constraint_violation = sum(max(0, g));

    % 惩罚函数
    f = f_obj + penalty_factor * constraint_violation;

    % 返回约束值
    constraints = g;
end

function stop = outputFcnGA(options, state, flag, current_run_best)
    % GA输出函数，用于记录每代最优值
    %
    % 这个函数会在每代被调用，记录当前代的最优值

    stop = false;

    if strcmp(flag, 'iter')
        gen = state.Generation;
        if gen > 0 && gen <= length(current_run_best)
            current_run_best(gen) = state.Best(end);
        end
    end
end
