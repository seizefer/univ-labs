%% Lab 2: Channel Equalization - Zero Forcing Equalizer
% 信道均衡实验 - 零迫均衡器
% 本实验研究符号间干扰(ISI)及零迫均衡器的性能

clear; close all; clc;

%% B. 创建输出脉冲响应
fprintf('=== Part B: Output Pulse Response ===\n\n');

% 基本参数设置
Vm = 1;          % 脉冲幅度
T = 1;           % 脉冲周期
dt = 0.01;       % 仿真采样时间

% 绘制不同tau值下的输出响应
tau_values = [0.2, 1, 10];
figure('Name', 'Part B: Output Pulse Response');

for idx = 1:length(tau_values)
    tau = tau_values(idx);

    % 计算输出响应
    t1 = dt:dt:T;
    t2 = T+dt:dt:T+5*tau;

    c = [Vm*(1 - exp(-t1'/tau)); ...
         Vm*(1 - exp(-T/tau))*exp(-(t2'-T)/tau)];
    t = dt:dt:T+5*tau;

    subplot(1, 3, idx);
    plot(t, c, 'LineWidth', 1.5);
    ylim([0 1.2]);
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('\\tau = %.1f', tau));
    grid on;
end
sgtitle('Part B: Output Pulse Response for Different \tau Values');
saveas(gcf, 'Lab2_PartB_OutputPulse.png');

fprintf('Part B 结论:\n');
fprintf('- tau=0.2: 响应快速上升和下降，接近理想矩形脉冲\n');
fprintf('- tau=1: 中等响应速度，有明显的上升和拖尾\n');
fprintf('- tau=10: 响应非常缓慢，严重失真，ISI严重\n\n');

%% C. 生成带有ISI的接收信号
fprintf('=== Part C: Generate Received Signal with ISI ===\n\n');

% 使用tau=1进行后续实验
tau = 1;

% 生成信道脉冲响应
t1 = dt:dt:T;
t2 = T+dt:dt:T+5*tau;
c = [Vm*(1 - exp(-t1'/tau)); ...
     Vm*(1 - exp(-T/tau))*exp(-(t2'-T)/tau)];

% 生成BPSK符号
N = 1000;                        % 符号数
v = rand(1, N) > 0.5;            % 生成随机比特
b = 2*v - 1;                     % BPSK调制: 0->-1, 1->+1

% 计算参数
nT = T/dt;                       % 每符号采样数
nc = length(c);                  % 信道响应长度
nx = N*nT;                       % 接收信号总长度

% 生成带ISI的接收信号
x = zeros(nx, 1);
for n = 1:N
    i1 = (n-1)*nT;
    y = [zeros(i1, 1); b(n)*c; zeros(N*nT-i1-nc, 1)];
    x = x + y(1:nx);
end

% 绘制眼图（无均衡）
figure('Name', 'Part C: Eye Diagram without Equalization (tau=1)');
hold on;
for n = 1:2:N-1
    plot(dt:dt:2, x((n-1)*nT+1:(n+1)*nT), 'b');
end
xlabel('Time (s)');
ylabel('Amplitude');
title('Eye Diagram without Equalization (\tau = 1)');
grid on;
saveas(gcf, 'Lab2_PartC_EyeDiagram_NoEQ_tau1.png');

% 计算误码数（无均衡）
xT = x(nT:nT:nx);
dz0 = find(xT < 0);
dz1 = find(xT >= 0);

db = b;
db(dz0) = -1*ones(size(dz0));
db(dz1) = +1*ones(size(dz1));

err = find(db ~= b);
fprintf('tau=1, No equalizer: %d bits out of %d in error\n', length(err), N);

%% 测试不同tau值
tau_test = [0.2, 10];
errors_no_eq = zeros(1, length(tau_test));

figure('Name', 'Part C: Eye Diagrams for Different tau');
for idx = 1:length(tau_test)
    tau = tau_test(idx);

    % 重新生成信道响应
    t1 = dt:dt:T;
    t2 = T+dt:dt:T+5*tau;
    c = [Vm*(1 - exp(-t1'/tau)); ...
         Vm*(1 - exp(-T/tau))*exp(-(t2'-T)/tau)];
    nc = length(c);

    % 生成带ISI的接收信号
    x = zeros(nx, 1);
    for n = 1:N
        i1 = (n-1)*nT;
        y = [zeros(i1, 1); b(n)*c; zeros(N*nT-i1-nc, 1)];
        x = x + y(1:nx);
    end

    % 绘制眼图
    subplot(1, 2, idx);
    hold on;
    for n = 1:2:N-1
        plot(dt:dt:2, x((n-1)*nT+1:(n+1)*nT), 'b');
    end
    xlabel('Time (s)');
    ylabel('Amplitude');
    title(sprintf('Eye Diagram (\\tau = %.1f)', tau));
    grid on;

    % 计算误码数
    xT = x(nT:nT:nx);
    dz0 = find(xT < 0);
    dz1 = find(xT >= 0);

    db = b;
    db(dz0) = -1*ones(size(dz0));
    db(dz1) = +1*ones(size(dz1));

    err = find(db ~= b);
    errors_no_eq(idx) = length(err);
    fprintf('tau=%.1f, No equalizer: %d bits out of %d in error\n', tau, length(err), N);
end
saveas(gcf, 'Lab2_PartC_EyeDiagram_DifferentTau.png');

fprintf('\nPart C 结论:\n');
fprintf('- tau=0.2: 眼图张开良好，误码少\n');
fprintf('- tau=1: 眼图部分闭合，有一定误码\n');
fprintf('- tau=10: 眼图完全闭合，误码严重\n\n');

%% D. 实现零迫均衡器
fprintf('=== Part D: Zero Forcing Equalizer ===\n\n');

% 恢复tau=1
tau = 1;

% 重新生成信道响应
t1 = dt:dt:T;
t2 = T+dt:dt:T+5*tau;
c = [Vm*(1 - exp(-t1'/tau)); ...
     Vm*(1 - exp(-T/tau))*exp(-(t2'-T)/tau)];
nc = length(c);

% 重新生成带ISI的接收信号
x = zeros(nx, 1);
for n = 1:N
    i1 = (n-1)*nT;
    y = [zeros(i1, 1); b(n)*c; zeros(N*nT-i1-nc, 1)];
    x = x + y(1:nx);
end

% 定义零迫均衡器长度
Ne = round(5*tau/T);

% 获取信道响应采样
cT = c(nT:nT:nc);
L = length(cT);

% 构建Toeplitz矩阵
C = toeplitz([cT(1:end)', zeros(1, 2*Ne+1-L)], [cT(1), zeros(1, 2*Ne)]);

% 构建目标向量
z = [zeros(Ne, 1); 1; zeros(Ne, 1)];

% 求解ZF均衡器权重
w = inv(C) * z;

% 处理接收信号
z0 = [1; zeros(nT-1, 1)];
hzf = kron(w, z0);

% 执行均衡
yall = conv(x, hzf);
y = yall((Ne*nT+1):(length(yall)-(Ne+1)*nT)+1);

% 绘制均衡后的眼图
figure('Name', 'Part D: Eye Diagram Comparison');

subplot(1, 2, 1);
hold on;
for n = 1:2:N-1
    plot(dt:dt:2, x((n-1)*nT+1:(n+1)*nT), 'b');
end
xlabel('Time (s)');
ylabel('Amplitude');
title('Without Equalization');
grid on;

subplot(1, 2, 2);
hold on;
for n = 1:2:N-2*Ne-1
    if (n+1)*nT <= length(y)
        plot(dt:dt:2, y((n-1)*nT+1:(n+1)*nT), 'r');
    end
end
xlabel('Time (s)');
ylabel('Amplitude');
title('With ZF Equalization');
grid on;

sgtitle('Part D: Eye Diagram Comparison (\tau = 1)');
saveas(gcf, 'Lab2_PartD_EyeDiagram_Comparison.png');

% 计算均衡后的误码数
yT = y(nT:nT:min(length(y), nx));
N_eq = length(yT);

dz0 = find(yT < 0);
dz1 = find(yT >= 0);

db_eq = b(1:N_eq);
db_eq(dz0) = -1*ones(size(dz0));
db_eq(dz1) = +1*ones(size(dz1));

err_eq = find(db_eq ~= b(1:N_eq));
fprintf('ZF equalizer: %d bits out of %d in error\n', length(err_eq), N_eq);

% 计算无均衡器的误码（用于比较）
xT_compare = x(nT:nT:N_eq*nT);
dz0 = find(xT_compare < 0);
dz1 = find(xT_compare >= 0);

db_no = b(1:N_eq);
db_no(dz0) = -1*ones(size(dz0));
db_no(dz1) = +1*ones(size(dz1));

err_no = find(db_no ~= b(1:N_eq));
fprintf('No equalizer: %d bits out of %d in error\n\n', length(err_no), N_eq);

fprintf('Part D 结论:\n');
fprintf('- 零迫均衡器显著改善眼图张开度\n');
fprintf('- 误码率大幅降低\n');
fprintf('- 均衡器有效消除了ISI\n\n');

fprintf('实验完成！所有图表已保存。\n');
