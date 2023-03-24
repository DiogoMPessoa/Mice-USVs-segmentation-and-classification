function [freq,periodogram]=Power_Spectral_Density(y,Fs,opt,disp)
warning('off','all')
if ~exist('disp','var')
    disp='off';
end

N = length(y);
xdft = fft(y);
xdft = xdft(1:N/2+1);
psdx = (1/(Fs*N)) * abs(xdft).^2;
psdx(2:end-1) = 2*psdx(2:end-1);
freq = 0:Fs/length(y):Fs/2;

if(strcmp(opt,'log'))
    periodogram=10*log10(psdx);%logaritmico
elseif(strcmp(opt,'abs'))
    periodogram=psdx;%absolute
end

if(~strcmp(disp,'off'))
    plot(freq,periodogram)
    grid on
    title('Periodogram Using FFT')
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (dB/Hz)')
end