clear all,clc,close
%%%%%%%%%%%%%%%%%%%%%%%%%MANUAL SEGMENTATION%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
addpath('..\Features Extraction')

store_caractheristics=true;
[name,path]=uigetfile({'*.WAV'},'Abrir o arquivo de audio','D:\Dados Tese');
info=audioinfo([path,name]);
signal_len=info.TotalSamples;
Fs=info.SampleRate;

% Arrays para guardar instantes iniciais e finais das vocalizações
times=[];

interval=1; % intervalo em que são lidos os segmentos do sinal (Nota: quanto maior o intervalo para calcular a entropia espetral menos ruído se deteta mas a precisao da detecao das vocalizacoes tambem piora)
start=0; % instante a partir do qual é lido o sinal

disp(' ')
disp(['File:',name])
disp('Starting...')
for j=1:interval*Fs:signal_len%2*Fs
    shift=start*Fs;
    ini=j+shift;
    fim=ini+interval*Fs;
    
    if(fim>signal_len)
        fim=signal_len;
    end
    
    [y,Fs] = audioread([path name],[ini fim]);
    
    spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    colormap(1-gray)
    title([num2str(ini/Fs),'s - ',num2str(fim/Fs),'s'])
    
    [x_manual,~,buttons] = ginput;
    
    hold on
    for i=1:length(x_manual)
        if(buttons(i)~=2 && buttons(i)~=3)
            h=plot([x_manual(i),x_manual(i)],[0 250], '-', 'LineWidth', 4);
            times=[times,((ini/Fs)+(x_manual(i)/1000))];
        end
    end
    hold off
    pause;
    delete(findobj(gca, 'type', 'line'));
end
close all

if(~isempty(times))
    init_voc = times(1:2:end);  % odd matrix
    fim_voc = times(2:2:end);  % even matrix
    
%     % Guardar caracteristicas de cada vocalização
%     peak_frequency_list=zeros(size(init_voc,2),1);
%     min_frequency_list=zeros(size(init_voc,2),1);
%     freq_init_list=zeros(size(init_voc,2),1);
%     freq_end_list=zeros(size(init_voc,2),1);
%     bandwith_list=zeros(size(init_voc,2),1);
%     mean_frequency_list=zeros(size(init_voc,2),1);
%     ste_list=zeros(size(init_voc,2),1);
%     Energy_dB_list=zeros(size(init_voc,2),1);
%     
%     
%     if(store_caractheristics)
%         for m=1:size(init_voc,2)
%             [y_voc,~] = audioread([path name],[ceil(init_voc(m)*Fs) ceil(fim_voc(m)*Fs)]);
%             
%             feat=Voc_characteristics(y_voc,Fs);
%             
%             peak_frequency_list(m,1)=feat(1);
%             min_frequency_list(m,1)=feat(2);
%             freq_init_list(m,1)=feat(3);
%             freq_end_list(m,1)=feat(4);
%             bandwith_list(m,1)=feat(5);
%             mean_frequency_list(m,1)=feat(6);
%             ste_list(m,1)=feat(7);
%             Energy_dB_list(m,1)=feat(8);
%             
%         end
%     end
else
    init_voc=[];
    end_voc=[];
end
disp('Saving to excell...')

Signal_array=cell(size(init_voc,2),1);
Path_array=cell(size(init_voc,2),1);
Signal_array(:)={name};
Path_array(:)={path};

folderName=[path,'Segmentation Results (Manual)'];
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

saving_directory=folderName;% diretoria para guardar ficheiro excell com vocalizacoes

filename = [saving_directory,'\',name,'_vocalizations.xls'];

disp(filename)
header={'#','Begining (s)','End(s)','Duration'};%,'Peak Frequency','Min Frequency','Mean Frequency','F(0)','F(end)','Delta frequency','Short Time Energy','Energy(dB)','Label(Custom)','','','','','Path','Filename'};
xlswrite(filename,header,'Folha1','A1');
xlswrite(filename,init_voc','Folha1','B2');
xlswrite(filename,fim_voc','Folha1','C2');
xlswrite(filename,(1:1:size(init_voc,2))','Folha1','A2');
xlswrite(filename,(fim_voc-init_voc)','Folha1','D2');
% xlswrite(filename,peak_frequency_list,'Folha1','E2');
% xlswrite(filename,min_frequency_list,'Folha1','F2');
% xlswrite(filename,mean_frequency_list,'Folha1','G2');
% xlswrite(filename,freq_init_list,'Folha1','H2');
% xlswrite(filename,freq_end_list,'Folha1','I2');
% xlswrite(filename,bandwith_list,'Folha1','J2');
% xlswrite(filename,ste_list,'Folha1','K2');
% xlswrite(filename,Energy_dB_list,'Folha1','L2');
% xlswrite(filename,NaN(size(init_voc,2),1),'Folha1','M2');%-4*ones(size(init_voc,2),1)
xlswrite(filename,{path},'Folha1','R2');
xlswrite(filename,{name},'Folha1','S2');

disp('The end!')