function [adjacency_matrix, page_names] = create_network()
    % 创建12个网页的学术网站链接结构
    % 输出:
    %   adjacency_matrix: 邻接矩阵，A(i,j)=1表示页面j链接到页面i
    %   page_names: 网页名称的cell数组

    % 定义网页名称
    page_names = {
        'Homepage';           % 1
        'CS_Dept';           % 2
        'Math_Dept';         % 3
        'Library';           % 4
        'Course_Portal';     % 5
        'Linear_Algebra';    % 6
        'Data_Science';      % 7
        'Student_Resources'; % 8
        'Research';          % 9
        'Faculty';           % 10
        'Admissions';        % 11
        'Alumni'             % 12
    };

    n = length(page_names);
    adjacency_matrix = zeros(n, n);

    % 定义链接关系 (from -> to)
    % Homepage (1) 的出链
    adjacency_matrix([2, 3, 4, 5, 11], 1) = 1;

    % CS_Dept (2) 的出链
    adjacency_matrix([1, 7, 9, 10], 2) = 1;

    % Math_Dept (3) 的出链
    adjacency_matrix([1, 6, 9, 10], 3) = 1;

    % Library (4) 的出链
    adjacency_matrix([1, 5, 9], 4) = 1;

    % Course_Portal (5) 的出链
    adjacency_matrix([1, 6, 7, 8], 5) = 1;

    % Linear_Algebra (6) 的出链
    adjacency_matrix([3, 5, 7, 8], 6) = 1;

    % Data_Science (7) 的出链
    adjacency_matrix([2, 5, 6, 8], 7) = 1;

    % Student_Resources (8) 的出链
    adjacency_matrix([1, 4, 5], 8) = 1;

    % Research (9) 的出链
    adjacency_matrix([1, 2, 3, 10], 9) = 1;

    % Faculty (10) 的出链
    adjacency_matrix([1, 2, 3, 9], 10) = 1;

    % Admissions (11) 的出链
    adjacency_matrix([1, 2, 3, 12], 11) = 1;

    % Alumni (12) 的出链 - Dead End (没有出链)
    % adjacency_matrix(:, 12) = 0;  % 已经是0

    fprintf('Network created with %d pages\n', n);
    fprintf('Total links: %d\n', sum(adjacency_matrix(:)));

    % 打印每个页面的入度和出度
    in_degree = sum(adjacency_matrix, 2);
    out_degree = sum(adjacency_matrix, 1)';

    fprintf('\nPage Statistics:\n');
    fprintf('%-20s %10s %10s\n', 'Page Name', 'In-Degree', 'Out-Degree');
    fprintf('%-20s %10s %10s\n', '----------', '---------', '----------');
    for i = 1:n
        fprintf('%-20s %10d %10d', page_names{i}, in_degree(i), out_degree(i));
        if out_degree(i) == 0
            fprintf(' (Dead End)');
        end
        fprintf('\n');
    end
end
