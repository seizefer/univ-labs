%% Lab 1 - Spoken Digit Recognition
% 语音数字识别实验
% 使用KNN和SVM算法对Audio MNIST数据集进行分类

clear; close all; clc;

%% 配置参数
data_dir = 'audio_mnist/recordings';
data_size = 2600;
test_ratio = 0.3;
n_mfcc_default = 20;

fprintf('Lab 1 - 语音数字识别\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 检查数据集是否存在
if ~exist(data_dir, 'dir')
    warning('数据集目录 %s 不存在', data_dir);
    fprintf('请将Audio MNIST数据集放置在正确的目录中\n');
    return;
end

%% Step 1: 读取并分割数据集
fprintf('\nStep 1: 读取并分割数据集\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 获取所有.wav文件
file_info = dir(fullfile(data_dir, '*.wav'));
file_list = {file_info.name};
n_files = length(file_list);

fprintf('找到 %d 个音频文件\n', n_files);

% 随机打乱并分割数据
rng(42); % 设置随机种子
indices = randperm(n_files);
file_list = file_list(indices);

split_point = floor(n_files * test_ratio);
test_list = file_list(1:split_point);
train_list = file_list(split_point+1:end);

fprintf('训练集: %d 个样本\n', length(train_list));
fprintf('测试集: %d 个样本\n', length(test_list));

%% Step 2: 提取MFCC特征
fprintf('\nStep 2: 提取MFCC特征 (n_mfcc=%d)\n', n_mfcc_default);
fprintf(repmat('-', 1, 80)); fprintf('\n');

[train_features, train_labels] = extractMFCCFeatures(data_dir, train_list, n_mfcc_default);
[test_features, test_labels] = extractMFCCFeatures(data_dir, test_list, n_mfcc_default);

fprintf('训练集形状: [%d, %d]\n', size(train_features));
fprintf('测试集形状: [%d, %d]\n', size(test_features));

%% Step 3: 数据标准化
fprintf('\nStep 3: 数据标准化\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 计算均值和标准差
mu = mean(train_features, 1);
sigma = std(train_features, 0, 1);

% 标准化
train_features_std = (train_features - mu) ./ sigma;
test_features_std = (test_features - mu) ./ sigma;

% 绘制标准化后的分布
figure('Position', [100, 100, 800, 600]);
histogram(train_features_std(:, 1), 50, 'Normalization', 'pdf', ...
    'FaceAlpha', 0.6, 'DisplayName', 'Data Distribution');
hold on;
x = linspace(-3, 3, 100);
plot(x, normpdf(x, 0, 1), 'r-', 'LineWidth', 2, ...
    'DisplayName', 'Standard Normal Distribution');
xlabel('Feature Value', 'FontSize', 12);
ylabel('Density', 'FontSize', 12);
title('Standardized Feature Distribution', 'FontSize', 14);
legend('show');
grid on;
saveas(gcf, 'standardized_distribution.png');

fprintf('数据标准化完成\n');

%% Step 4: KNN分类器 (默认参数)
fprintf('\nStep 4: 训练KNN分类器 (k=5)\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

k = 5;
knn_model = fitcknn(train_features_std, train_labels, 'NumNeighbors', k);
knn_predictions = predict(knn_model, test_features_std);

% 计算性能指标
knn_accuracy = sum(knn_predictions == test_labels) / length(test_labels);
knn_f1 = calculateF1Score(test_labels, knn_predictions);

fprintf('KNN (k=%d) Accuracy: %.4f\n', k, knn_accuracy);
fprintf('KNN (k=%d) F1 Score: %.4f\n', k, knn_f1);

% 绘制混淆矩阵
plotConfusionMatrix(test_labels, knn_predictions, ...
    sprintf('KNN Confusion Matrix (k=%d)', k), 'knn_confusion_matrix.png');

%% Step 5: SVM分类器 (默认参数)
fprintf('\nStep 5: 训练SVM分类器 (kernel=rbf)\n');
fprintf(repmat('-', 1, 80)); fprintf('\n');

% 使用RBF核的多类SVM
template = templateSVM('KernelFunction', 'rbf', 'Standardize', false);
svm_model = fitcecoc(train_features_std, train_labels, 'Learners', template);
svm_predictions = predict(svm_model, test_features_std);

% 计算性能指标
svm_accuracy = sum(svm_predictions == test_labels) / length(test_labels);
svm_f1 = calculateF1Score(test_labels, svm_predictions);

fprintf('SVM (kernel=rbf) Accuracy: %.4f\n', svm_accuracy);
fprintf('SVM (kernel=rbf) F1 Score: %.4f\n', svm_f1);

% 绘制混淆矩阵
plotConfusionMatrix(test_labels, svm_predictions, ...
    'SVM Confusion Matrix (kernel=rbf)', 'svm_confusion_matrix.png');

%% 实验1: 不同MFCC特征数量对比
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('实验1: 不同MFCC特征数量对比\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

mfcc_values = [10, 20, 30];
mfcc_results = [];

for i = 1:length(mfcc_values)
    n_mfcc = mfcc_values(i);
    fprintf('\n测试 n_mfcc = %d\n', n_mfcc);
    fprintf(repmat('-', 1, 60)); fprintf('\n');

    % 提取特征
    [train_feat, train_lab] = extractMFCCFeatures(data_dir, train_list, n_mfcc);
    [test_feat, test_lab] = extractMFCCFeatures(data_dir, test_list, n_mfcc);

    % 标准化
    mu_temp = mean(train_feat, 1);
    sigma_temp = std(train_feat, 0, 1);
    train_feat_std = (train_feat - mu_temp) ./ sigma_temp;
    test_feat_std = (test_feat - mu_temp) ./ sigma_temp;

    % KNN
    knn_temp = fitcknn(train_feat_std, train_lab, 'NumNeighbors', 5);
    knn_pred = predict(knn_temp, test_feat_std);
    knn_f1_temp = calculateF1Score(test_lab, knn_pred);

    % SVM
    template_temp = templateSVM('KernelFunction', 'rbf', 'Standardize', false);
    svm_temp = fitcecoc(train_feat_std, train_lab, 'Learners', template_temp);
    svm_pred = predict(svm_temp, test_feat_std);
    svm_f1_temp = calculateF1Score(test_lab, svm_pred);

    mfcc_results = [mfcc_results; n_mfcc, knn_f1_temp, svm_f1_temp];

    fprintf('KNN F1 Score: %.4f\n', knn_f1_temp);
    fprintf('SVM F1 Score: %.4f\n', svm_f1_temp);
end

% 打印对比表格
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('MFCC特征数量对比结果\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('%-15s %-20s %-20s\n', 'n_mfcc', 'KNN F1 Score', 'SVM F1 Score');
fprintf(repmat('-', 1, 80)); fprintf('\n');
for i = 1:size(mfcc_results, 1)
    fprintf('%-15d %-20.4f %-20.4f\n', mfcc_results(i, 1), ...
        mfcc_results(i, 2), mfcc_results(i, 3));
end
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 实验2: 不同KNN邻居数对比
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('实验2: 不同KNN邻居数对比\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

neighbor_values = [3, 5, 7];
knn_results = [];

for i = 1:length(neighbor_values)
    k_temp = neighbor_values(i);
    fprintf('\n测试 n_neighbors = %d\n', k_temp);

    knn_temp = fitcknn(train_features_std, train_labels, 'NumNeighbors', k_temp);
    knn_pred = predict(knn_temp, test_features_std);
    f1_temp = calculateF1Score(test_labels, knn_pred);

    knn_results = [knn_results; k_temp, f1_temp];
    fprintf('F1 Score: %.4f\n', f1_temp);
end

% 打印对比表格
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('KNN邻居数对比结果\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('%-15s %-20s\n', 'n_neighbors', 'F1 Score');
fprintf(repmat('-', 1, 80)); fprintf('\n');
for i = 1:size(knn_results, 1)
    fprintf('%-15d %-20.4f\n', knn_results(i, 1), knn_results(i, 2));
end
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 实验3: 不同SVM核函数对比
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('实验3: 不同SVM核函数对比\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

kernel_names = {'linear', 'rbf', 'polynomial'};
kernel_types = {'linear', 'rbf', 'polynomial'};
svm_results = cell(length(kernel_names), 2);

for i = 1:length(kernel_types)
    kernel = kernel_types{i};
    fprintf('\n测试 kernel = %s\n', kernel);

    template_temp = templateSVM('KernelFunction', kernel, 'Standardize', false);
    svm_temp = fitcecoc(train_features_std, train_labels, 'Learners', template_temp);
    svm_pred = predict(svm_temp, test_features_std);
    f1_temp = calculateF1Score(test_labels, svm_pred);

    svm_results{i, 1} = kernel_names{i};
    svm_results{i, 2} = f1_temp;

    fprintf('F1 Score: %.4f\n', f1_temp);

    % 绘制混淆矩阵
    plotConfusionMatrix(test_labels, svm_pred, ...
        sprintf('SVM Confusion Matrix (kernel=%s)', kernel), ...
        sprintf('svm_%s_confusion_matrix.png', kernel));
end

% 打印对比表格
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('SVM核函数对比结果\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('%-15s %-20s\n', 'Kernel', 'F1 Score');
fprintf(repmat('-', 1, 80)); fprintf('\n');
for i = 1:size(svm_results, 1)
    fprintf('%-15s %-20.4f\n', svm_results{i, 1}, svm_results{i, 2});
end
fprintf(repmat('=', 1, 80)); fprintf('\n');

fprintf('\n所有实验完成！\n');

%% 辅助函数

function [features, labels] = extractMFCCFeatures(data_dir, file_list, n_mfcc)
    % 从音频文件中提取MFCC特征
    %
    % 输入:
    %   data_dir: 数据目录
    %   file_list: 文件名列表
    %   n_mfcc: MFCC系数数量
    %
    % 输出:
    %   features: 特征矩阵
    %   labels: 标签向量

    n_files = length(file_list);
    labels = zeros(n_files, 1);
    features_cell = cell(n_files, 1);

    for i = 1:n_files
        file_name = file_list{i};
        file_path = fullfile(data_dir, file_name);

        try
            % 读取音频文件
            [audio_data, sample_rate] = audioread(file_path);

            % 如果是立体声，转换为单声道
            if size(audio_data, 2) > 1
                audio_data = mean(audio_data, 2);
            end

            % 提取标签
            parts = strsplit(file_name, '_');
            labels(i) = str2double(parts{1});

            % 提取MFCC特征
            mfcc_feat = mfcc(audio_data, sample_rate, 'NumCoeffs', n_mfcc);

            % 展平为向量
            features_cell{i} = mfcc_feat(:)';
        catch
            warning('处理文件 %s 时出错', file_name);
            features_cell{i} = [];
        end
    end

    % 找到所有特征的最大长度
    feature_lengths = cellfun(@length, features_cell);
    max_length = max(feature_lengths);

    % 填充或截断特征到相同长度
    features = zeros(n_files, max_length);
    for i = 1:n_files
        feat = features_cell{i};
        if ~isempty(feat)
            if length(feat) < max_length
                features(i, 1:length(feat)) = feat;
            else
                features(i, :) = feat(1:max_length);
            end
        end
    end
end

function f1 = calculateF1Score(true_labels, predicted_labels)
    % 计算微平均F1分数
    %
    % 输入:
    %   true_labels: 真实标签
    %   predicted_labels: 预测标签
    %
    % 输出:
    %   f1: F1分数

    % 微平均F1等于准确率
    f1 = sum(true_labels == predicted_labels) / length(true_labels);
end

function plotConfusionMatrix(true_labels, predicted_labels, title_text, save_path)
    % 绘制混淆矩阵
    %
    % 输入:
    %   true_labels: 真实标签
    %   predicted_labels: 预测标签
    %   title_text: 图表标题
    %   save_path: 保存路径

    % 计算混淆矩阵
    cm = confusionmat(true_labels, predicted_labels);

    % 绘图
    figure('Position', [100, 100, 800, 700]);
    imagesc(cm);
    colormap(flipud(gray));
    colorbar;

    % 添加数值标注
    [rows, cols] = size(cm);
    for i = 1:rows
        for j = 1:cols
            text(j, i, num2str(cm(i, j)), ...
                'HorizontalAlignment', 'center', ...
                'VerticalAlignment', 'middle', ...
                'Color', 'red', 'FontSize', 10);
        end
    end

    xlabel('Predicted', 'FontSize', 12);
    ylabel('Ground Truth', 'FontSize', 12);
    title(title_text, 'FontSize', 14);
    set(gca, 'XTick', 1:10, 'XTickLabel', 0:9);
    set(gca, 'YTick', 1:10, 'YTickLabel', 0:9);

    % 保存图片
    saveas(gcf, save_path);
end
