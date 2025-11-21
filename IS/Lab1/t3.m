% =========================================================================
% Task 3: 使用频率分析法破解Caesar密码
% =========================================================================
% 功能说明：
%   利用英文字母频率统计特性破解Caesar密码
%   在英文中，字母'e'出现频率最高，通过找到密文中最高频字母
%   与'e'的距离，可以估算出密钥k
% =========================================================================

% 运行测试函数
test_frequency_analysis();

% =========================================================================
% 频率分析破解函数
% =========================================================================
% 输入参数：
%   ciphertext - 待破解的密文字符串
% 输出参数：
%   estimated_k - 估算的密钥值
%   decrypted_text - 使用估算密钥解密的结果
% =========================================================================
function [estimated_k, decrypted_text] = caesar_frequency_analysis(ciphertext)
    % 英文字母按出现频率排序（从高到低）
    % e, t, a, o, i, n 是最常见的字母
    common_letters = 'etaoinshrdlcumwfgypbvkjxqz';

    % 初始化频率统计数组（26个字母）
    freq = zeros(1, 26);

    % 统计密文中每个字母出现的次数
    for i = 1:length(ciphertext)
        if isstrprop(ciphertext(i), 'alpha')
            % 将字母转换为1-26的索引
            index = double(lower(ciphertext(i))) - 96;
            freq(index) = freq(index) + 1;
        end
    end

    % 找到密文中出现频率最高的字母
    [~, most_frequent] = max(freq);
    most_frequent_char = char(most_frequent + 96);

    % 假设最高频字母对应英文中最常见的字母'e'
    % 计算密钥k = 最高频字母 - 'e'
    estimated_k = mod(double(most_frequent_char) - double('e') + 26, 26);

    % 使用估算的k值进行解密
    decrypted_text = '';
    for i = 1:length(ciphertext)
        if isstrprop(ciphertext(i), 'alpha')
            % 应用解密公式
            decrypted_char = mod(double(lower(ciphertext(i))) - double('a') - estimated_k + 26, 26) + double('a');
            decrypted_text = [decrypted_text, char(decrypted_char)];
        else
            % 保留非字母字符
            decrypted_text = [decrypted_text, ciphertext(i)];
        end
    end
end

% =========================================================================
% 测试函数
% =========================================================================
% 功能说明：
%   使用一段富含字母'e'的测试文本来验证频率分析方法的有效性
% =========================================================================
function test_frequency_analysis()
    % 内嵌加密函数
    function ciphertext = caesar_encrypt(plaintext, k)
        plaintext = lower(plaintext);
        ciphertext = '';
        for i = 1:length(plaintext)
            if isstrprop(plaintext(i), 'alpha')
                ciphertext = [ciphertext, char(mod(double(plaintext(i)) - double('a') + k, 26) + double('a'))];
            else
                ciphertext = [ciphertext, plaintext(i)];
            end
        end
    end

    % 测试文本（刻意选择包含大量字母'e'的文本以验证频率分析）
    plaintext = 'the energetic teacher presented her excellent lesson, deeply engaging every eager student, ensuring they received exemplary education';
    true_k = 9;  % 真实的加密密钥

    % 加密明文
    ciphertext = caesar_encrypt(plaintext, true_k);

    % 显示加密结果
    disp('=== Frequency Analysis Test ===');
    disp(['Original text: ', plaintext]);
    disp(['True k: ', num2str(true_k)]);
    disp(['Ciphertext: ', ciphertext]);
    disp(' ');

    % 使用频率分析进行破解
    [estimated_k, decrypted_text] = caesar_frequency_analysis(ciphertext);

    % 显示破解结果
    disp('=== Decryption Results ===');
    disp(['Estimated k: ', num2str(estimated_k)]);
    disp(['Decrypted text: ', decrypted_text]);

    % 验证结果
    if estimated_k == true_k
        disp(' ');
        disp('SUCCESS: Frequency analysis correctly identified the key!');
    else
        disp(' ');
        disp('NOTE: Estimated key differs from true key. This can happen with short texts.');
    end
end

% =========================================================================
% 方法原理：
%   1. 英文中字母'e'的出现频率约为12.7%，是最常见的字母
%   2. Caesar密码是单表替换密码，字母频率分布模式保持不变
%   3. 通过找到密文中频率最高的字母，假设它对应明文中的'e'
%   4. 两者的距离就是密钥k
%
% 局限性：
%   - 对于短文本可能不准确
%   - 如果明文中'e'不是最高频字母，方法会失效
%   - 可以尝试第二、第三高频字母来提高准确性
% =========================================================================
