function [P_actual, new_voltage, new_energy] = supercapacitor_model(P_required, current_voltage, params, dt)
% SUPERCAPACITOR_MODEL Simulates super-capacitor charge/discharge operation
%
% Inputs:
%   P_required     - Required power (kW), positive = discharge, negative = charge
%   current_voltage - Current capacitor voltage (V)
%   params         - Super-capacitor parameters structure
%   dt             - Time step (seconds)
%
% Outputs:
%   P_actual       - Actual power delivered/absorbed (kW)
%   new_voltage    - Updated voltage (V)
%   new_energy     - Updated stored energy (kWh)
%
% Super-capacitor model based on:
%   E = 0.5 * C * V^2
%   P = V * I - I^2 * ESR
%
% Key characteristics:
%   - Very fast response time (milliseconds)
%   - High power density
%   - Lower energy density than batteries
%   - High cycle life

% Extract parameters
C = params.capacitance;              % Farads
max_power = params.max_power;        % kW
V_max = params.voltage_max;          % Maximum voltage (V)
V_min = params.voltage_min;          % Minimum voltage (V)
ESR = params.esr;                    % Equivalent series resistance (Ohms)
efficiency = params.efficiency;      % Round-trip efficiency

% Apply power limits
P_limited = max(-max_power, min(max_power, P_required));

% Current energy stored (kWh)
current_energy = 0.5 * C * current_voltage^2 / 1e6;  % Convert J to kWh

% Calculate power considering ESR losses
if P_limited > 0
    % Discharging
    % P = V*I - I^2*ESR
    % Solve quadratic: ESR*I^2 - V*I + P = 0

    a = ESR;
    b = -current_voltage;
    c = P_limited * 1000;  % Convert to W

    discriminant = b^2 - 4*a*c;

    if discriminant >= 0
        I = (-b - sqrt(discriminant)) / (2*a);  % Take smaller root for discharge

        % Check voltage limits
        dV = I * dt / C;
        new_voltage_temp = current_voltage - dV;

        if new_voltage_temp < V_min
            % Limit by minimum voltage
            dV_max = current_voltage - V_min;
            I = dV_max * C / dt;
            P_actual = (current_voltage * I - I^2 * ESR) / 1000;  % kW
            new_voltage = V_min;
        else
            P_actual = P_limited * efficiency;
            new_voltage = new_voltage_temp;
        end
    else
        % Cannot deliver required power
        P_actual = 0;
        new_voltage = current_voltage;
    end

elseif P_limited < 0
    % Charging
    P_charge = abs(P_limited);

    % P_charge = V*I + I^2*ESR (power into capacitor)
    a = ESR;
    b = current_voltage;
    c = -P_charge * 1000;  % Convert to W

    discriminant = b^2 - 4*a*c;

    if discriminant >= 0
        I = (-b + sqrt(discriminant)) / (2*a);  % Take positive root for charge

        % Check voltage limits
        dV = I * dt / C;
        new_voltage_temp = current_voltage + dV;

        if new_voltage_temp > V_max
            % Limit by maximum voltage
            dV_max = V_max - current_voltage;
            I = dV_max * C / dt;
            P_actual = -(current_voltage * I + I^2 * ESR) / 1000;  % kW (negative for charging)
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
    % No power exchange
    P_actual = 0;
    new_voltage = current_voltage;
end

% Calculate new energy
new_energy = 0.5 * C * new_voltage^2 / 1e6;  % kWh

end
