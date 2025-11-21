%% MATLAB Based Design Exercise - Hybrid Energy Storage System
% Course: UESTC4003 - Control
% This script simulates a wind turbine + battery + super-capacitor system
% for grid stability control

clear; clc; close all;

%% Load Wind Power Data
fprintf('Loading wind power data...\n');
data = readtable('gridwatch wind data.csv');
wind_power = data.wind;  % Power in kW
n_samples = length(wind_power);
dt = 5 * 60;  % 5 minutes in seconds
time = (0:n_samples-1) * dt;  % Time in seconds
time_hours = time / 3600;  % Time in hours

%% System Parameters
% Load parameters
P_load_constant = 450;  % Constant load in kW
P_load_disturbance = 750;  % Disturbance load in kW

% Battery parameters (optimized through trial-and-error)
battery_params.capacity = 500;  % kWh
battery_params.max_power = 300;  % kW (max charge/discharge rate)
battery_params.efficiency = 0.95;  % Charge/discharge efficiency
battery_params.initial_soc = 0.5;  % Initial state of charge (50%)
battery_params.soc_min = 0.2;  % Minimum SOC
battery_params.soc_max = 0.9;  % Maximum SOC
battery_params.voltage = 400;  % Nominal voltage (V)

% Super-capacitor parameters (optimized through trial-and-error)
sc_params.capacitance = 100;  % Farads
sc_params.max_power = 500;  % kW (high power for transient response)
sc_params.voltage_max = 800;  % Maximum voltage (V)
sc_params.voltage_min = 400;  % Minimum voltage (V)
sc_params.esr = 0.01;  % Equivalent series resistance (Ohms)
sc_params.initial_voltage = 600;  % Initial voltage (V)
sc_params.efficiency = 0.98;  % Higher efficiency than battery

%% Case 1: Constant Load Simulation
fprintf('\n=== Case 1: Constant Load (450 kW) ===\n');

% Initialize battery state
battery_soc = zeros(n_samples, 1);
battery_power = zeros(n_samples, 1);
battery_energy = zeros(n_samples, 1);
battery_soc(1) = battery_params.initial_soc;
battery_energy(1) = battery_params.capacity * battery_soc(1);

% Power balance for constant load
P_load = P_load_constant * ones(n_samples, 1);
P_net = wind_power - P_load;  % Positive = excess, Negative = deficit

% Simulate battery operation
for i = 2:n_samples
    % Determine required battery power
    P_required = -P_net(i);  % Positive = discharge, Negative = charge

    % Apply battery constraints
    [P_actual, new_soc, new_energy] = battery_model(...
        P_required, battery_soc(i-1), battery_energy(i-1), ...
        battery_params, dt);

    battery_power(i) = P_actual;
    battery_soc(i) = new_soc;
    battery_energy(i) = new_energy;
end

% Store Case 1 results
case1.time = time_hours;
case1.wind_power = wind_power;
case1.load_power = P_load;
case1.battery_power = battery_power;
case1.battery_soc = battery_soc;
case1.battery_energy = battery_energy;
case1.net_power = P_net;

% Calculate Case 1 statistics
case1.avg_wind = mean(wind_power);
case1.max_battery_discharge = max(battery_power);
case1.min_battery_charge = min(battery_power);
case1.soc_range = [min(battery_soc), max(battery_soc)];

fprintf('Average wind power: %.2f kW\n', case1.avg_wind);
fprintf('Battery SOC range: [%.2f%%, %.2f%%]\n', ...
    case1.soc_range(1)*100, case1.soc_range(2)*100);
fprintf('Max discharge: %.2f kW, Max charge: %.2f kW\n', ...
    case1.max_battery_discharge, -case1.min_battery_charge);

%% Case 2: Load with Disturbance Simulation
fprintf('\n=== Case 2: Load with Disturbance ===\n');

% Create load profile with disturbance at mid-day
P_load_case2 = P_load_constant * ones(n_samples, 1);

% Find mid-day index (approximately 12 hours from start)
% Data starts at 16:00, so mid-day would be around sample 144 (12:00 next day)
midday_idx = 144;  % Approximately 12 hours from start
disturbance_duration = 5 * 60;  % 5 minutes in seconds
n_disturbance_samples = round(disturbance_duration / dt);

% Apply disturbance
if n_disturbance_samples < 1
    n_disturbance_samples = 1;
end
P_load_case2(midday_idx:min(midday_idx+n_disturbance_samples-1, n_samples)) = P_load_disturbance;

% Initialize states for Case 2
battery_soc2 = zeros(n_samples, 1);
battery_power2 = zeros(n_samples, 1);
battery_energy2 = zeros(n_samples, 1);
sc_voltage = zeros(n_samples, 1);
sc_power = zeros(n_samples, 1);
sc_energy = zeros(n_samples, 1);

