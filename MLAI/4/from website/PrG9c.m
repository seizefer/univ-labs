function y = PrG9c(x)
% Matlab Code by A. Hedar (Nov. 23, 2005).
% Constraints
v1 = 2*x(1)^2;
v2 = x(2)^2;
y(1) = v1+3*v2^2+x(3)+4*x(4)^2+5*x(5)-127;
y(2) = 7*x(1)+3*x(2)+10*x(3)^2+x(4)-x(5)-282;
y(3) = 23*x(1)+v2+6*x(6)^2-8*x(7)-196;
y(4) = 2*v1+v2-3*x(1)*x(2)+2*x(3)^2+5*x(6)-11*x(7);
% Variable lower bounds
for j=1:7; y(j+4) = -x(j)-10; end
% Variable upper bounds
for j=1:7; y(j+11) = x(j)-10; end
% *************************************************************************
y=y';