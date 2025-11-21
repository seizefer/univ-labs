%% Lab 3: Channel Coding - Linear Block Codes
% 信道编码实验 - 线性分组码
% 本实验实现线性分组码的编码、解码和伴随式解码

clear; close all; clc;

%% Exercise 1: (6,3) Linear Block Code
fprintf('=== Exercise 1: (6,3) Linear Block Code ===\n\n');

% 定义P矩阵
P = [0 1 1; 1 0 1; 1 1 0];

% 参数
k = 3;                  % 消息长度
n = 6;                  % 码字长度
r = n - k;              % 校验位数

% 生成矩阵 G = [P | I_k]
genmat = [P, eye(k)];

fprintf('Generator Matrix G:\n');
disp(genmat);

%% Exercise 1a: 编码消息 [1 1 1] 和 [1 0 1]
fprintf('--- Exercise 1a ---\n');

msg1 = [1 1 1];
msg2 = [1 0 1];

code1 = encode(msg1, n, k, 'linear/binary', genmat);
code2 = encode(msg2, n, k, 'linear/binary', genmat);

fprintf('Message [1 1 1] -> Code: ');
disp(code1);
fprintf('Message [1 0 1] -> Code: ');
disp(code2);

%% Exercise 1b: 编码所有可能的消息
fprintf('--- Exercise 1b ---\n');

% 所有可能的3位消息
all_messages = [0 0 0; 0 0 1; 0 1 0; 0 1 1; 1 0 0; 1 0 1; 1 1 0; 1 1 1];

% 编码所有消息
all_codes = encode(all_messages, n, k, 'linear/binary', genmat);

% 计算汉明重量
weights = sum(all_codes, 2);

fprintf('\nMESSAGE\t\tCODE VECTOR\t\tWeight\n');
fprintf('-------\t\t-----------\t\t------\n');
for i = 1:8
    fprintf('%d%d%d\t\t%d%d%d%d%d%d\t\t%d\n', ...
        all_messages(i,1), all_messages(i,2), all_messages(i,3), ...
        all_codes(i,1), all_codes(i,2), all_codes(i,3), ...
        all_codes(i,4), all_codes(i,5), all_codes(i,6), ...
        weights(i));
end

%% Exercise 1c-f: 计算码的性质
fprintf('\n--- Exercise 1c-f ---\n');

% 最小汉明距离（非零码字的最小重量）
nonzero_weights = weights(weights > 0);
d_min = min(nonzero_weights);
fprintf('c) Minimum Hamming Distance d_min = %d\n', d_min);

% 可检测错误数
detect_errors = d_min - 1;
fprintf('d) Number of detectable errors = %d\n', detect_errors);

% 可纠正错误数
correct_errors = floor((d_min - 1) / 2);
fprintf('e) Number of correctable errors = %d\n', correct_errors);

% 码率
code_rate = k / n;
fprintf('f) Code rate = %d/%d = %.4f\n\n', k, n, code_rate);

%% Exercise 2: 编码8x8图像矩阵
fprintf('=== Exercise 2: Encode 8x8 Image Matrix ===\n\n');

% 创建字母'S'的8x8矩阵
image = [1, 1, 1, 0, 0, 1, 1, 1;
         1, 1, 0, 1, 1, 0, 1, 1;
         1, 1, 0, 1, 1, 1, 1, 1;
         1, 1, 1, 0, 1, 1, 1, 1;
         1, 1, 1, 1, 0, 1, 1, 1;
         1, 1, 1, 1, 1, 0, 1, 1;
         1, 1, 0, 1, 1, 0, 1, 1;
         1, 1, 1, 0, 0, 1, 1, 1];

% 显示原始图像
figure('Name', 'Exercise 2: Letter S');
subplot(1, 2, 1);
imshow(image);
title('Original Image (Letter S)');

% 定义P矩阵 (8x4)
P2 = [1 1 1 1;
      0 1 1 1;
      1 1 1 0;
      1 1 0 1;
      0 0 1 1;
      0 1 0 1;
      0 1 1 0;
      1 0 0 1];

% 参数: k=8, n-k=4, 所以n=12
k2 = 8;
n2 = 12;

% 生成矩阵
genmat2 = [P2, eye(k2)];

fprintf('P matrix size: %dx%d\n', size(P2, 1), size(P2, 2));
fprintf('k = %d, n = %d\n', k2, n2);

