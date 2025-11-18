function perf = perf(f, S11_val, S21_val, S31_val)
    % Initialize performance vector
    perf = zeros(1, 6);

    % Define frequency ranges for each criterion
    
    % Find indices within the specified frequency range
    freq_ranges = {[12.5, 12.75], [13, 13.25], [12, 12.3], [13, 13.25], [12.5, 12.75], [13.4, 13.75]};

    % Criterion 1: S11_val ≤ -20 dB, 12.5~12.75 GHz
    idx = find(f >= freq_ranges{1}(1) & f <= freq_ranges{1}(2));
    
    % Calculate the violation, considering only values above the threshold
    violation = max(0, max(S11_val(idx) + 20));
    
    % Store the violation in the performance vector for Criterion 1
    perf(1) = violation;

    % Criterion 2: S11_val ≤ -20 dB, 13~13.25 GHz
    idx = find(f >= freq_ranges{2}(1) & f <= freq_ranges{2}(2));
    violation = max(0, max(S11_val(idx) + 20));
    perf(2) = violation;

    % Criterion 3: S21_val ≤ -20 dB, 12~12.3 GHz; S21_val ≤ -55 dB, 13~13.25 GHz
    idx = find(f >= freq_ranges{3}(1) & f <= freq_ranges{3}(2));
    violation = max(0, max(S21_val(idx) + 20));
    perf(3) = violation;

    idx = find(f >= freq_ranges{4}(1) & f <= freq_ranges{4}(2));
    violation = max(0, max(S21_val(idx) + 55));
    perf(4) = violation;

    % Criterion 5: S31_val ≤ -55 dB, 12.5~12.75 GHz
    idx = find(f >= freq_ranges{5}(1) & f <= freq_ranges{5}(2));
    violation = max(0, max(S31_val(idx) + 55));
    perf(5) = violation;

    % Criterion 6: S31_val ≤ -20 dB, 13.4~13.75 GHz
    idx = find(f >= freq_ranges{6}(1) & f <= freq_ranges{6}(2));
    violation = max(0, max(S31_val(idx) + 20));
    perf(6) = violation;
end
