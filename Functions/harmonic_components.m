function harmonic_component = harmonic_components(y,Fs,perc,tolerance)



[freq,periodogram]=Power_Spectral_Density(y,Fs,'abs');

%perc=0.075;

[Ymax,Idx] = max(periodogram);

% subplot(2,2,[1 3])
% plot(freq,periodogram)
% hold on
% plot([0,2.50]*10^5,[Ymax*perc,Ymax*perc],'r-')
% hold off
% subplot(2,2,[2 4])
% spectrogram(y,256,128,1024,500000,'yaxis','MinThreshold',-110);

indexes=periodogram>Ymax*perc;
indexes=freq(indexes);

%tolerance=10*10^3; %10 kKz

freq_principal=freq(Idx);

if(any(2*freq_principal-tolerance<indexes & 2*freq_principal+tolerance>indexes) ||...
   any(3*freq_principal-tolerance<indexes & 3*freq_principal+tolerance>indexes) ||...
   any(0.5*freq_principal-tolerance<indexes & 0.5*freq_principal+tolerance>indexes))

    harmonic_component=1;
else
    harmonic_component=0;
end


