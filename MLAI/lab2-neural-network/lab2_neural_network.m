%% Lab 2 - Neural Network
% 神经网络实验
% 使用MATLAB深度学习工具箱构建前馈神经网络对MNIST手写数字进行分类

clear; close all; clc;

fprintf('Lab 2 - 神经网络实验\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% Task 1: 张量变换演示
fprintf('\nTask 1: 张量变换演示\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

t = [2, 3, 5];
fprintf('原始张量形状: [1, %d], 值: [%d, %d, %d]\n', length(t), t(1), t(2), t(3));

% 方法1: 使用repmat
t1 = repmat(t, 10, 1);
fprintf('\n方法1 - repmat(): 形状 [%d, %d]\n', size(t1));
fprintf('说明: repmat()复制张量内容，创建新的内存空间\n');

% 方法2: 使用repelem
t2 = repmat(t, [10, 1]);
fprintf('\n方法2 - 另一种repmat用法: 形状 [%d, %d]\n', size(t2));
fprintf('说明: 两种方法结果相同，但MATLAB中repmat已经优化了内存使用\n');

fprintf('\n差异总结:\n');
fprintf('- MATLAB的repmat已经过优化，会智能管理内存\n');
fprintf('- 对于大型张量，MATLAB会采用写时复制(copy-on-write)策略\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% Task 2: 为什么需要Softmax
fprintf('\nTask 2: 为什么需要Softmax作为最后的激活函数\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('\n原因:\n');
fprintf('1. 概率解释: Softmax将原始输出转换为概率分布，所有输出和为1\n');
fprintf('2. 多分类任务: 对于10个数字的分类，softmax输出每个类别的概率\n');
fprintf('3. 数值稳定: Softmax处理了指数运算，使得训练更稳定\n');
fprintf('4. 与交叉熵损失配合: 使梯度计算更简洁高效\n');

raw_output = [2.0, 1.0, 0.1];
softmax_output = exp(raw_output) / sum(exp(raw_output));
fprintf('\n示例:\n');
fprintf('原始输出: [%.2f, %.2f, %.2f]\n', raw_output);
fprintf('Softmax输出: [%.4f, %.4f, %.4f]\n', softmax_output);
fprintf('输出总和: %.4f\n', sum(softmax_output));
fprintf(repmat('=', 1, 80)); fprintf('\n');

%% 加载MNIST数据集
fprintf('\n加载MNIST数据集...\n');

% 加载MATLAB内置的MNIST数据集
% 如果没有，需要先下载
try
    [XTrain, YTrain] = digitTrain4DArrayData;
    [XTest, YTest] = digitTest4DArrayData;
catch
    fprintf('正在下载MNIST数据集...\n');
    % 使用替代方法加载数据
    digitDatasetPath = fullfile(matlabroot,'toolbox','nnet','nndemos', ...
        'nndatasets','DigitDataset');
    imds = imageDatastore(digitDatasetPath, ...
        'IncludeSubfolders',true,'LabelSource','foldernames');

    % 分割训练集和测试集
    [imdsTrain,imdsTest] = splitEachLabel(imds,0.7,'randomize');

    % 调整图像大小为28x28
    XTrain = zeros(28, 28, 1, length(imdsTrain.Files));
    YTrain = categorical(zeros(length(imdsTrain.Files), 1));
    for i = 1:length(imdsTrain.Files)
        img = readimage(imdsTrain, i);
        XTrain(:,:,1,i) = imresize(img, [28 28]);
        YTrain(i) = imdsTrain.Labels(i);
    end

    XTest = zeros(28, 28, 1, length(imdsTest.Files));
    YTest = categorical(zeros(length(imdsTest.Files), 1));
    for i = 1:length(imdsTest.Files)
        img = readimage(imdsTest, i);
        XTest(:,:,1,i) = imresize(img, [28 28]);
        YTest(i) = imdsTest.Labels(i);
    end
end

% 归一化数据到[0,1]
XTrain = double(XTrain) / 255.0;
XTest = double(XTest) / 255.0;

fprintf('训练集大小: %d 样本\n', size(XTrain, 4));
fprintf('测试集大小: %d 样本\n', size(XTest, 4));

%% 显示数据示例
fprintf('\n显示数据示例...\n');

figure('Position', [100, 100, 1000, 600]);
for i = 1:6
    subplot(2, 3, i);
    imshow(XTrain(:,:,1,i));
    title(sprintf('Label: %s', string(YTrain(i))));
end
sgtitle('MNIST Sample Images');
saveas(gcf, 'mnist_samples.png');

%% 数据标准化示例
fprintf('\n数据标准化示例...\n');

% 对第一个样本进行标准化
sample_data = XTrain(:,:,1,1);
sample_flat = sample_data(:);

% 计算均值和标准差
mu = mean(sample_flat);
sigma = std(sample_flat);
sigma = max(sigma, 1.0/sqrt(28*28)); % 调整标准化

sample_std = (sample_flat - mu) / sigma;

% 绘制分布
figure('Position', [100, 100, 800, 600]);
histogram(sample_std, 50, 'Normalization', 'pdf', 'FaceAlpha', 0.6, ...
    'DisplayName', 'Data Distribution');
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

%% 构建神经网络
fprintf('\n构建前馈神经网络...\n');

layers = [
    imageInputLayer([28 28 1], 'Name', 'input', 'Normalization', 'zscore')

    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu1')

    fullyConnectedLayer(128, 'Name', 'fc2')
    reluLayer('Name', 'relu2')

    fullyConnectedLayer(256, 'Name', 'fc3')
    reluLayer('Name', 'relu3')

    fullyConnectedLayer(256, 'Name', 'fc4')
    reluLayer('Name', 'relu4')

    fullyConnectedLayer(10, 'Name', 'fc5')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

%% Task 3 & 4: 训练模型 (学习率=0.5)
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('Task 3 & 4: 训练模型 (学习率=0.5, 20轮)\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

options = trainingOptions('sgdm', ...
    'InitialLearnRate', 0.5, ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 128, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XTest, YTest}, ...
    'ValidationFrequency', 30, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'auto');

[net, trainInfo] = trainNetwork(XTrain, YTrain, layers, options);

% 提取训练历史
training_accuracy = trainInfo.ValidationAccuracy;
training_loss = trainInfo.TrainingLoss;

% 绘制训练历史
plotTrainingHistory(training_accuracy, training_loss, ...
    'training_history_lr0.5.png');

%% Task 5: 绘制混淆矩阵
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('Task 5: 绘制混淆矩阵\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

YPred = classify(net, XTest);
plotConfusionMatrixNN(YTest, YPred, 'Confusion Matrix (LR=0.5)', ...
    'confusion_matrix_lr0.5.png');

%% Task 6: 不同学习率对比
fprintf('\n'); fprintf(repmat('=', 1, 80)); fprintf('\n');
fprintf('Task 6: 不同学习率对比\n');
fprintf(repmat('=', 1, 80)); fprintf('\n');

learning_rates = [0.02, 0.1, 0.5];
results = cell(length(learning_rates), 1);

for i = 1:length(learning_rates)
    lr = learning_rates(i);
    fprintf('\n训练模型 (学习率=%.2f)...\n', lr);

    options_temp = trainingOptions('sgdm', ...
        'InitialLearnRate', lr, ...
        'MaxEpochs', 20, ...
        'MiniBatchSize', 128, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', {XTest, YTest}, ...
        'ValidationFrequency', 30, ...
        'Verbose', false, ...
        'Plots', 'none');

    [net_temp, trainInfo_temp] = trainNetwork(XTrain, YTrain, layers, options_temp);

    results{i} = struct(...
        'lr', lr, ...
        'accuracy', trainInfo_temp.ValidationAccuracy, ...
        'loss', trainInfo_temp.TrainingLoss);

    % 绘制单独的训练历史
    plotTrainingHistory(trainInfo_temp.ValidationAccuracy, ...
        trainInfo_temp.TrainingLoss, ...
        sprintf('training_history_lr%.2f.png', lr));
end

% 对比绘图
figure('Position', [100, 100, 1400, 600]);

subplot(1, 2, 1);
hold on;
for i = 1:length(results)
    res = results{i};
    epochs = 1:length(res.accuracy);
    plot(epochs, res.accuracy, '-o', 'LineWidth', 2, ...
        'DisplayName', sprintf('LR=%.2f', res.lr));
end
xlabel('Epochs', 'FontSize', 12);
ylabel('Test Accuracy', 'FontSize', 12);
title('Test Accuracy Comparison', 'FontSize', 14);
legend('show');
grid on;

subplot(1, 2, 2);
hold on;
for i = 1:length(results)
    res = results{i};
    epochs = 1:length(res.loss);
    plot(epochs, res.loss, '-o', 'LineWidth', 2, ...
        'DisplayName', sprintf('LR=%.2f', res.lr));
end
xlabel('Epochs', 'FontSize', 12);
ylabel('Train Loss', 'FontSize', 12);
title('Train Loss Comparison', 'FontSize', 14);
legend('show');
grid on;

saveas(gcf, 'learning_rate_comparison.png');

fprintf('\n所有实验完成！\n');

%% 辅助函数

function plotTrainingHistory(accuracy, losses, save_path)
    % 绘制训练历史
    %
    % 输入:
    %   accuracy: 准确率数组
    %   losses: 损失数组
    %   save_path: 保存路径

    figure('Position', [100, 100, 1400, 600]);

    subplot(1, 2, 1);
    epochs = 1:length(accuracy);
    plot(epochs, accuracy, 'b-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('Epochs', 'FontSize', 12);
    ylabel('Test Accuracy', 'FontSize', 12);
    title('Test Accuracy vs Epochs', 'FontSize', 14);
    grid on;

    subplot(1, 2, 2);
    epochs = 1:length(losses);
    plot(epochs, losses, 'r-o', 'LineWidth', 2, 'MarkerSize', 6);
    xlabel('Epochs', 'FontSize', 12);
    ylabel('Train Loss', 'FontSize', 12);
    title('Train Loss vs Epochs', 'FontSize', 14);
    grid on;

    saveas(gcf, save_path);
end

function plotConfusionMatrixNN(true_labels, predicted_labels, title_text, save_path)
    % 绘制混淆矩阵
    %
    % 输入:
    %   true_labels: 真实标签
    %   predicted_labels: 预测标签
    %   title_text: 图表标题
    %   save_path: 保存路径

    figure('Position', [100, 100, 800, 700]);
    cm = confusionchart(true_labels, predicted_labels);
    cm.Title = title_text;
    cm.RowSummary = 'row-normalized';
    cm.ColumnSummary = 'column-normalized';

    saveas(gcf, save_path);
end
