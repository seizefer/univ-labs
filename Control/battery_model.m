function [P_actual, new_soc, new_energy] = battery_model(P_required, current_soc, current_energy, params, dt)
% BATTERY_MODEL 模拟电池充放电运行
%
% 输入参数:
%   P_required    - 所需功率 (kW)，正值=放电，负值=充电
%   current_soc   - 当前荷电状态 (0-1)
%   current_energy - 当前存储能量 (kWh)
%   params        - 电池参数结构体
%   dt            - 时间步长 (秒)
%
% 输出参数:
%   P_actual      - 实际输出/吸收功率 (kW)
%   new_soc       - 更新后的荷电状态
%   new_energy    - 更新后的存储能量 (kWh)
%
% 电池等效电路模型:
%   - 内阻损耗
%   - 基于SOC的电压变化
%   - 充放电过程中的效率损耗

% 提取参数
capacity = params.capacity;          % 容量 kWh
max_power = params.max_power;        % 最大功率 kW
efficiency = params.efficiency;      % 效率
soc_min = params.soc_min;           % 最小 SOC
soc_max = params.soc_max;           % 最大 SOC

% 应用功率限制
P_limited = max(-max_power, min(max_power, P_required));

% 计算能量变化
dt_hours = dt / 3600;  % 转换为小时

if P_limited > 0
    % 放电
    % 检查是否有足够的能量可用
    max_discharge_energy = (current_soc - soc_min) * capacity;
    max_discharge_power = max_discharge_energy / dt_hours;

    P_actual = min(P_limited, max_discharge_power);
    energy_change = -P_actual * dt_hours / efficiency;  % 放电时的效率损耗

elseif P_limited < 0
    % 充电
    % 检查是否有足够的容量可用
    max_charge_energy = (soc_max - current_soc) * capacity;
    max_charge_power = max_charge_energy / dt_hours;

    P_actual = max(P_limited, -max_charge_power);
    energy_change = -P_actual * dt_hours * efficiency;  % 充电时的效率损耗

else
    % 无功率交换
    P_actual = 0;
    energy_change = 0;
end

% 更新状态
new_energy = current_energy + energy_change;
new_soc = new_energy / capacity;

% 确保SOC在边界内
new_soc = max(soc_min, min(soc_max, new_soc));
new_energy = new_soc * capacity;

end
