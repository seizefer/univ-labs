% =========================================================================
% Task 4: Playfair密码矩阵生成
% =========================================================================
% 功能说明：
%   Playfair密码使用5x5矩阵进行加密
%   本程序根据给定的关键词生成Playfair密码矩阵
%   矩阵中I和J被视为同一字母（因为矩阵只有25个位置）
% =========================================================================

% 测试1：使用关键词"Security"生成矩阵
disp('=== Playfair Matrix Generation ===');
disp(' ');
disp('Playfair matrix for keyword "Security":');
matrix1 = generate_playfair_matrix('Security');
disp(matrix1);
disp(' ');

% 测试2：使用姓名"Wang"生成矩阵
disp('Playfair matrix for keyword "Wang":');
matrix2 = generate_playfair_matrix('Wang');
disp(matrix2);
disp(' ');

% 测试3：使用姓名"Zhang"生成矩阵
disp('Playfair matrix for keyword "Zhang":');
matrix3 = generate_playfair_matrix('Zhang');
disp(matrix3);

% =========================================================================
% Playfair矩阵生成函数
% =========================================================================
% 输入参数：
%   keyword - 用于生成矩阵的关键词字符串
% 输出参数：
%   matrix - 5x5的Playfair密码矩阵
% =========================================================================
function matrix = generate_playfair_matrix(keyword)
    % 将关键词转换为大写
    keyword = upper(keyword);

    % 移除非字母字符
    keyword = keyword(isstrprop(keyword, 'alpha'));

    % 将J替换为I（Playfair密码的标准做法）
    keyword = strrep(keyword, 'J', 'I');

    % 定义字母表（不包含J，共25个字母）
    alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ';

    % 初始化5x5矩阵
    matrix = char(zeros(5, 5));

    % 用于记录已使用的字符
    used_chars = '';

    % 当前填充位置
    row = 1;
    col = 1;

    % 步骤1：首先填入关键词中的字符（去重）
    for i = 1:length(keyword)
        % 检查字符是否已被使用
        if ~contains(used_chars, keyword(i))
            % 将字符填入矩阵
            matrix(row, col) = keyword(i);
            % 记录已使用的字符
            used_chars = [used_chars, keyword(i)];

            % 移动到下一个位置
            col = col + 1;
            if col > 5
                col = 1;
                row = row + 1;
            end
        end
    end

    % 步骤2：填入剩余的字母（按字母表顺序）
    for i = 1:length(alphabet)
        % 检查字母是否已被使用
        if ~contains(used_chars, alphabet(i))
            % 将字母填入矩阵
            matrix(row, col) = alphabet(i);

            % 移动到下一个位置
            col = col + 1;
            if col > 5
                col = 1;
                row = row + 1;
            end
        end
    end
end

% =========================================================================
% Playfair密码加密规则（参考）：
% 1. 将明文分成两个字母一组（digrams）
% 2. 如果一组中两个字母相同，插入填充字母'X'
% 3. 对每一组应用以下规则：
%    - 同一行：每个字母替换为其右边的字母（循环）
%    - 同一列：每个字母替换为其下边的字母（循环）
%    - 不同行列：每个字母替换为同行、另一字母所在列的字母
%
% 示例（使用关键词"monarchy"）：
%   矩阵：
%   M O N A R
%   C H Y B D
%   E F G I K
%   L P Q S T
%   U V W X Z
%
%   明文"hs"加密为"BP"（矩形规则）
%   明文"ar"加密为"RM"（同一行规则）
% =========================================================================
