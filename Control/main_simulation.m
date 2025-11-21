%% MATLAB 设计练习 - 混合储能系统
% 课程: UESTC4003 - 控制
% 本脚本模拟风力发电机 + 电池 + 超级电容器系统
% 用于电网稳定性控制

clear; clc; close all;

%% 加载风力发电数据
fprintf('Loading wind power data...\n');
data = readtable('gridwatch wind data.csv');
wind_power = data.wind;  % 功率单位为 kW
n_samples = length(wind_power);
dt = 5 * 60;  % 5分钟转换为秒
time = (0:n_samples-1) * dt;  % 时间单位为秒
time_hours = time / 3600;  % 时间单位为小时

%% 系统参数设置
% 负载参数
P_load_constant = 450;  % 恒定负载 kW
P_load_disturbance = 750;  % 扰动负载 kW

% 电池参数（通过试错法优化）
battery_params.capacity = 500;  % 容量 kWh
battery_params.max_power = 300;  % 最大充放电功率 kW
battery_params.efficiency = 0.95;  % 充放电效率
battery_params.initial_soc = 0.5;  % 初始荷电状态 50%
battery_params.soc_min = 0.2;  % 最小 SOC
battery_params.soc_max = 0.9;  % 最大 SOC
battery_params.voltage = 400;  % 标称电压 V

% 超级电容器参数（通过试错法优化）
sc_params.capacitance = 100;  % 电容量 F
sc_params.max_power = 500;  % 最大功率 kW（用于瞬态响应）
sc_params.voltage_max = 800;  % 最大电压 V
sc_params.voltage_min = 400;  % 最小电压 V
sc_params.esr = 0.01;  % 等效串联电阻 Ohms
sc_params.initial_voltage = 600;  % 初始电压 V
sc_params.efficiency = 0.98;  % 效率高于电池

%% 案例1：恒定负载仿真
fprintf('\n=== Case 1: Constant Load (450 kW) ===\n');

% 初始化电池状态
battery_soc = zeros(n_samples, 1);
battery_power = zeros(n_samples, 1);
battery_energy = zeros(n_samples, 1);
battery_soc(1) = battery_params.initial_soc;
battery_energy(1) = battery_params.capacity * battery_soc(1);

% 恒定负载的功率平衡
P_load = P_load_constant * ones(n_samples, 1);
P_net = wind_power - P_load;  % 正值=过剩，负值=不足

% 模拟电池运行
for i = 2:n_samples
    % 确定所需电池功率
    P_required = -P_net(i);  % 正值=放电，负值=充电

    % 应用电池约束
    [P_actual, new_soc, new_energy] = battery_model(...
        P_required, battery_soc(i-1), battery_energy(i-1), ...
        battery_params, dt);

    battery_power(i) = P_actual;
    battery_soc(i) = new_soc;
    battery_energy(i) = new_energy;
end

% 保存案例1结果
case1.time = time_hours;
case1.wind_power = wind_power;
case1.load_power = P_load;
case1.battery_power = battery_power;
case1.battery_soc = battery_soc;
case1.battery_energy = battery_energy;
case1.net_power = P_net;

% 计算案例1统计数据
case1.avg_wind = mean(wind_power);
case1.max_battery_discharge = max(battery_power);
case1.min_battery_charge = min(battery_power);
case1.soc_range = [min(battery_soc), max(battery_soc)];

fprintf('Average wind power: %.2f kW\n', case1.avg_wind);
fprintf('Battery SOC range: [%.2f%%, %.2f%%]\n', ...
    case1.soc_range(1)*100, case1.soc_range(2)*100);
fprintf('Max discharge: %.2f kW, Max charge: %.2f kW\n', ...
    case1.max_battery_discharge, -case1.min_battery_charge);

%% 案例2：带扰动的负载仿真
fprintf('\n=== Case 2: Load with Disturbance ===\n');

% 创建带中午扰动的负载曲线
P_load_case2 = P_load_constant * ones(n_samples, 1);

% 找到中午时刻的索引（数据从16:00开始，所以中午大约在第144个采样点）
midday_idx = 144;
disturbance_duration = 5 * 60;  % 5分钟转换为秒
n_disturbance_samples = round(disturbance_duration / dt);

% 应用扰动
if n_disturbance_samples < 1
    n_disturbance_samples = 1;
