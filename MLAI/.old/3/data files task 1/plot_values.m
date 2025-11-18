
load('T_junction_best.mat')
freq_S11=value{1,1};
S11_val=value{1,2};
freq_S21=value{1,3};
S21_val=value{1,4};
freq_S31=value{1,5};
S31_val=value{1,6};

S11 = [freq_S11,S11_val];
S21 = [freq_S21,S21_val];
S31 = [freq_S31,S31_val];

figure(10)
plot(freq_S11,S11_val,'Color',[1 0 0],'LineWidth',1.5);
hold on;
plot(freq_S21,S21_val,'Color',[ 0 0.5 0],'LineWidth',1.5);
hold on;
plot(freq_S31,S31_val,'Color',[ 0 0 1],'LineWidth',1.5);
hold on;
grid on;
legend('S11','S21','S31');
axis([12 13.75 -100 0]);
% legend('S11','S21','S31','RZs');

xlabel('frequency (GHz)')
ylabel('S parameter (dB)')


function perf = evaluate (f, S11_val, S21_val, S31_val) 