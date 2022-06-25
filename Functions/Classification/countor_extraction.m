function cont_vec=countor_extraction(y,Fs,opt,display)

if ~exist('display','var')
    display = 'off';
end


if(strcmp(opt,'max'))%analisar a frequencia com maior potencia ao longo de todos os instantes temporais do espetrograma
    
    [s,f,t,~]=spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    [vetor_freqs,~,~] = tfridge(s,f);
    
    cont_vec = smoothdata(vetor_freqs,'rlowess',50);
    %cont_vec = smoothdata(vetor_freqs,'rlowess',0.155*length(vetor_freqs));
    
    %cont_vec = smooth(vetor_freqs,0.1,'rloess');
    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        hold on
        plot(t*1000,cont_vec./1000,'--r','LineWidth',3)
        hold off
    end
elseif (strcmp(opt,'psd'))
       
    int=4*128;
    cont_vec=[];
    for i=1:int:length(y)-int
        [Pxx,f]=periodogram(y(i:i+int),rectwin(length(y(i:i+int))),length(y(i:i+int)),Fs,'power');
        
        [~,idx]=max(Pxx);
        
        cont_vec=[cont_vec,f(idx)];
    end
    
    %cont_vec = smooth(cont_vec,0.1,'rloess');
    %cont_vec = smoothdata(cont_vec,'rlowess',0.15*length(cont_vec));
    cont_vec = smoothdata(cont_vec,'rlowess',50);
    
    if(strcmp(display,'on'))
        %         subplot 211
        %         spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %         subplot 212
        %         plot([1:length(cont_vec)]/10,cont_vec./1000,'r')
        spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        hold on
        plot([1:length(cont_vec)],cont_vec./1000,'--r','LineWidth',3)
        hold off
    end
elseif (strcmp(opt,'max_tonality'))    
    [s,f,t,~]=spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    
    [vetor_freqs,~,~] = tfridge(s,f);
    
    vetor_freqs=vetor_freqs';
    
    %Para extrair o contorno apenas onde a tonalidada é superior ao threshold
    threshold=0.6;
    [tonality_vector,~,~,~,~]=tonality(y,Fs,threshold,'spec','off');
    above=false;
    init=[];
    fim=[];
    for k=1:length(tonality_vector)
        if (tonality_vector(k)>threshold & ~above)
            init=[init,k];
            above=true;
        elseif(tonality_vector(k)<threshold & above)
            fim=[fim,k-1];
            above=false;
        end
    end
    if(length(init)~=length(fim))
        fim=[fim, length(tonality_vector)];
    end
    
    %criacao dos vetores incompletos para fazer a interpolacao
    x_non_outlier=[];
    y_non_outlier=[];
    for m=1:length(init)
        x_non_outlier=[x_non_outlier,init(m):fim(m)];
        y_non_outlier=[y_non_outlier,vetor_freqs(init(m):fim(m))];
    end
    newPcntVals = init(1):1:fim(end);%length(max_freq);
    newYvals = interp1(x_non_outlier, y_non_outlier, newPcntVals);
    cont_vec = smooth(newYvals,'rlowess',50);
    %cont_vec = smoothdata(newYvals,'rlowess',0.15*length(newYvals));

    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        hold on
        plot(1:length(cont_vec),cont_vec./1000,'--r','LineWidth',3)
        hold off        
    end
elseif (strcmp(opt,'syncro'))
  
    %nfb = 1;
    [sst,f,t] = fsst(y,Fs);
    
    [fr,~] = tfridge(sst,f,40,'NumRidges',1);%'NumFrequencyBins',nfb);
    
    %cont_vec = smooth(fr,.1,'rlowess');
    cont_vec=movmean(fr,0.1*length(fr));
    %cont_vec=smoothdata(fr,'rlowess',0.15*length(fr));
    %cont_vec=fr;
    
    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %fsst(y,Fs,'yaxis');
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        fsst(y,Fs,'yaxis');
        hold on
        plot(t*1000,cont_vec./1000,'--r','LineWidth',2)
        hold off
    end
