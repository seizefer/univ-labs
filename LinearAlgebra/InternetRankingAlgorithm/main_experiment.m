% PageRank算法主实验脚本
% 本脚本执行所有实验并保存结果

clear; clc; close all;

fprintf('=== PageRank Algorithm Experiments ===\n\n');

%% 实验1: 创建网络并分析结构
fprintf('Experiment 1: Network Creation and Analysis\n');
fprintf('--------------------------------------------\n');
[A, page_names] = create_network();
n = length(page_names);

%% 实验2: 基础PageRank计算（alpha = 0.85）
fprintf('\n\nExperiment 2: Basic PageRank Computation\n');
fprintf('--------------------------------------------\n');
alpha = 0.85;
tolerance = 1e-8;
max_iter = 1000;

% 幂迭代法
fprintf('\n[Power Iteration Method]\n');
[ranks_power, history_power, iter_power] = pagerank_power_method(A, alpha, tolerance, max_iter);

% 特征值方法
fprintf('\n[Eigenvalue Method]\n');
[ranks_eigen, eigenval, time_eigen] = pagerank_eigenvalue_method(A, alpha);

% 比较两种方法的结果
fprintf('\n[Comparison of Two Methods]\n');
diff_methods = norm(ranks_power - ranks_eigen, inf);
fprintf('Maximum difference between methods: %.2e\n', diff_methods);

%% 实验3: PageRank排名结果
fprintf('\n\nExperiment 3: PageRank Ranking Results\n');
fprintf('--------------------------------------------\n');

% 排序并显示
[sorted_ranks, sorted_idx] = sort(ranks_power, 'descend');

fprintf('\n%-5s %-20s %15s %12s\n', 'Rank', 'Page Name', 'PageRank', 'Percentage');
fprintf('%-5s %-20s %15s %12s\n', '----', '---------', '--------', '----------');
for i = 1:n
    fprintf('%-5d %-20s %15.6f %11.2f%%\n', ...
        i, page_names{sorted_idx(i)}, sorted_ranks(i), sorted_ranks(i)*100);
end

% 保存排名结果到文件
results_table = table((1:n)', page_names(sorted_idx), sorted_ranks, sorted_ranks*100, ...
    'VariableNames', {'Rank', 'PageName', 'PageRank', 'Percentage'});
writetable(results_table, 'pagerank_results.csv');
fprintf('\nResults saved to: pagerank_results.csv\n');

%% 实验4: 阻尼因子影响分析
fprintf('\n\nExperiment 4: Damping Factor Sensitivity Analysis\n');
fprintf('--------------------------------------------\n');

alpha_values = [0.5, 0.75, 0.85, 0.95];
ranks_alpha = zeros(n, length(alpha_values));
iterations_alpha = zeros(1, length(alpha_values));

for i = 1:length(alpha_values)
    alpha_test = alpha_values(i);
    fprintf('Testing alpha = %.2f... ', alpha_test);
    [ranks_temp, ~, iter_temp] = pagerank_power_method(A, alpha_test, tolerance, max_iter);
    ranks_alpha(:, i) = ranks_temp;
    iterations_alpha(i) = iter_temp;
end

fprintf('\n%-8s %12s\n', 'Alpha', 'Iterations');
fprintf('%-8s %12s\n', '-----', '----------');
for i = 1:length(alpha_values)
    fprintf('%-8.2f %12d\n', alpha_values(i), iterations_alpha(i));
end

%% 实验5: 收敛性分析
fprintf('\n\nExperiment 5: Convergence Analysis\n');
fprintf('--------------------------------------------\n');

% 使用alpha=0.85的收敛历史
convergence_error = zeros(1, size(history_power, 2)-1);
for i = 1:length(convergence_error)
    convergence_error(i) = norm(history_power(:, i+1) - history_power(:, i), 1);
end

fprintf('Convergence rate analysis:\n');
fprintf('Iteration %5d: Error = %.2e\n', 1, convergence_error(1));
fprintf('Iteration %5d: Error = %.2e\n', 10, convergence_error(min(10, length(convergence_error))));
if length(convergence_error) >= 20
    fprintf('Iteration %5d: Error = %.2e\n', 20, convergence_error(20));
end
fprintf('Final iteration %d: Error = %.2e\n', iter_power, convergence_error(iter_power));

%% 实验6: 网络结构分析
fprintf('\n\nExperiment 6: Network Structure Analysis\n');
fprintf('--------------------------------------------\n');

in_degree = sum(A, 2);
out_degree = sum(A, 1)';

% 计算相关系数
corr_in = corr(in_degree, ranks_power);
corr_out = corr(out_degree, ranks_power);

fprintf('Correlation between In-Degree and PageRank: %.4f\n', corr_in);
fprintf('Correlation between Out-Degree and PageRank: %.4f\n', corr_out);

% 保存网络分析结果
network_analysis = table(page_names, in_degree, out_degree, ranks_power, ...
    'VariableNames', {'PageName', 'InDegree', 'OutDegree', 'PageRank'});
writetable(network_analysis, 'network_analysis.csv');
fprintf('\nNetwork analysis saved to: network_analysis.csv\n');

%% 保存所有数据到.mat文件供可视化使用
fprintf('\n\nSaving all results to MAT file...\n');
save('pagerank_results.mat', 'A', 'page_names', 'ranks_power', 'ranks_eigen', ...
    'history_power', 'convergence_error', 'alpha_values', 'ranks_alpha', ...
    'iterations_alpha', 'in_degree', 'out_degree', 'sorted_idx', 'sorted_ranks');
fprintf('All results saved to: pagerank_results.mat\n');

fprintf('\n=== All Experiments Completed ===\n');
