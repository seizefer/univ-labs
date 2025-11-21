original_text = 'this is a secret message';
k_original = 9;

% Encryption
encrypted_text = caesar_encrypt(original_text, k_original);
disp(['Encrypted text: ', encrypted_text]);

% Violent cracking
decrypted_texts = caesar_brute_force(encrypted_text);

% Show all possible decryption results
for i = 1:26
    disp(['k = ', num2str(i-1), ': ', decrypted_texts{i}]);
end

function ciphertext = caesar_encrypt(plaintext, k)
% Convert plaintext to lowercase
plaintext = lower(plaintext);
% Initialize the ciphertext
ciphertext = '';
for i = 1:length(plaintext)
    if isletter(plaintext(i))
        % Get the ASCII value of a character
        ascii_val = double(plaintext(i));
        % Applying encryption formulas
        encrypted_val = mod(ascii_val - 97 + k, 26) + 97;
        % Converting encrypted ASCII values back to characters
        ciphertext = [ciphertext, char(encrypted_val)];
    else
        % If it's not a letter, leave it as it is
        ciphertext = [ciphertext, plaintext(i)];
    end
end
end

function decrypted_texts = caesar_brute_force(ciphertext)
decrypted_texts = cell(1, 26);
for k = 0:25
    decrypted_text = '';
    for i = 1:length(ciphertext)
        if isletter(ciphertext(i))
            % Get the ASCII value of a character
            ascii_val = double(ciphertext(i));
            % Applying the decryption formula
            decrypted_val = mod(ascii_val - 97 - k + 26, 26) + 97;
            % Convert decrypted ASCII values back to characters
            decrypted_text = [decrypted_text, char(decrypted_val)];
        else
            % If it's not a letter, leave it as it is
            decrypted_text = [decrypted_text, ciphertext(i)];
        end
    end
    decrypted_texts{k+1} = decrypted_text;
end
end
