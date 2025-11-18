%% Lab 3 - Task 1: 微波双工器性能评估
% Microwave Diplexer Performance Evaluation
% 评估双工器响应是否满足设计规范

clear; close all; clc;

fprintf('Lab 3 - Task 1: 微波双工器性能评估\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 加载数据
% 注意: 需要先下载T_junctioni_best.mat数据文件
data_file = 'T_junctioni_best.mat';

if ~exist(data_file, 'file')
    warning('数据文件 %s 不存在', data_file);
    fprintf('请从实验材料中下载数据文件\n');
    fprintf('继续使用模拟数据进行演示...\n\n');

    % 创建模拟数据用于演示
    f = linspace(12, 14, 1000); % 频率范围 12-14 GHz
    S11_val = -25 + 10*rand(size(f)); % 模拟S11
    S21_val = -30 + 15*rand(size(f)); % 模拟S21
    S31_val = -40 + 20*rand(size(f)); % 模拟S31
else
    % 加载实际数据
    load(data_file);
    % 假设数据格式为: f, S11_val, S21_val, S31_val
end

%% 调用性能评估函数
perf = evaluate(f, S11_val, S21_val, S31_val);

%% 显示结果
fprintf('\n性能评估结果:\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');
fprintf('E1 (S11 @ 12.5-12.75 GHz, threshold=-20dB): %.4f dB\n', perf(1));
fprintf('E2 (S11 @ 13-13.25 GHz, threshold=-20dB):    %.4f dB\n', perf(2));
fprintf('E3 (S21 @ 12-12.3 GHz, threshold=-20dB):     %.4f dB\n', perf(3));
fprintf('E4 (S21 @ 13-13.25 GHz, threshold=-55dB):    %.4f dB\n', perf(4));
fprintf('E5 (S31 @ 12.5-12.75 GHz, threshold=-55dB):  %.4f dB\n', perf(5));
fprintf('E6 (S31 @ 13.4-13.75 GHz, threshold=-20dB):  %.4f dB\n', perf(6));
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 判断是否满足规范
if all(perf == 0)
    fprintf('\n结论: 所有规范都得到满足! ✓\n');
else
    fprintf('\n结论: 存在规范违反，最大违反值: %.4f dB\n', max(perf));
end

%% 绘制S参数响应
plotDiplexerResponse(f, S11_val, S21_val, S31_val, perf);

%% 核心函数: evaluate
function perf = evaluate(f, S11_val, S21_val, S31_val)
    % 微波双工器性能评估函数
    %
    % 输入:
    %   f: 频率向量 (GHz)
    %   S11_val: S11参数幅度 (dB)
    %   S21_val: S21参数幅度 (dB)
    %   S31_val: S31参数幅度 (dB)
    %
    % 输出:
    %   perf: 性能向量 [E1, E2, E3, E4, E5, E6]
    %         每个E表示对应频率范围内的规范违反值
    %         如果E=0，表示满足规范
    %         如果E>0，表示最大违反值(dB)

    % 初始化性能向量
    perf = zeros(1, 6);

    % 定义频率范围和阈值
    % E1: S11_val ≤ -20 dB, 12.5~12.75 GHz
    freq_range = [12.5, 12.75];
    threshold = -20;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        % 计算违反值: max(S11_val - threshold, 0)
        violations = S11_val(idx) - threshold;
        perf(1) = max(0, max(violations));
    end

    % E2: S11_val ≤ -20 dB, 13~13.25 GHz
    freq_range = [13, 13.25];
    threshold = -20;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        violations = S11_val(idx) - threshold;
        perf(2) = max(0, max(violations));
    end

    % E3: S21_val ≤ -20 dB, 12~12.3 GHz
    freq_range = [12, 12.3];
    threshold = -20;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        violations = S21_val(idx) - threshold;
        perf(3) = max(0, max(violations));
    end

    % E4: S21_val ≤ -55 dB, 13~13.25 GHz
    freq_range = [13, 13.25];
    threshold = -55;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        violations = S21_val(idx) - threshold;
        perf(4) = max(0, max(violations));
    end

    % E5: S31_val ≤ -55 dB, 12.5~12.75 GHz
    freq_range = [12.5, 12.75];
    threshold = -55;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        violations = S31_val(idx) - threshold;
        perf(5) = max(0, max(violations));
    end

    % E6: S31_val ≤ -20 dB, 13.4~13.75 GHz
    freq_range = [13.4, 13.75];
    threshold = -20;
    idx = find(f >= freq_range(1) & f <= freq_range(2));
    if ~isempty(idx)
        violations = S31_val(idx) - threshold;
        perf(6) = max(0, max(violations));
    end
end

function plotDiplexerResponse(f, S11_val, S21_val, S31_val, perf)
    % 绘制双工器响应曲线
    %
    % 输入:
    %   f: 频率向量
    %   S11_val, S21_val, S31_val: S参数
    %   perf: 性能向量

    figure('Position', [100, 100, 1200, 800]);

    % S11响应
    subplot(3, 1, 1);
    plot(f, S11_val, 'b-', 'LineWidth', 1.5);
    hold on;
    % 绘制规范线
    plot([12.5, 12.75], [-20, -20], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 1');
    plot([13, 13.25], [-20, -20], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 2');
    xlabel('Frequency (GHz)', 'FontSize', 11);
    ylabel('S11 (dB)', 'FontSize', 11);
    title('S11 Response', 'FontSize', 12);
    legend('S11', 'Specifications', 'Location', 'best');
    grid on;
    xlim([min(f), max(f)]);

    % S21响应
    subplot(3, 1, 2);
    plot(f, S21_val, 'g-', 'LineWidth', 1.5);
    hold on;
    % 绘制规范线
    plot([12, 12.3], [-20, -20], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 1');
    plot([13, 13.25], [-55, -55], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 2');
    xlabel('Frequency (GHz)', 'FontSize', 11);
    ylabel('S21 (dB)', 'FontSize', 11);
    title('S21 Response', 'FontSize', 12);
    legend('S21', 'Specifications', 'Location', 'best');
    grid on;
    xlim([min(f), max(f)]);

    % S31响应
    subplot(3, 1, 3);
    plot(f, S31_val, 'm-', 'LineWidth', 1.5);
    hold on;
    % 绘制规范线
    plot([12.5, 12.75], [-55, -55], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 1');
    plot([13.4, 13.75], [-20, -20], 'r--', 'LineWidth', 2, 'DisplayName', 'Spec 2');
    xlabel('Frequency (GHz)', 'FontSize', 11);
    ylabel('S31 (dB)', 'FontSize', 11);
    title('S31 Response', 'FontSize', 12);
    legend('S31', 'Specifications', 'Location', 'best');
    grid on;
    xlim([min(f), max(f)]);

    sgtitle('Diplexer S-Parameter Responses', 'FontSize', 14, 'FontWeight', 'bold');
    saveas(gcf, 'diplexer_responses.png');
end
