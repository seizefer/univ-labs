%% Create Simulink Model for Hybrid Energy Storage System
% This script programmatically creates a Simulink model for the
% wind turbine + battery + super-capacitor system
%
% Course: UESTC4003 - Control
% MATLAB Based Design Exercise

clear; clc;

% Model name
modelName = 'hybrid_energy_system';

% Check if model exists and close it
if bdIsLoaded(modelName)
    close_system(modelName, 0);
end

% Delete existing model file
if exist([modelName '.slx'], 'file')
    delete([modelName '.slx']);
end

% Create new model
new_system(modelName);
open_system(modelName);

%% Set model parameters
set_param(modelName, 'Solver', 'ode45');
set_param(modelName, 'StopTime', '86400');  % 24 hours in seconds
set_param(modelName, 'MaxStep', '300');  % 5 minute max step

%% Add blocks for Wind Power Input
% From Workspace block for wind data
add_block('simulink/Sources/From Workspace', [modelName '/Wind_Power']);
set_param([modelName '/Wind_Power'], 'Position', [50, 100, 100, 140]);
set_param([modelName '/Wind_Power'], 'VariableName', 'wind_data');

%% Add Load Profile
% Constant block for base load
add_block('simulink/Sources/Constant', [modelName '/Base_Load']);
set_param([modelName '/Base_Load'], 'Position', [50, 200, 100, 240]);
set_param([modelName '/Base_Load'], 'Value', '450');

% Step block for disturbance
add_block('simulink/Sources/Step', [modelName '/Disturbance']);
set_param([modelName '/Disturbance'], 'Position', [50, 280, 100, 320]);
set_param([modelName '/Disturbance'], 'Time', '43200');  % Mid-day
set_param([modelName '/Disturbance'], 'After', '300');   % 750-450 = 300 kW extra

% Add blocks for load sum
add_block('simulink/Math Operations/Add', [modelName '/Load_Sum']);
set_param([modelName '/Load_Sum'], 'Position', [180, 230, 220, 270]);

%% Add Power Balance Calculator
% Subtract: Wind - Load = Net Power
add_block('simulink/Math Operations/Sum', [modelName '/Power_Balance']);
set_param([modelName '/Power_Balance'], 'Position', [300, 150, 340, 190]);
set_param([modelName '/Power_Balance'], 'Inputs', '+-');

%% Add Battery Subsystem
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/Battery']);
set_param([modelName '/Battery'], 'Position', [450, 100, 550, 180]);

% Add Super-Capacitor Subsystem
add_block('simulink/Ports & Subsystems/Subsystem', [modelName '/SuperCapacitor']);
set_param([modelName '/SuperCapacitor'], 'Position', [450, 220, 550, 300]);

%% Add Output Scopes
% Battery SOC Scope
add_block('simulink/Sinks/Scope', [modelName '/Battery_SOC_Scope']);
set_param([modelName '/Battery_SOC_Scope'], 'Position', [700, 100, 740, 140]);

% Super-capacitor Voltage Scope
add_block('simulink/Sinks/Scope', [modelName '/SC_Voltage_Scope']);
set_param([modelName '/SC_Voltage_Scope'], 'Position', [700, 220, 740, 260]);

% Power Balance Scope
add_block('simulink/Sinks/Scope', [modelName '/Power_Scope']);
set_param([modelName '/Power_Scope'], 'Position', [700, 160, 740, 200]);

%% Add To Workspace blocks for data export
add_block('simulink/Sinks/To Workspace', [modelName '/Battery_SOC_Out']);
set_param([modelName '/Battery_SOC_Out'], 'Position', [650, 50, 700, 80]);
set_param([modelName '/Battery_SOC_Out'], 'VariableName', 'battery_soc');

add_block('simulink/Sinks/To Workspace', [modelName '/SC_Power_Out']);
set_param([modelName '/SC_Power_Out'], 'Position', [650, 280, 700, 310]);
set_param([modelName '/SC_Power_Out'], 'VariableName', 'sc_power');

%% Connect blocks
% Load connections
add_line(modelName, 'Base_Load/1', 'Load_Sum/1');
add_line(modelName, 'Disturbance/1', 'Load_Sum/2');

% Power balance connections
add_line(modelName, 'Wind_Power/1', 'Power_Balance/1');
add_line(modelName, 'Load_Sum/1', 'Power_Balance/2');

% Battery connections
add_line(modelName, 'Power_Balance/1', 'Battery/1');
add_line(modelName, 'Battery/1', 'Battery_SOC_Scope/1');
add_line(modelName, 'Battery/1', 'Battery_SOC_Out/1');

% Super-capacitor connections
add_line(modelName, 'Power_Balance/1', 'SuperCapacitor/1');
add_line(modelName, 'SuperCapacitor/1', 'SC_Voltage_Scope/1');
add_line(modelName, 'SuperCapacitor/1', 'SC_Power_Out/1');

%% Save model
save_system(modelName);
fprintf('Simulink model created: %s.slx\n', modelName);

%% Create data for simulation
% Load wind data
data = readtable('gridwatch wind data.csv');
wind_power = data.wind;
n_samples = length(wind_power);
dt = 5 * 60;  % 5 minutes
time = (0:n_samples-1)' * dt;

% Create timeseries for Simulink
wind_data = timeseries(wind_power, time);
wind_data.Name = 'Wind Power';

% Save to workspace
assignin('base', 'wind_data', wind_data);

fprintf('Wind data loaded to workspace.\n');
fprintf('\nTo run simulation:\n');
fprintf('  1. Open the model: open_system(''%s'')\n', modelName);
fprintf('  2. Run: sim(''%s'')\n', modelName);
fprintf('  3. View results in scopes or exported variables\n');

%% Configure Battery and Super-capacitor subsystems
% Note: The subsystems need to be populated with the actual models
% For a complete implementation, MATLAB Function blocks can be used
% to call battery_model.m and supercapacitor_model.m

fprintf('\nNote: Battery and SuperCapacitor subsystems need to be\n');
fprintf('configured with MATLAB Function blocks calling the model functions.\n');
fprintf('See battery_model.m and supercapacitor_model.m for the implementations.\n');