battery_soc2(1) = battery_params.initial_soc;
battery_energy2(1) = battery_params.capacity * battery_soc2(1);
sc_voltage(1) = sc_params.initial_voltage;
sc_energy(1) = 0.5 * sc_params.capacitance * sc_voltage(1)^2 / 1e6;  % kWh

% Power balance for Case 2
P_net2 = wind_power - P_load_case2;

% Simulate hybrid system operation
for i = 2:n_samples
    % Determine required power
    P_required = -P_net2(i);  % Positive = discharge, Negative = charge

    % Super-capacitor handles fast transients (high frequency component)
    % Use high-pass filter approach: SC handles sudden changes
    if i > 1
        P_change = P_required - (-P_net2(i-1));
    else
        P_change = 0;
    end

    % Super-capacitor responds to rapid changes and high power demands
    if abs(P_change) > 50 || abs(P_required) > battery_params.max_power
        % Super-capacitor handles the transient
        P_sc_required = P_change + max(0, abs(P_required) - battery_params.max_power) * sign(P_required);

        [P_sc_actual, new_voltage, new_sc_energy] = supercapacitor_model(...
            P_sc_required, sc_voltage(i-1), sc_params, dt);

        sc_power(i) = P_sc_actual;
        sc_voltage(i) = new_voltage;
        sc_energy(i) = new_sc_energy;

        % Battery handles the rest
        P_battery_required = P_required - P_sc_actual;
    else
        % Battery handles steady-state
        P_battery_required = P_required;
        sc_power(i) = 0;
        sc_voltage(i) = sc_voltage(i-1);
        sc_energy(i) = sc_energy(i-1);
    end

    % Apply battery model
    [P_bat_actual, new_soc, new_energy] = battery_model(...
        P_battery_required, battery_soc2(i-1), battery_energy2(i-1), ...
        battery_params, dt);

    battery_power2(i) = P_bat_actual;
    battery_soc2(i) = new_soc;
    battery_energy2(i) = new_energy;
end

% Store Case 2 results
case2.time = time_hours;
case2.wind_power = wind_power;
case2.load_power = P_load_case2;
case2.battery_power = battery_power2;
case2.battery_soc = battery_soc2;
case2.battery_energy = battery_energy2;
case2.sc_power = sc_power;
case2.sc_voltage = sc_voltage;
case2.sc_energy = sc_energy;
case2.net_power = P_net2;

% Calculate Case 2 statistics
case2.max_sc_power = max(abs(sc_power));
case2.sc_response_time = dt;  % Response within one time step
case2.soc_range = [min(battery_soc2), max(battery_soc2)];

fprintf('Max SC power: %.2f kW\n', case2.max_sc_power);
fprintf('SC response time: %.1f seconds\n', case2.sc_response_time);
fprintf('Battery SOC range: [%.2f%%, %.2f%%]\n', ...
    case2.soc_range(1)*100, case2.soc_range(2)*100);

%% Plot Results
fprintf('\nGenerating plots...\n');

% Figure 1: Case 1 - Constant Load Results
figure('Name', 'Case 1: Constant Load', 'Position', [100, 100, 1200, 800]);

