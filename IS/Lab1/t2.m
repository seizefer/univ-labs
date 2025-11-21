% =========================================================================
% Task 2: Caesar密码加密与暴力破解
% =========================================================================
% 功能说明：
%   1. 使用Caesar密码对明文进行加密
%   2. 使用暴力破解方法尝试所有可能的k值（0-25）解密
%   3. 通过目视检查找到正确的解密结果
% =========================================================================

% 定义原始明文
original_text = 'this is a secret message';
% 使用的加密密钥（由Task1计算得到）
k_original = 9;

% 加密过程
encrypted_text = caesar_encrypt(original_text, k_original);
disp(['Original text: ', original_text]);
disp(['Encryption key k = ', num2str(k_original)]);
disp(['Encrypted text: ', encrypted_text]);
disp(' ');

% 暴力破解：尝试所有可能的k值
disp('=== Brute Force Decryption Results ===');
decrypted_texts = caesar_brute_force(encrypted_text);

% 显示所有可能的解密结果
for i = 1:26
    disp(['k = ', num2str(i-1), ': ', decrypted_texts{i}]);
end

% =========================================================================
% Caesar密码加密函数
% =========================================================================
% 输入参数：
%   plaintext - 待加密的明文字符串
%   k - 加密密钥（位移量）
% 输出参数：
%   ciphertext - 加密后的密文字符串
% =========================================================================
function ciphertext = caesar_encrypt(plaintext, k)
    % 将明文转换为小写字母
    plaintext = lower(plaintext);
    % 初始化密文字符串
    ciphertext = '';

    % 遍历明文中的每个字符
    for i = 1:length(plaintext)
        if isletter(plaintext(i))
            % 获取字符的ASCII值
            ascii_val = double(plaintext(i));
            % 应用Caesar加密公式: C = (p + k) mod 26
            % 'a'的ASCII值为97，所以先减97转换到0-25范围
            encrypted_val = mod(ascii_val - 97 + k, 26) + 97;
            % 将加密后的ASCII值转换回字符
            ciphertext = [ciphertext, char(encrypted_val)];
        else
            % 非字母字符保持不变（如空格、标点）
            ciphertext = [ciphertext, plaintext(i)];
        end
    end
end

% =========================================================================
% Caesar密码暴力破解函数
% =========================================================================
% 输入参数：
%   ciphertext - 待破解的密文字符串
% 输出参数：
%   decrypted_texts - 包含26种可能解密结果的元胞数组
% =========================================================================
function decrypted_texts = caesar_brute_force(ciphertext)
    % 初始化结果元胞数组
    decrypted_texts = cell(1, 26);

    % 尝试所有可能的k值（0到25）
    for k = 0:25
        decrypted_text = '';

        % 对每个字符进行解密
        for i = 1:length(ciphertext)
            if isletter(ciphertext(i))
                % 获取字符的ASCII值
                ascii_val = double(ciphertext(i));
                % 应用Caesar解密公式: p = (C - k) mod 26
                % 加26确保取模前为正数
                decrypted_val = mod(ascii_val - 97 - k + 26, 26) + 97;
                % 将解密后的ASCII值转换回字符
                decrypted_text = [decrypted_text, char(decrypted_val)];
            else
                % 非字母字符保持不变
                decrypted_text = [decrypted_text, ciphertext(i)];
            end
        end

        % 存储当前k值对应的解密结果
        decrypted_texts{k+1} = decrypted_text;
    end
end

% =========================================================================
% 预期结果：
% 当k=9时，解密结果应该是原始明文"this is a secret message"
% 这验证了加密和解密过程的正确性
% =========================================================================
