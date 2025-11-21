%% Lab 1: Modulation/Demodulation - BPSK and QPSK
% 数字通信实验 - 相移键控调制技术
% 本实验实现BPSK和QPSK的调制、解调及误码率分析

clear; close all; clc;

%% ==================== 第一部分: BPSK ====================

%% 1.1 信源 - 生成随机比特
num_bits = 10000;                    % 每帧比特数
bits = rand(1, num_bits) > 0.5;      % 生成信息比特

%% 1.2 调制器 - BPSK调制
bpsk_sig = -2*(bits-0.5);            % BPSK调制数据

%% 1.3 热噪声 - 添加高斯噪声 (SNR = 0 dB)
SNR_dB = 0;                          % 信噪比设为0 dB
N0 = 1/10^(SNR_dB/10);               % 噪声功率（信号功率为1）

a = length(bpsk_sig);
Noise = sqrt(N0/2)*(randn(1,a)+1i*randn(1,a));  % AWGN噪声
Rx_bpsk_sig = bpsk_sig + Noise;                  % 接收信号

%% Task 1.1: 绘制接收信号的前10个比特
figure('Name', 'Task 1.1: First 10 Received BPSK Symbols');
stem(real(Rx_bpsk_sig(1:10)), 'filled');
xlabel('Symbol Index');
ylabel('Amplitude');
title('Task 1.1: First 10 Received BPSK Symbols (SNR = 0 dB)');
grid on;
saveas(gcf, 'Task1_1_BPSK_First10.png');

%% 1.4 解调器 - BPSK解调
Demod_bpsk_bits = real(Rx_bpsk_sig) < 0;  % BPSK解调信号

%% 1.5 误码率计算 (SNR = 0 dB)
Error_bits_bpsk = bits - Demod_bpsk_bits;          % 找出错误比特
BER_bpsk_0dB = sum(abs(Error_bits_bpsk))/num_bits; % 误码率
num_errors_0dB = sum(abs(Error_bits_bpsk));        % 错误比特数

fprintf('Task 1.2: SNR = 0 dB时的错误比特数: %d\n', num_errors_0dB);
fprintf('Task 1.2: SNR = 0 dB时的BER: %.4f\n', BER_bpsk_0dB);

%% Task 1.3: BER vs SNR曲线 (BPSK)
SNR = 0:2:10;                        % SNR范围
BER_bpsk = zeros(1, length(SNR));    % 初始化BER数组

for idx = 1:length(SNR)
    SNR_dB = SNR(idx);
    N0 = 1/10^(SNR_dB/10);

    % 生成新的比特和调制
    bits_temp = rand(1, num_bits) > 0.5;
    bpsk_sig_temp = -2*(bits_temp-0.5);

    % 添加噪声
    Noise = sqrt(N0/2)*(randn(1,num_bits)+1i*randn(1,num_bits));
    Rx_bpsk_sig_temp = bpsk_sig_temp + Noise;

    % 解调
    Demod_bpsk_bits_temp = real(Rx_bpsk_sig_temp) < 0;

    % 计算BER
    Error_bits = bits_temp - Demod_bpsk_bits_temp;
    BER_bpsk(idx) = sum(abs(Error_bits))/num_bits;
end

