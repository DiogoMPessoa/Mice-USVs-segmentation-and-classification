function jumps=n_freq_jumps(y,Fs)

max_changes=6;
tonality_thresh=0.65;
[tonality_vector,mean_tonailty,max_tonality,min_tonality,time_above_threshold]=tonality(y,Fs,tonality_thresh,'spec','off');

if(time_above_threshold*10^3>5)
   %[s,f,t,pxx] = spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    
    %pxx=pow2db(pxx);
    %pxx_after = (pxx-min(pxx(:)))./(max(pxx(:))-min(pxx(:))) ;
    
    [s,f,t,pxx] = spectrogram(y,256,128,1024,Fs,'yaxis');
    pxx=pow2db(pxx);
    %pxx = normalize(pxx); 
    %pxx_after = (pxx-min(pxx(:)))./(max(pxx(:))-min(pxx(:))) ;
    
    
    ipt=findchangepts(pxx,'MaxNumChanges',max_changes,'MinDistance',floor(0.1*size(pxx,2)));
    %findchangepts(pxx,'MaxNumChanges',max_changes,'MinDistance',floor(0.1*size(pxx,2)))
    
    %ipt=findchangepts(pow2db(pxx),'MaxNumChanges',max_changes,'MinDistance',floor(0.1*size(pxx,2)));
    %findchangepts(pow2db(pxx),'MaxNumChanges',max_changes,'MinDistance',floor(0.1*size(pxx,2)))
   
    max_power=max(pxx(:));
    min_power=min(pxx(:));
    power_threshold=max_power-0.2*abs(min_power-max_power);
    step=ceil(size(pxx,2)*0.15);
    step_tolerance=ceil(size(pxx,2)*0.05);
    jumps=0;
    
    %para os casos em que a vocalizacao esta ligeiramente mal segmentada e
    %na ha potencia nas extremidades
    init_power_check=max(pxx(:,[1:ipt(1)]));
    end_power_check=max(pxx(:,[ipt(end):end]));
    
    if(nnz(init_power_check>power_threshold)>0.75*length(init_power_check))%max_power*1.1
        init_cycle=1;
    else
        init_cycle=2;
    end

    if(nnz(end_power_check>power_threshold)>0.75*length(end_power_check))%max_power*1.1
        end_cycle=length(ipt);
    else
        end_cycle=length(ipt)-1;
    end
    
    data_analysis=[];
    for i=init_cycle:end_cycle%1:length(ipt)
        center=ipt(i);
            
        %         if(center-step<1)
        %             back_init=1;
        %             back_end=center-step_tolerance;
        %         else
        %             back_init=center-step;
        %             back_end=center-step_tolerance;
        %         end
        %
        %         if(center+step>length(t))
        %             forward_init=center+step_tolerance;
        %             forward_end=size(pxx,2);
        %         else
        %             forward_init=center+step_tolerance;
        %             forward_end=center+step;
        %         end
        
        min_seq_length=5;
        
        forward_check=false;
        back_check=false;
        forward_init=center;
        back_end=center;
        
        seq=0;
        while(~forward_check && forward_init<size(pxx,2))
            forward_init=forward_init+1;
            if(max(pxx(:,forward_init))>power_threshold)
                seq=seq+1;
                if(seq==min_seq_length)
                    forward_check=true;
                    forward_init=forward_init-min_seq_length+1;
                end
            else
                seq=0;
            end
        end
        seq=0;
        while(~back_check && back_end>1)
            back_end=back_end-1;
            if(max(pxx(:,back_end))>power_threshold)
                seq=seq+1;
                if(seq==min_seq_length)
                    back_check=true;
                    back_end=back_end+min_seq_length-1;
                end
            else
                seq=0;
            end
        end
        
        if(back_end-step<1)
            back_init=1;
        else
            back_init=center-step;
        end
        
        if(forward_init+step>length(t))
            forward_end=size(pxx,2);
        else
            forward_end=forward_init+step;
        end
                
        [max_back,f_back_idx]=max(pxx(:,[back_init:back_end]));
        [max_forward,f_forward_idx]=max(pxx(:,[forward_init:forward_end]));
        entropy=pentropy(y(back_init:forward_end),Fs,'Instantaneous',false);        
        
        freqs_back=f(f_back_idx);
        freqs_forward=f(f_forward_idx);
        
        [freqs_back,TF_back] = rmoutliers(freqs_back);
        [freqs_forward,TF_forward] = rmoutliers(freqs_forward);
        
        tonality_center=tonality_vector([back_init:back_end,forward_init:forward_end]);
                
        back_power_non_outliers=max_back(TF_back==0)<power_threshold;
        forward_power_non_outliers=max_forward(TF_forward==0)<power_threshold;
                       
        %if(any(max_back(TF_back==0)<power_threshold)~=1 & any(max_forward(TF_forward==0)<power_threshold)~=1)
        if(nnz(back_power_non_outliers)<0.75*length(back_power_non_outliers) && nnz(forward_power_non_outliers)<0.75*length(forward_power_non_outliers))
        %if(nnz(tonality_center>tonality_thresh)>0.5*length(tonality_center))
            %if(any(max_back(TF_back==0)<power_threshold)~=1 & any(max_forward(TF_forward==0)<power_threshold)~=1)
                if(abs(mean(freqs_back)-mean(freqs_forward))>15000 && abs(mean(freqs_back)-mean(freqs_forward))<65000)
                    %center
                    jumps=jumps+1;
                end
            %end
        end
    end
else
    jumps=0;
end





% [s,f,t,pxx] = spectrogram(y,256,128,1024,Fs,'yaxis');
% ipt=findchangepts(pow2db(pxx),'MaxNumChanges',6);
% 
% %findchangepts(pow2db(pxx),'MaxNumChanges',5)
% 
% pxx=pow2db(pxx);
% 
% % jumps=0;
% % for i=1:length(ipt)
% %     center=ipt(i);
% %     
% %     step=5;
% %     
% %     if(center-step<1)
% %         [max_back,f_back_idx]=max(pxx(:,[1:center]));
% %     else
% %         [max_back,f_back_idx]=max(pxx(:,[center-step:center]));
% %     end
% %     
% %     if(center+step>length(t))
% %         [max_forward,f_forward_idx]=max(pxx(:,[center:end]));
% %     else
% %         [max_forward,f_forward_idx]=max(pxx(:,[center:center+step]));
% %     end
% %     
% %     freqs_back=f(f_back_idx);
% %     freqs_forward=f(f_forward_idx);
% %     
% %     freqs_back = rmoutliers(freqs_back);
% %     freqs_forward = rmoutliers(freqs_forward);
% %     
% %     if(abs(mean(freqs_back)-mean(freqs_forward))>15000)
% %         jumps=jumps+1;
% %     end
% % end
