function feat=USV_characteristics(y,Fs,extraction,norm,disp)

if ~exist('disp','var')
    disp = 'off';
end

if ~exist('extraction','var') || isempty(extraction)
    extraction = 'max';
end

if ~exist('norm','var')
    norm = [];
end

%extraction='max','psd','max_tonality','syncro','wsst'
freqs_smooth = contour_extraction(y,Fs,extraction,norm);%funcao para obter o cotorno da vocalizacao

[peak_frequency,Idx_peak]=max(freqs_smooth);
[min_frequency,Idx_min]=min(freqs_smooth);
freq_init=freqs_smooth(1);
freq_end=freqs_smooth(end);
bandwith=abs(peak_frequency-min_frequency);
mean_frequency=mean(freqs_smooth);
ste=Short_Time_Energy(y);
power_dB=Signal_Energy(y);
f_max_init=peak_frequency-freqs_smooth(1);
f_max_end=peak_frequency-freqs_smooth(end);
f_min_init=min_frequency-freqs_smooth(1);
f_min_end=min_frequency-freqs_smooth(end);
f_end_init=(freqs_smooth(end)-freqs_smooth(1));
%duration=length(y)/Fs;
[~,n_changes,~]=n_dir_changes(freqs_smooth,8000);
harmonic_component=harmonic_components(y,Fs,0.4,7500);
%n_steps=number_f_steps(y,Fs);
n_jumps=n_freq_jumps(y,Fs);
freq_spectral_edge=spectral_edge_freq(y,Fs,0.7);
se = pentropy(y,Fs,'Instantaneous',false);
se_vector = pentropy(y,Fs);
max_entropy=max(se_vector);
min_entropy=min(se_vector);
mean_entropy=mean(se_vector);
median_entropy=median(se_vector);
std_entropy=std(se_vector);
y_mean=mean(y);
y_median=median(y);
y_std=std(y);
%y_end=y(end);
%y_init=y(1);
kurtosis_matlab=kurtosis(y);
skewness_matlab=skewness(y);
%[d_temp,d_spectral]=discontinuity(y);
vector_spectrum_features=powerSpectrumFeatures(y,Fs);

if(freq_end-freq_init>1000)
    trend=1;
elseif(freq_end-freq_init<-1000)
    trend=-1;
else
    trend=0;
end

[tonality_vector,mean_tonality,max_tonality,min_tonality,duration]=tonality(y,Fs,0.60,'spec','off');

if(strcmp(disp,'on'))
    %outliers = isoutlier(vetor_freqs);% metodo para calcular outliers ; param-'movmedian',10
    
    %t=1:1:size(vetor_freqs,2);
    
    figure
    subplot(2,1,1)
    spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    colormap(1-gray)
    subplot(2,1,2)
    %plot(t,vetor_freqs,t(outliers),vetor_freqs(outliers),'xg',t,freqs_smooth,'r')
    plot(freqs_smooth,'r')
    ax = gca;
    ax.YRuler.Exponent = 3;
    ylabel('Freqeuncy(Hz)')
    %legend('Data','Outliers','Smooth Data')
    pos = get (subplot(212), 'position');
    annotation('textbox',pos,...
                'String',{['peak\_freq=',num2str(peak_frequency/1000),'kHz',' ;  ','min\_freq=',num2str(min_frequency/1000),'kHz'],...
                ['f(0)=', num2str(freq_init/1000),'kHz','  ;  ','f(end)=',num2str(freq_end/1000),'kHz'],['\Delta f=',...
                num2str(bandwith/1000),'kHz','  ;  ','Duration=',num2str((length(y)/Fs)*1000),'ms']},...
        'FontName','Arial',...
        'FontSize',10,...
        'BackgroundColor',[0.9  0.9 0.9],...
        'FitBoxToText', true);
    
end
feat=[peak_frequency,min_frequency,freq_init,freq_end,bandwith,mean_frequency,ste,power_dB,...%8
      f_max_init,f_max_end,f_min_init,f_min_end,f_end_init,duration,n_changes,harmonic_component,n_jumps,...%17
      freq_spectral_edge,se,max_entropy,min_entropy,mean_entropy,median_entropy,...
      std_entropy,mean_tonality,max_tonality,min_tonality,std(tonality_vector),median(tonality_vector),y_mean,y_median,y_std,kurtosis_matlab,skewness_matlab,trend,vector_spectrum_features];%%
end