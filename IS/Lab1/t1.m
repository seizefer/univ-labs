% Sum the GUIDs
guid1 = 2720906;
guid2 = 2720746;
sum_guids = guid1 + guid2;

% Add all individual digits repeatedly until the result is <= 25
result = sum(arrayfun(@(x) str2double(x), num2str(sum_guids)));

while result > 25
    result = sum(arrayfun(@(x) str2double(x), num2str(result)));
end

k = result; % Resulting key value
disp(['The key value k is: ', num2str(k)])