% 编码每一行
coded_image = zeros(8, n2);
for row = 1:8
    coded_image(row, :) = encode(image(row, :), n2, k2, 'linear/binary', genmat2);
end

fprintf('\nEncoded Image (8 rows x 12 bits):\n');
disp(coded_image);

% 显示编码后的图像
subplot(1, 2, 2);
imshow(coded_image);
title('Encoded Image (8x12)');
saveas(gcf, 'Lab3_Ex2_EncodedImage.png');

%% Exercise 3: Syndrome Decoding
fprintf('\n=== Exercise 3: Syndrome Decoding ===\n\n');

% (8,4) 线性分组码
k3 = 4;
n3 = 8;
r3 = n3 - k3;

% 生成矩阵和校验矩阵
P3 = [0 1 1 1;
      1 0 1 1;
      1 1 0 1;
      1 1 1 0];

G3 = [P3, eye(k3)];
H3 = [eye(r3), P3'];

fprintf('Generator Matrix G:\n');
disp(G3);
fprintf('Parity Check Matrix H:\n');
disp(H3);

%% 创建伴随式表
fprintf('--- Syndrome Table ---\n');

% 使用syndtable函数（如果可用）或手动创建
% 单比特错误模式
error_patterns = eye(n3);

fprintf('\nError Pattern\t\tSyndrome\n');
fprintf('-------------\t\t--------\n');

syndrome_table = zeros(n3, r3);
for i = 1:n3
    e = error_patterns(i, :);
    s = mod(e * H3', 2);
    syndrome_table(i, :) = s;
    fprintf('%d%d%d%d%d%d%d%d\t\t%d%d%d%d\n', ...
        e(1), e(2), e(3), e(4), e(5), e(6), e(7), e(8), ...
        s(1), s(2), s(3), s(4));
end

%% 解码接收向量
fprintf('\n--- Decode Received Vector ---\n');

z = [0 1 1 1 0 1 1 0];
fprintf('Received vector z = [%d %d %d %d %d %d %d %d]\n', z);

% 计算伴随式
s = mod(z * H3', 2);
fprintf('Syndrome s = [%d %d %d %d]\n', s);

% 查找匹配的错误模式
error_pos = 0;
for i = 1:n3
    if isequal(syndrome_table(i, :), s)
        error_pos = i;
        break;
    end
end

if error_pos > 0
    fprintf('Error detected at position: %d\n', error_pos);

    % 纠正错误
    corrected = z;
    corrected(error_pos) = mod(corrected(error_pos) + 1, 2);
    fprintf('Corrected vector = [%d %d %d %d %d %d %d %d]\n', corrected);

    % 提取消息
    msg_decoded = corrected(5:8);
    fprintf('Decoded message = [%d %d %d %d]\n', msg_decoded);
else
    if all(s == 0)
        fprintf('No error detected.\n');
        msg_decoded = z(5:8);
        fprintf('Decoded message = [%d %d %d %d]\n', msg_decoded);
    else
        fprintf('Error pattern not in table (multiple errors).\n');
    end
end

%% 验证示例
fprintf('\n--- Verification Example ---\n');

% 测试消息
m1 = [0 1 1 0];
m2 = [1 0 1 1];

% 编码
u1 = mod(m1 * G3, 2);
u2 = mod(m2 * G3, 2);

fprintf('m1 = [%d %d %d %d] -> u1 = [%d %d %d %d %d %d %d %d]\n', ...
    m1, u1);
fprintf('m2 = [%d %d %d %d] -> u2 = [%d %d %d %d %d %d %d %d]\n', ...
    m2, u2);

% 添加错误
e = [0 0 0 0 0 1 0 0];
z1 = mod(u1 + e, 2);
z2 = mod(u2 + e, 2);

fprintf('\nError pattern e = [%d %d %d %d %d %d %d %d]\n', e);
fprintf('z1 = u1 + e = [%d %d %d %d %d %d %d %d]\n', z1);
fprintf('z2 = u2 + e = [%d %d %d %d %d %d %d %d]\n', z2);

% 计算伴随式
s1 = mod(z1 * H3', 2);
s2 = mod(z2 * H3', 2);

fprintf('\nSyndrome s1 = [%d %d %d %d]\n', s1);
fprintf('Syndrome s2 = [%d %d %d %d]\n', s2);
fprintf('Syndromes are equal: %s\n', mat2str(isequal(s1, s2)));
fprintf('Error is in column 6 of H.\n');

fprintf('\n实验完成！\n');
