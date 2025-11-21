% operational test
test_frequency_analysis();

function [estimated_k, decrypted_text] = caesar_frequency_analysis(ciphertext)
% The most common letters in the English language (in order of frequency)
common_letters = 'etaoinshrdlcumwfgypbvkjxqz';
% Calculate the frequency of each letter in the ciphertext
freq = zeros(1, 26);
for i = 1:length(ciphertext)
    if isstrprop(ciphertext(i), 'alpha')
        index = double(lower(ciphertext(i))) - 96;
        freq(index) = freq(index) + 1;
    end
end
% Find the letter that appears most frequently in the ciphertext
[~, most_frequent] = max(freq);
most_frequent_char = char(most_frequent + 96);
% Estimated k-value (assuming that the most frequent letter corresponds to the most common letter 'e' in English)
estimated_k = mod(double(most_frequent_char) - double('e') + 26, 26);
% Decryption using estimated k
decrypted_text = '';
for i = 1:length(ciphertext)
    if isstrprop(ciphertext(i), 'alpha')
        decrypted_char = mod(double(lower(ciphertext(i))) - double('a') - estimated_k + 26, 26) + double('a');
        decrypted_text = [decrypted_text, char(decrypted_char)];
    else
        decrypted_text = [decrypted_text, ciphertext(i)];
    end
end
end

% Test Functions
function test_frequency_analysis()
% Encryption function
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

% Test text
plaintext = 'the energetic teacher presented her excellent lesson, deeply engaging every eager student, ensuring they received exemplary education';
true_k = 9;
% Encryption
ciphertext = caesar_encrypt(plaintext, true_k);
disp(['Ciphertext: ', ciphertext]);
% Declassified by frequency-of-use analysis
[estimated_k, decrypted_text] = caesar_frequency_analysis(ciphertext);
disp(['Estimated k: ', num2str(estimated_k)]);
disp(['Decrypted text: ', decrypted_text]);
disp(['True k: ', num2str(true_k)]);
disp(['Original text: ', plaintext]);
end
