function [power,energy]=Power_Energy(y)
energy = sum(abs(y).^2);

N = length(y);
Average_power = (1/N) * sum(y.^2);

power=pow2db(Average_power);

