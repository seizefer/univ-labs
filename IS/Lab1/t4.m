% Test Functions
disp('Playfair matrix for keyword "Security":')
disp(generate_playfair_matrix('Security'))

disp('Playfair matrix for your full name:')
disp(generate_playfair_matrix('Wang'))

disp('Playfair matrix for your full name:')
disp(generate_playfair_matrix('Zhang'))

function matrix = generate_playfair_matrix(keyword)
% Convert keywords to uppercase and remove non-alphabetic characters
keyword = upper(keyword);
keyword = keyword(isstrprop(keyword, 'alpha'));
% Treat I and J as the same character
keyword = strrep(keyword, 'J', 'I');
% Creation of the alphabet (excluding J)
alphabet = 'ABCDEFGHIKLMNOPQRSTUVWXYZ';
% Initialize the matrix
matrix = char(zeros(5, 5));
% Filling matrix
used_chars = '';
row = 1;
col = 1;
% First fill in the characters in the keyword
for i = 1:length(keyword)
    if ~contains(used_chars, keyword(i))
        matrix(row, col) = keyword(i);
        used_chars = [used_chars, keyword(i)];
        col = col + 1;
        if col > 5
            col = 1;
            row = row + 1;
        end
    end
end
% Then fill in the remaining letters
for i = 1:length(alphabet)
    if ~contains(used_chars, alphabet(i))
        matrix(row, col) = alphabet(i);
        col = col + 1;
        if col > 5
            col = 1;
            row = row + 1;
        end
    end
end
end