elseif(strcmp(opt,'wsst'))%Time-frequency ridges from wavelet synchrosqueezing
    
    [sst,F] = wsst(y,Fs);
    [fridge,~] = wsstridge(sst,100,F,'NumRidges',1);
    
    cont_vec=fridge;
    cont_vec=movmean(cont_vec,0.1*length(cont_vec));
    %cont_vec = smoothdata(cont_vec,'rlowess',0.15*length(cont_vec));

    
    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %wsst(y,Fs,'yaxis');
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        wsst(y,Fs);
        hold on
        plot(([1:length(cont_vec)]/Fs)*1000,cont_vec./1000,'--r','LineWidth',2)
        hold off
    end
elseif(strcmp(opt,'max_interpolation'))%analisar a frequencia com maior potencia ao longo de todos os instantes temporais do espetrograma
       
    [s,f,t,~]=spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    [vetor_freqs,~,~] = tfridge(s,f);
    
    %cont_vec = smoothdata(vetor_freqs,'rlowess',50);
    %cont_vec = smooth(vetor_freqs,0.1,'rloess');
    [vetor_freqs_new,TF] = rmoutliers(vetor_freqs,'mean');
    
    %criacao dos vetores incompletos para fazer a interpolacao
    x_non_outlier=[];
    y_non_outlier=[];
    for m=1:length(TF)
        if(TF(m)==0)
            x_non_outlier=[x_non_outlier,m];
            y_non_outlier=[y_non_outlier,vetor_freqs(m)];
        end
    end
    newPcntVals = 1:length(TF);
    newYvals = interp1(x_non_outlier, y_non_outlier, newPcntVals);
    
    %cont_vec = newYvals;
    cont_vec = smoothdata(newYvals,'rlowess',50);
    %cont_vec = smoothdata(newYvals,'rlowess',0.15*length(newYvals));
    
    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        hold on
        plot(t*1000,cont_vec./1000,'--r','LineWidth',3)
        hold off
    end
elseif(strcmp(opt,'best_path'))%
        
    [s,f,t,p]=spectrogram(y,256,128,1024,Fs,'yaxis');
    p=pow2db(p);
    
    max_power=max(p(:));
    
    %[x_max,y_max]=find(p==max_power);
    [y_max,x_max]=find(p==max_power);
    
    n=100;
    
    vetor_forward=[f(y_max)];
    vetor_back=[f(y_max)];
    for i=x_max+1:1:size(s,2)
        p_instante=sortrows([p(:,i),[1:size(p,1)]'],1,'descend');
        n_max_idx=p_instante(1:n,2);
        
        idx_power_above_threshold=find(p(:,i)>1.7*max_power);
        n_max_idx=intersect(n_max_idx,idx_power_above_threshold);
        
        diffs=abs(f(n_max_idx)-vetor_forward(end));
        [~,idx_min_diff]=min(diffs);
        
        vetor_forward=[vetor_forward,f(n_max_idx(idx_min_diff))];
    end
    
    for j=x_max-1:-1:1
        p_instante=sortrows([p(:,j),[1:size(p,1)]'],1,'descend');
        n_max_idx=p_instante(1:n,2);
        
        idx_power_above_threshold=find(p(:,j)>1.7*max_power);
        n_max_idx=intersect(n_max_idx,idx_power_above_threshold);
        
        diffs=abs(f(n_max_idx)-vetor_back(1));
        [~,idx_min_diff]=min(diffs);
        
        vetor_back=[f(n_max_idx(idx_min_diff)),vetor_back];
    end
    
    cont_vec=[vetor_back(1:end-1),vetor_forward];
    %cont_vec = smoothdata(cont_vec,'rlowess',0.15*length(cont_vec));
    cont_vec = smoothdata(cont_vec,'rlowess',50);
    
    if(strcmp(display,'on'))
        %subplot 211
        %spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        %subplot 212
        %plot([1:length(cont_vec)],cont_vec./1000,'r')
        spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
        hold on
        plot(t*1000,cont_vec./1000,'--r','LineWidth',3)
        hold off
    end
    
end