end
P_load_case2(midday_idx:min(midday_idx+n_disturbance_samples-1, n_samples)) = P_load_disturbance;

% 初始化案例2的状态变量
battery_soc2 = zeros(n_samples, 1);
battery_power2 = zeros(n_samples, 1);
battery_energy2 = zeros(n_samples, 1);
sc_voltage = zeros(n_samples, 1);
sc_power = zeros(n_samples, 1);
sc_energy = zeros(n_samples, 1);

battery_soc2(1) = battery_params.initial_soc;
battery_energy2(1) = battery_params.capacity * battery_soc2(1);
sc_voltage(1) = sc_params.initial_voltage;
sc_energy(1) = 0.5 * sc_params.capacitance * sc_voltage(1)^2 / 1e6;  % 单位 kWh

% 案例2的功率平衡
P_net2 = wind_power - P_load_case2;

% 模拟混合系统运行
for i = 2:n_samples
    % 确定所需功率
    P_required = -P_net2(i);  % 正值=放电，负值=充电

    % 超级电容器处理快速瞬态（高频分量）
    % 使用高通滤波方法：超级电容器处理突变
    if i > 1
        P_change = P_required - (-P_net2(i-1));
    else
        P_change = 0;
    end

    % 超级电容器响应快速变化和高功率需求
    if abs(P_change) > 50 || abs(P_required) > battery_params.max_power
        % 超级电容器处理瞬态
        P_sc_required = P_change + max(0, abs(P_required) - battery_params.max_power) * sign(P_required);

        [P_sc_actual, new_voltage, new_sc_energy] = supercapacitor_model(...
            P_sc_required, sc_voltage(i-1), sc_params, dt);

        sc_power(i) = P_sc_actual;
        sc_voltage(i) = new_voltage;
        sc_energy(i) = new_sc_energy;

        % 电池处理剩余部分
        P_battery_required = P_required - P_sc_actual;
    else
        % 电池处理稳态
        P_battery_required = P_required;
        sc_power(i) = 0;
        sc_voltage(i) = sc_voltage(i-1);
        sc_energy(i) = sc_energy(i-1);
    end

    % 应用电池模型
    [P_bat_actual, new_soc, new_energy] = battery_model(...
        P_battery_required, battery_soc2(i-1), battery_energy2(i-1), ...
        battery_params, dt);

    battery_power2(i) = P_bat_actual;
    battery_soc2(i) = new_soc;
    battery_energy2(i) = new_energy;
end

% 保存案例2结果
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

% 计算案例2统计数据
case2.max_sc_power = max(abs(sc_power));
case2.sc_response_time = dt;  % 在一个时间步内响应
case2.soc_range = [min(battery_soc2), max(battery_soc2)];

fprintf('Max SC power: %.2f kW\n', case2.max_sc_power);
fprintf('SC response time: %.1f seconds\n', case2.sc_response_time);
fprintf('Battery SOC range: [%.2f%%, %.2f%%]\n', ...
    case2.soc_range(1)*100, case2.soc_range(2)*100);

%% 绘制结果图表
fprintf('\nGenerating plots...\n');

% 图1：案例1 - 恒定负载结果
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
% 功率平衡验证
P_balance = wind_power - P_load - battery_power;
plot(time_hours, P_balance, 'k-', 'LineWidth', 1.5);
xlabel('Time (hours)');
ylabel('Power (kW)');
title('Power Balance Error');
grid on;

saveas(gcf, 'case1_constant_load.png');
saveas(gcf, 'case1_constant_load.fig');

% 图2：案例2 - 带扰动负载结果
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
% 扰动附近的放大视图
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

% 图3：系统比较
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
% 能量流总结
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

%% 保存结果用于Python分析
fprintf('\nSaving results for analysis...\n');

% 保存为CSV供Python处理
results_table = table(time_hours', wind_power, P_load, battery_power, ...
    battery_soc, P_load_case2, battery_power2, battery_soc2, ...
    sc_power, sc_voltage, ...
    'VariableNames', {'time_hours', 'wind_power', 'load_case1', ...
    'battery_power_case1', 'battery_soc_case1', 'load_case2', ...
    'battery_power_case2', 'battery_soc_case2', 'sc_power', 'sc_voltage'});
writetable(results_table, 'simulation_results.csv');

% 保存参数
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
