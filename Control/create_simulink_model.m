%% 创建混合储能系统Simulink模型
% 本脚本以编程方式创建风力发电机+电池+超级电容器系统的Simulink模型
%
% 课程: UESTC4003 - 控制
% MATLAB设计练习

clear; clc;

% 模型名称
modelName = 'hybrid_energy_system';

% 检查模型是否存在并关闭
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% 删除现有模型文件
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% 创建新模型
new_system(modelName);
open_system(modelName);

%% 设置模型参数
set_param(modelName, 'Solver', 'ode45');
set_param(modelName, 'StopTime', '86400');  % 24小时转换为秒
set_param(modelName, 'MaxStep', '300');  % 最大步长5分钟

%% 添加风力发电输入模块
% 从工作空间读取风力数据的模块
add_block('simulink/Sources/From Workspace', [modelName '/Wind_Power']);
set_param([modelName '/Wind_Power'], 'Position', [50, 100, 100, 140]);
set_param([modelName '/Wind_Power'], 'VariableName', 'wind_data');

%% 添加负载曲线
% 基础负载常数模块
add_block('simulink/Sources/Constant', [modelName '/Base_Load']);
set_param([modelName '/Base_Load'], 'Position', [50, 200, 100, 240]);
set_param([modelName '/Base_Load'], 'Value', '450');

% 扰动阶跃模块
add_block('simulink/Sources/Step', [modelName '/Disturbance']);
set_param([modelName '/Disturbance'], 'Position', [50, 280, 100, 320]);
set_param([modelName '/Disturbance'], 'Time', '43200');  % 中午
set_param([modelName '/Disturbance'], 'After', '300');   % 750-450 = 300 kW 额外负载

% 添加负载求和模块
add_block('simulink/Math Operations/Add', [modelName '/Load_Sum']);
set_param([modelName '/Load_Sum'], 'Position', [180, 230, 220, 270]);

%% 添加功率平衡计算器
% 减法: 风力 - 负载 = 净功率
add_block('simulink/Math Operations/Sum', [modelName '/Power_Balance']);
set_param([modelName '/Power_Balance'], 'Position', [300, 150, 340, 190]);
set_param([modelName '/Power_Balance'], 'Inputs', '+-');

%% 添加电池子系统
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Battery']);
set_param([modelName '/Battery'], 'Position', [450, 100, 550, 180]);

% 添加超级电容器子系统
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/SuperCapacitor']);
set_param([modelName '/SuperCapacitor'], 'Position', [450, 220, 550, 300]);

%% 添加输出示波器
% 电池SOC示波器
add_block('simulink/Sinks/Scope', [modelName '/Battery_SOC_Scope']);
set_param([modelName '/Battery_SOC_Scope'], 'Position', [700, 100, 740, 140]);

% 超级电容器电压示波器
add_block('simulink/Sinks/Scope', [modelName '/SC_Voltage_Scope']);
set_param([modelName '/SC_Voltage_Scope'], 'Position', [700, 220, 740, 260]);

% 功率平衡示波器
add_block('simulink/Sinks/Scope', [modelName '/Power_Scope']);
set_param([modelName '/Power_Scope'], 'Position', [700, 160, 740, 200]);

%% 添加数据导出模块
add_block('simulink/Sinks/To Workspace', [modelName '/Battery_SOC_Out']);
set_param([modelName '/Battery_SOC_Out'], 'Position', [650, 50, 700, 80]);
set_param([modelName '/Battery_SOC_Out'], 'VariableName', 'battery_soc');

add_block('simulink/Sinks/To Workspace', [modelName '/SC_Power_Out']);
set_param([modelName '/SC_Power_Out'], 'Position', [650, 280, 700, 310]);
set_param([modelName '/SC_Power_Out'], 'VariableName', 'sc_power');

%% 连接模块
% 负载连接
add_line(modelName, 'Base_Load/1', 'Load_Sum/1');
add_line(modelName, 'Disturbance/1', 'Load_Sum/2');

% 功率平衡连接
add_line(modelName, 'Wind_Power/1', 'Power_Balance/1');
add_line(modelName, 'Load_Sum/1', 'Power_Balance/2');

% 电池连接
add_line(modelName, 'Power_Balance/1', 'Battery/1');
add_line(modelName, 'Battery/1', 'Battery_SOC_Scope/1');
add_line(modelName, 'Battery/1', 'Battery_SOC_Out/1');

% 超级电容器连接
add_line(modelName, 'Power_Balance/1', 'SuperCapacitor/1');
add_line(modelName, 'SuperCapacitor/1', 'SC_Voltage_Scope/1');
add_line(modelName, 'SuperCapacitor/1', 'SC_Power_Out/1');

%% 保存模型
save_system(modelName);
fprintf('Simulink model created: %s.slx\n', modelName);

%% 创建仿真数据
% 加载风力数据
data = readtable('gridwatch wind data.csv');
wind_power = data.wind;
n_samples = length(wind_power);
dt = 5 * 60;  % 5分钟
time = (0:n_samples-1)' * dt;

% 创建Simulink时间序列
wind_data = timeseries(wind_power, time);
wind_data.Name = 'Wind Power';

% 保存到工作空间
assignin('base', 'wind_data', wind_data);

fprintf('Wind data loaded to workspace.\n');
fprintf('\nTo run simulation:\n');
fprintf('  1. Open the model: open_system(''%s'')\n', modelName);
fprintf('  2. Run: sim(''%s'')\n', modelName);
fprintf('  3. View results in scopes or exported variables\n');

%% 配置电池和超级电容器子系统
% 注意：子系统需要填充实际模型
% 完整实现可以使用MATLAB Function模块
% 调用battery_model.m和supercapacitor_model.m

fprintf('\nNote: Battery and SuperCapacitor subsystems need to be\n');
fprintf('configured with MATLAB Function blocks calling the model functions.\n');
fprintf('See battery_model.m and supercapacitor_model.m for the implementations.\n');
