function [P_actual, new_soc, new_energy] = battery_model(P_required, current_soc, current_energy, params, dt)
% BATTERY_MODEL Simulates battery charge/discharge operation
%
% Inputs:
%   P_required    - Required power (kW), positive = discharge, negative = charge
%   current_soc   - Current state of charge (0-1)
%   current_energy - Current stored energy (kWh)
%   params        - Battery parameters structure
%   dt            - Time step (seconds)
%
% Outputs:
%   P_actual      - Actual power delivered/absorbed (kW)
%   new_soc       - Updated state of charge
%   new_energy    - Updated stored energy (kWh)
%
% Battery equivalent circuit model:
%   - Internal resistance losses
%   - SOC-based voltage variation
%   - Efficiency losses during charge/discharge

% Extract parameters
capacity = params.capacity;          % kWh
max_power = params.max_power;        % kW
efficiency = params.efficiency;      % Efficiency
soc_min = params.soc_min;           % Minimum SOC
soc_max = params.soc_max;           % Maximum SOC

% Apply power limits
P_limited = max(-max_power, min(max_power, P_required));

% Calculate energy change
dt_hours = dt / 3600;  % Convert to hours

if P_limited > 0
    % Discharging
    % Check if enough energy available
    max_discharge_energy = (current_soc - soc_min) * capacity;
    max_discharge_power = max_discharge_energy / dt_hours;

    P_actual = min(P_limited, max_discharge_power);
    energy_change = -P_actual * dt_hours / efficiency;  % Efficiency loss during discharge

elseif P_limited < 0
    % Charging
    % Check if enough capacity available
    max_charge_energy = (soc_max - current_soc) * capacity;
    max_charge_power = max_charge_energy / dt_hours;

    P_actual = max(P_limited, -max_charge_power);
    energy_change = -P_actual * dt_hours * efficiency;  % Efficiency loss during charge

else
    % No power exchange
    P_actual = 0;
    energy_change = 0;
end

% Update state
new_energy = current_energy + energy_change;
new_soc = new_energy / capacity;

% Ensure SOC bounds
new_soc = max(soc_min, min(soc_max, new_soc));
new_energy = new_soc * capacity;

end
