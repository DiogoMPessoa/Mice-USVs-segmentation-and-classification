function vector=powerSpectrumFeatures(y,Fs)

[freq,periodogram]=Power_Spectral_Density(y,Fs,'log');

[max_power,idx_freq_max_power] = max(periodogram);
[min_power,idx_freq_min_power] = min(periodogram);
mean_power=mean(periodogram);
median_power=median(periodogram);
std_power=std(periodogram);
mean_freq=meanfreq(y,Fs);


vector=[max_power,freq(idx_freq_max_power),min_power,freq(idx_freq_min_power),mean_power,median_power,std_power,mean_freq];