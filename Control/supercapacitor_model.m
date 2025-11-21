function [P_actual, new_voltage, new_energy] = supercapacitor_model(P_required, current_voltage, params, dt)
% SUPERCAPACITOR_MODEL 模拟超级电容器充放电运行
%
% 输入参数:
%   P_required     - 所需功率 (kW)，正值=放电，负值=充电
%   current_voltage - 当前电容器电压 (V)
%   params         - 超级电容器参数结构体
%   dt             - 时间步长 (秒)
%
% 输出参数:
%   P_actual       - 实际输出/吸收功率 (kW)
%   new_voltage    - 更新后的电压 (V)
%   new_energy     - 更新后的存储能量 (kWh)
%
% 超级电容器模型基于:
%   E = 0.5 * C * V^2
%   P = V * I - I^2 * ESR
%
% 关键特性:
%   - 极快的响应时间（毫秒级）
%   - 高功率密度
%   - 能量密度低于电池
%   - 高循环寿命

% 提取参数
C = params.capacitance;              % 电容量 F
max_power = params.max_power;        % 最大功率 kW
V_max = params.voltage_max;          % 最大电压 V
V_min = params.voltage_min;          % 最小电压 V
ESR = params.esr;                    % 等效串联电阻 Ohms
efficiency = params.efficiency;      % 往返效率

% 应用功率限制
P_limited = max(-max_power, min(max_power, P_required));

% 当前存储能量 (kWh)
current_energy = 0.5 * C * current_voltage^2 / 1e6;  % 从J转换为kWh

% 考虑ESR损耗计算功率
if P_limited > 0
    % 放电
    % P = V*I - I^2*ESR
    % 求解二次方程: ESR*I^2 - V*I + P = 0

    a = ESR;
    b = -current_voltage;
    c = P_limited * 1000;  % 转换为W

    discriminant = b^2 - 4*a*c;

    if discriminant >= 0
        I = (-b - sqrt(discriminant)) / (2*a);  % 取较小根用于放电

        % 检查电压限制
        dV = I * dt / C;
        new_voltage_temp = current_voltage - dV;

        if new_voltage_temp < V_min
            % 受最小电压限制
            dV_max = current_voltage - V_min;
            I = dV_max * C / dt;
            P_actual = (current_voltage * I - I^2 * ESR) / 1000;  % kW
            new_voltage = V_min;
        else
            P_actual = P_limited * efficiency;
            new_voltage = new_voltage_temp;
        end
    else
        % 无法提供所需功率
        P_actual = 0;
        new_voltage = current_voltage;
    end

elseif P_limited < 0
    % 充电
    P_charge = abs(P_limited);

    % P_charge = V*I + I^2*ESR (输入电容器的功率)
    a = ESR;
    b = current_voltage;
    c = -P_charge * 1000;  % 转换为W

    discriminant = b^2 - 4*a*c;

    if discriminant >= 0
        I = (-b + sqrt(discriminant)) / (2*a);  % 取正根用于充电

        % 检查电压限制
        dV = I * dt / C;
        new_voltage_temp = current_voltage + dV;

        if new_voltage_temp > V_max
            % 受最大电压限制
            dV_max = V_max - current_voltage;
            I = dV_max * C / dt;
            P_actual = -(current_voltage * I + I^2 * ESR) / 1000;  % kW（充电为负值）
            new_voltage = V_max;
        else
            P_actual = P_limited * efficiency;
            new_voltage = new_voltage_temp;
        end
    else
        P_actual = 0;
        new_voltage = current_voltage;
    end

else
    % 无功率交换
    P_actual = 0;
    new_voltage = current_voltage;
end

% 计算新的能量
new_energy = 0.5 * C * new_voltage^2 / 1e6;  % kWh

end
