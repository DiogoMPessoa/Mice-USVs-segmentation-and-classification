function [tonality_vector,mean_tonailty,max_tonality,min_tonality,time_above_threshold]=tonality(y,Fs,threshold,type_fft,disp)

if ~exist('type_fft','var')
    type_fft = 'spec';
end

if ~exist('disp','var')
    disp = 'off';
end

if ~exist('threshold','var')
    threshold = 100;
end

vec_tempos=[1:length(y)]/Fs;

if(strcmp(type_fft,'spec'))
    [~,~,T,~]=spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    tonality_vector=zeros(1,length(T));
    for i=1:length(T)
        
        if(i==1)
            x=find(vec_tempos<T(1));
            
            ini=1;
            fim=x(end);
        elseif(i==length(T))
            x=find(vec_tempos>T(i));
            
            ini=x(1);
            fim=length(y);
        else
            x=find(vec_tempos<T(i) & vec_tempos>T(i-1));
            ini=x(1);
            fim=x(end);
        end
        
        Pxx=periodogram(y(ini:fim),rectwin(length(y(ini:fim))),length(y(ini:fim)),Fs,'psd');
        
        tonality_vector(i)=1-(geomean(Pxx)/mean(Pxx));
    end
elseif(strcmp(type_fft,'syncro'))
    [~,~,T] = fsst(y,Fs);
    tonality_vector=zeros(1,length(T));
    for i=1:length(T)-2
        ini=i+1;
        fim=i+2;
        
        Pxx=periodogram(y(ini:fim),rectwin(length(y(ini:fim))),length(y(ini:fim)),Fs,'psd');
        
        tonality_vector(i)=1-(geomean(Pxx)/mean(Pxx));
    end
end

mean_tonailty=mean(tonality_vector);
max_tonality=max(tonality_vector);
min_tonality=min(tonality_vector);

if(strcmp(disp,'on'))
    plot(tonality_vector)
end

if(threshold~=100)
    th=find(tonality_vector>threshold);
    time_above_threshold=(1*(length(y)/Fs))/length(tonality_vector)*length(th);
else
    time_above_threshold=0;
end
