% PageRank结果可视化脚本
% 生成所有实验图表

clear; clc; close all;

% 加载实验结果
load('pagerank_results.mat');

% 设置图形属性
set(0, 'DefaultAxesFontSize', 12);
set(0, 'DefaultTextFontSize', 12);

%% 图1: 网络结构图
figure('Position', [100, 100, 1000, 800]);
G = digraph(A', page_names);
h = plot(G, 'Layout', 'force', 'EdgeColor', [0.3 0.3 0.3], 'LineWidth', 1.5);

% 根据PageRank调整节点大小和颜色
node_sizes = ranks_power * 1000 + 50;
h.MarkerSize = node_sizes;
h.NodeCData = ranks_power;
colormap('jet');
colorbar('FontSize', 12);

title('Web Page Network Structure with PageRank', 'FontSize', 16, 'FontWeight', 'bold');
xlabel('Node size and color represent PageRank value', 'FontSize', 12);

% 高亮显示最重要的节点
highlight(h, sorted_idx(1:3), 'NodeColor', 'r', 'MarkerSize', node_sizes(sorted_idx(1:3)));

saveas(gcf, 'figure1_network_structure.png');
fprintf('Saved: figure1_network_structure.png\n');

%% 图2: PageRank排名柱状图
figure('Position', [100, 100, 1200, 600]);

% 创建柱状图
bar(sorted_ranks, 'FaceColor', [0.2 0.6 0.8]);
hold on;

% 添加数值标签
for i = 1:length(sorted_ranks)
    text(i, sorted_ranks(i) + 0.003, sprintf('%.4f', sorted_ranks(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 10);
end

% 设置x轴标签
set(gca, 'XTick', 1:length(page_names));
set(gca, 'XTickLabel', page_names(sorted_idx));
xtickangle(45);

ylabel('PageRank Value', 'FontSize', 14);
title('PageRank Ranking of Web Pages (alpha = 0.85)', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
ylim([0, max(sorted_ranks) * 1.15]);

saveas(gcf, 'figure2_pagerank_ranking.png');
fprintf('Saved: figure2_pagerank_ranking.png\n');

%% 图3: 收敛曲线
figure('Position', [100, 100, 1000, 600]);

semilogy(1:length(convergence_error), convergence_error, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
grid on;

xlabel('Iteration Number', 'FontSize', 14);
ylabel('L1 Norm of Difference (log scale)', 'FontSize', 14);
title('Convergence of Power Iteration Method (alpha = 0.85)', 'FontSize', 16, 'FontWeight', 'bold');

% 添加收敛阈值线
hold on;
tolerance_line = 1e-8;
yline(tolerance_line, 'r--', 'LineWidth', 2, 'Label', 'Tolerance = 10^{-8}', 'FontSize', 12);

saveas(gcf, 'figure3_convergence_curve.png');
fprintf('Saved: figure3_convergence_curve.png\n');

%% 图4: 阻尼因子影响 - 排名变化
figure('Position', [100, 100, 1200, 700]);

% 选择前5个页面展示
top_pages = 5;
colors = lines(top_pages);

for i = 1:top_pages
    page_idx = sorted_idx(i);
    plot(alpha_values, ranks_alpha(page_idx, :), '-o', 'LineWidth', 2, ...
        'MarkerSize', 8, 'Color', colors(i, :), 'DisplayName', page_names{page_idx});
    hold on;
end

xlabel('Damping Factor (alpha)', 'FontSize', 14);
ylabel('PageRank Value', 'FontSize', 14);
title('Effect of Damping Factor on Top Pages', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 11);
grid on;

saveas(gcf, 'figure4_damping_factor_effect.png');
fprintf('Saved: figure4_damping_factor_effect.png\n');

%% 图5: 阻尼因子与收敛速度
figure('Position', [100, 100, 1000, 600]);

bar(alpha_values, iterations_alpha, 'FaceColor', [0.8 0.4 0.2]);
hold on;

% 添加数值标签
for i = 1:length(iterations_alpha)
    text(alpha_values(i), iterations_alpha(i) + 1, num2str(iterations_alpha(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 12, 'FontWeight', 'bold');
end

xlabel('Damping Factor (alpha)', 'FontSize', 14);
ylabel('Number of Iterations to Converge', 'FontSize', 14);
title('Convergence Speed vs Damping Factor', 'FontSize', 16, 'FontWeight', 'bold');
grid on;
ylim([0, max(iterations_alpha) * 1.15]);

saveas(gcf, 'figure5_convergence_speed.png');
fprintf('Saved: figure5_convergence_speed.png\n');

%% 图6: 入度/出度与PageRank的关系
figure('Position', [100, 100, 1400, 600]);

% 子图1: 入度 vs PageRank
subplot(1, 2, 1);
scatter(in_degree, ranks_power, 100, 'filled', 'MarkerFaceColor', [0.2 0.6 0.8]);
hold on;

% 添加标签
for i = 1:length(page_names)
    text(in_degree(i) + 0.1, ranks_power(i), page_names{i}, 'FontSize', 9);
end

% 拟合线
p = polyfit(in_degree, ranks_power, 1);
x_fit = linspace(min(in_degree), max(in_degree), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'r--', 'LineWidth', 2);

xlabel('In-Degree', 'FontSize', 14);
ylabel('PageRank Value', 'FontSize', 14);
title(sprintf('In-Degree vs PageRank (Corr = %.4f)', corr(in_degree, ranks_power)), ...
    'FontSize', 14, 'FontWeight', 'bold');
grid on;

% 子图2: 出度 vs PageRank
subplot(1, 2, 2);
scatter(out_degree, ranks_power, 100, 'filled', 'MarkerFaceColor', [0.8 0.4 0.2]);
hold on;

% 添加标签
for i = 1:length(page_names)
    text(out_degree(i) + 0.1, ranks_power(i), page_names{i}, 'FontSize', 9);
end

% 拟合线
p = polyfit(out_degree, ranks_power, 1);
x_fit = linspace(min(out_degree), max(out_degree), 100);
y_fit = polyval(p, x_fit);
plot(x_fit, y_fit, 'r--', 'LineWidth', 2);

xlabel('Out-Degree', 'FontSize', 14);
ylabel('PageRank Value', 'FontSize', 14);
title(sprintf('Out-Degree vs PageRank (Corr = %.4f)', corr(out_degree, ranks_power)), ...
    'FontSize', 14, 'FontWeight', 'bold');
grid on;

saveas(gcf, 'figure6_degree_vs_pagerank.png');
fprintf('Saved: figure6_degree_vs_pagerank.png\n');

%% 图7: PageRank值的迭代演化（选择几个代表性页面）
figure('Position', [100, 100, 1200, 700]);

selected_pages = [sorted_idx(1), sorted_idx(6), sorted_idx(12)]; % 最高、中间、最低
colors = ['r', 'g', 'b'];

for i = 1:length(selected_pages)
    page_idx = selected_pages(i);
    plot(0:size(history_power, 2)-1, history_power(page_idx, :), ...
        [colors(i), '-'], 'LineWidth', 2, 'DisplayName', page_names{page_idx});
    hold on;
end

xlabel('Iteration Number', 'FontSize', 14);
ylabel('PageRank Value', 'FontSize', 14);
title('Evolution of PageRank Values During Iteration', 'FontSize', 16, 'FontWeight', 'bold');
legend('Location', 'best', 'FontSize', 12);
grid on;

saveas(gcf, 'figure7_pagerank_evolution.png');
fprintf('Saved: figure7_pagerank_evolution.png\n');

fprintf('\n=== All visualizations completed ===\n');
fprintf('Total figures generated: 7\n');