subplot(3,2,1);
plot(time_hours, wind_power, 'b-', 'LineWidth', 1.5);
hold on;
plot(time_hours, P_load, 'r--', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Wind Power vs Load');
legend('Wind Power', 'Load', 'Location', 'best');
grid on;

subplot(3,2,2);
plot(time_hours, P_net, 'g-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Net Power (Wind - Load)');
grid on;
yline(0, 'k--');

subplot(3,2,3);
plot(time_hours, battery_power, 'm-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Battery Power (+ = discharge, - = charge)');
grid on;
yline(0, 'k--');

subplot(3,2,4);
plot(time_hours, battery_soc * 100, 'c-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('SOC (%)');
title('Battery State of Charge');
ylim([0, 100]);
grid on;

subplot(3,2,5);
plot(time_hours, battery_energy, 'Color', [0.5, 0, 0.5], 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Energy (kWh)');
title('Battery Stored Energy');
grid on;

subplot(3,2,6);
% Power balance verification
P_balance = wind_power - P_load - battery_power;
plot(time_hours, P_balance, 'k-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Power Balance Error');
grid on;

saveas(gcf, 'case1_constant_load.png');
saveas(gcf, 'case1_constant_load.fig');

% Figure 2: Case 2 - Load with Disturbance Results
figure('Name', 'Case 2: Load with Disturbance', 'Position', [150, 100, 1200, 900]);

subplot(4,2,1);
plot(time_hours, wind_power, 'b-', 'LineWidth', 1.5);
hold on;
plot(time_hours, P_load_case2, 'r-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Wind Power vs Load (with Disturbance)');
legend('Wind Power', 'Load', 'Location', 'best');
grid on;

subplot(4,2,2);
plot(time_hours, P_net2, 'g-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Net Power');
grid on;
yline(0, 'k--');

subplot(4,2,3);
plot(time_hours, battery_power2, 'm-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Battery Power');
grid on;
yline(0, 'k--');

subplot(4,2,4);
plot(time_hours, battery_soc2 * 100, 'c-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('SOC (%)');
title('Battery State of Charge');
ylim([0, 100]);
grid on;

subplot(4,2,5);
plot(time_hours, sc_power, 'Color', [1, 0.5, 0], 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Super-capacitor Power');
grid on;
yline(0, 'k--');

subplot(4,2,6);
plot(time_hours, sc_voltage, 'Color', [0.5, 0.5, 0], 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Voltage (V)');
title('Super-capacitor Voltage');
grid on;

subplot(4,2,7);
plot(time_hours, sc_energy, 'Color', [0, 0.5, 0.5], 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Energy (kWh)');
title('Super-capacitor Stored Energy');
grid on;

subplot(4,2,8);
% Zoomed view around disturbance
dist_start = max(1, midday_idx - 10);
dist_end = min(n_samples, midday_idx + 15);
zoom_time = time_hours(dist_start:dist_end);
plot(zoom_time, P_load_case2(dist_start:dist_end), 'r-', 'LineWidth', 2);
hold on;
plot(zoom_time, sc_power(dist_start:dist_end), 'Color', [1, 0.5, 0], 'LineWidth', 1.5);
plot(zoom_time, battery_power2(dist_start:dist_end), 'm--', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Zoomed: Disturbance Response');
legend('Load', 'SC Power', 'Battery Power', 'Location', 'best');
grid on;

saveas(gcf, 'case2_disturbance.png');
saveas(gcf, 'case2_disturbance.fig');

% Figure 3: System Comparison
figure('Name', 'System Comparison', 'Position', [200, 100, 1000, 600]);

subplot(2,2,1);
bar([case1.avg_wind, P_load_constant; 0, 0]);
set(gca, 'XTickLabel', {'Average', ''});
ylabel('Power (kW)');
title('Power Comparison');
legend('Wind', 'Load', 'Location', 'northeast');
grid on;

subplot(2,2,2);
plot(time_hours, case1.battery_soc * 100, 'b-', 'LineWidth', 1.5);
hold on;
plot(time_hours, case2.battery_soc * 100, 'r-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('SOC (%)');
title('Battery SOC Comparison');
legend('Case 1', 'Case 2', 'Location', 'best');
grid on;

subplot(2,2,3);
histogram(P_net, 20, 'FaceColor', 'b', 'FaceAlpha', 0.7);
xlabel('Net Power (kW)');
ylabel('Frequency');
title('Net Power Distribution');
grid on;

subplot(2,2,4);
% Energy flow summary
categories = {'Wind Gen', 'Load', 'Battery', 'SC'};
case1_energy = [sum(wind_power)*dt/3600, sum(P_load)*dt/3600, ...
    sum(abs(battery_power))*dt/3600, 0];
case2_energy = [sum(wind_power)*dt/3600, sum(P_load_case2)*dt/3600, ...
    sum(abs(battery_power2))*dt/3600, sum(abs(sc_power))*dt/3600];
bar([case1_energy; case2_energy]');
set(gca, 'XTickLabel', categories);
ylabel('Energy (kWh)');
title('Energy Flow Summary');
legend('Case 1', 'Case 2', 'Location', 'northeast');
grid on;

saveas(gcf, 'system_comparison.png');
saveas(gcf, 'system_comparison.fig');

%% Save Results for Python Analysis
fprintf('\nSaving results for analysis...\n');

% Save to CSV for Python processing
results_table = table(time_hours', wind_power, P_load, battery_power, ...
    battery_soc, P_load_case2, battery_power2, battery_soc2, ...
    sc_power, sc_voltage, ...
    'VariableNames', {'time_hours', 'wind_power', 'load_case1', ...
    'battery_power_case1', 'battery_soc_case1', 'load_case2', ...
    'battery_power_case2', 'battery_soc_case2', 'sc_power', 'sc_voltage'});
writetable(results_table, 'simulation_results.csv');

% Save parameters
params_struct.battery = battery_params;
params_struct.supercapacitor = sc_params;
params_struct.load_constant = P_load_constant;
params_struct.load_disturbance = P_load_disturbance;
save('system_parameters.mat', 'params_struct', 'case1', 'case2');

fprintf('\nSimulation completed successfully!\n');
fprintf('Results saved to:\n');
fprintf('  - case1_constant_load.png/fig\n');
fprintf('  - case2_disturbance.png/fig\n');
fprintf('  - system_comparison.png/fig\n');
fprintf('  - simulation_results.csv\n');
fprintf('  - system_parameters.mat\n');
