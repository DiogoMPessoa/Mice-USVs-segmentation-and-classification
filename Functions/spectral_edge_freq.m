function freq_spectral_edge=spectral_edge_freq(y,Fs,threshold)

[freq,periodogram]=Power_Spectral_Density(y,Fs,'abs');
Q = trapz(periodogram);
Q1 = cumtrapz(periodogram);

idx=find(Q1>threshold*Q);

freq_spectral_edge=freq(idx(1));