figure('Name', 'Task 1.3: BPSK BER vs SNR');
semilogy(SNR, BER_bpsk, '-o', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Task 1.3: BPSK BER vs SNR');
grid on;
saveas(gcf, 'Task1_3_BPSK_BER.png');

%% Task 1.4: 使用MATLAB内置函数进行BPSK调制/解调
fprintf('\n=== Task 1.4: MATLAB Built-in BPSK Functions ===\n');

% 使用pskmod和pskdemod函数
bits_test = rand(1, num_bits) > 0.5;
bpsk_mod_builtin = pskmod(double(bits_test), 2);  % BPSK调制

% 添加噪声
SNR_dB = 5;
N0 = 1/10^(SNR_dB/10);
Noise = sqrt(N0/2)*(randn(1,num_bits)+1i*randn(1,num_bits));
Rx_builtin = bpsk_mod_builtin + Noise;

% 解调
Demod_builtin = pskdemod(Rx_builtin, 2);          % BPSK解调

% 计算BER
BER_builtin = sum(abs(bits_test - Demod_builtin))/num_bits;
fprintf('使用内置函数的BER (SNR=5dB): %.4f\n', BER_builtin);

%% ==================== 第二部分: QPSK ====================

%% 2.1 信源 - 生成随机比特
bits = rand(1, num_bits) > 0.5;

%% 2.2 调制器 - QPSK调制
% 将比特分成两个流
Bits1 = bits(1:2:end);
Bits2 = bits(2:2:end);

% QPSK pi/4弧度星座图
qpsk_sig = ((Bits1==0).*(Bits2==0)*(exp(1i*pi/4))+(Bits1==0).*(Bits2==1)...
            *(exp(3*1i*pi/4))+(Bits1==1).*(Bits2==1)*(exp(5*1i*pi/4))...
            +(Bits1==1).*(Bits2==0)*(exp(7*1i*pi/4)));

%% Task 2.1: 绘制QPSK星座图
figure('Name', 'Task 2.1: QPSK Constellation');
plot(real(qpsk_sig), imag(qpsk_sig), 'o', 'MarkerSize', 8);
xlabel('In-phase');
ylabel('Quadrature');
title('Task 2.1: QPSK Modulated Signal Constellation');
axis equal;
grid on;
saveas(gcf, 'Task2_1_QPSK_Constellation.png');

%% Task 2.2: 不同SNR下的接收信号星座图
figure('Name', 'Task 2.2: QPSK Received Constellation at Different SNR');

SNR_values = [0, 10, 20];
for k = 1:3
    SNR_dB = SNR_values(k);
    N0 = 1/10^(SNR_dB/10);

    a = length(qpsk_sig);
    Noise = sqrt(N0/2)*(randn(1,a)+1i*randn(1,a));
    Rx_qpsk_sig = qpsk_sig + Noise;

    subplot(1,3,k);
    plot(real(Rx_qpsk_sig(1:100)), imag(Rx_qpsk_sig(1:100)), '*');
    xlabel('In-phase');
    ylabel('Quadrature');
    title(sprintf('SNR = %d dB', SNR_dB));
    axis([-3 3 -3 3]);
    grid on;
end
saveas(gcf, 'Task2_2_QPSK_SNR_Comparison.png');

%% 2.4 解调器 - QPSK解调 (SNR = 0 dB)
SNR_dB = 0;
N0 = 1/10^(SNR_dB/10);
a = length(qpsk_sig);
Noise = sqrt(N0/2)*(randn(1,a)+1i*randn(1,a));
Rx_qpsk_sig = qpsk_sig + Noise;

Bits4 = (real(Rx_qpsk_sig)<0);
Bits3 = (imag(Rx_qpsk_sig)<0);

Demod_qpsk_bits = zeros(1, 2*length(Rx_qpsk_sig));
Demod_qpsk_bits(1:2:end) = Bits3;
Demod_qpsk_bits(2:2:end) = Bits4;

%% 2.5 误码率计算 (QPSK)
Error_bits_qpsk = bits - Demod_qpsk_bits;
BER_qpsk_0dB = sum(abs(Error_bits_qpsk))/num_bits;
fprintf('\nQPSK在SNR = 0 dB时的BER: %.4f\n', BER_qpsk_0dB);

%% Task 2.3: BER vs SNR曲线 (QPSK)
SNR = 0:2:10;
BER_qpsk = zeros(1, length(SNR));

for idx = 1:length(SNR)
    SNR_dB = SNR(idx);
    N0 = 1/10^(SNR_dB/10);

    % 生成新的比特
    bits_temp = rand(1, num_bits) > 0.5;

    % QPSK调制
    Bits1 = bits_temp(1:2:end);
    Bits2 = bits_temp(2:2:end);
    qpsk_sig_temp = ((Bits1==0).*(Bits2==0)*(exp(1i*pi/4))+(Bits1==0).*(Bits2==1)...
                *(exp(3*1i*pi/4))+(Bits1==1).*(Bits2==1)*(exp(5*1i*pi/4))...
                +(Bits1==1).*(Bits2==0)*(exp(7*1i*pi/4)));

    % 添加噪声
    a = length(qpsk_sig_temp);
    Noise = sqrt(N0/2)*(randn(1,a)+1i*randn(1,a));
    Rx_qpsk_sig_temp = qpsk_sig_temp + Noise;

    % 解调
    Bits4 = (real(Rx_qpsk_sig_temp)<0);
    Bits3 = (imag(Rx_qpsk_sig_temp)<0);
    Demod_qpsk_bits_temp = zeros(1, 2*length(Rx_qpsk_sig_temp));
    Demod_qpsk_bits_temp(1:2:end) = Bits3;
    Demod_qpsk_bits_temp(2:2:end) = Bits4;

    % 计算BER
    Error_bits = bits_temp - Demod_qpsk_bits_temp;
    BER_qpsk(idx) = sum(abs(Error_bits))/num_bits;
end

figure('Name', 'Task 2.3: QPSK BER vs SNR');
semilogy(SNR, BER_qpsk, '--s', 'LineWidth', 2);
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Task 2.3: QPSK BER vs SNR');
grid on;
saveas(gcf, 'Task2_3_QPSK_BER.png');

%% Task 2.4: BPSK与QPSK的BER比较
figure('Name', 'Task 2.4: BPSK vs QPSK BER Comparison');
semilogy(SNR, BER_bpsk, '-o', 'LineWidth', 2, 'DisplayName', 'BPSK');
hold on;
semilogy(SNR, BER_qpsk, '--s', 'LineWidth', 2, 'DisplayName', 'QPSK');
xlabel('SNR (dB)');
ylabel('Bit Error Rate (BER)');
title('Task 2.4: BER Comparison - BPSK vs QPSK');
legend('Location', 'southwest');
grid on;
saveas(gcf, 'Task2_4_BER_Comparison.png');

fprintf('\n实验完成！所有图表已保存。\n');
