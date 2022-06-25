function spectral_entropy_segmentation(path,name,cut_freq,threshold,min_threshold,pos_process)

info = audioinfo([path name]);
signal_len=info.TotalSamples;
Fs=info.SampleRate;

% Arrays para guardar instantes iniciais e finais das vocalizações
init_voc=[];
fim_voc=[];
voc=false;

interval=1; % intervalo em que são lidos os segmentos do sinal (Nota: quanto maior o intervalo para calcular a entropia espetral menos ruído se deteta mas a precisao da detecao das vocalizacoes tambem piora)
start=0; % instante a partir do qual é lido o sinal

tic
disp(' ')
disp(['File:',name])
disp('Starting...')
for j=1:interval*Fs:signal_len
    shift=start*Fs;
    ini=j+shift;
    fim=ini+interval*Fs;
    
    if(fim>signal_len)
        fim=signal_len;
    end
    
    [y,Fs] = audioread([path name],[ini fim]);
    
    y=filter_signal(y,Fs,cut_freq);
    
    [se,te] = pentropy(y,Fs);% calculo da entropia espetral para o segmento actual
    
    for i=1:1:size(te,1)
        if(se(i)<threshold && voc==false)
            init_voc=[init_voc (ini/Fs+te(i))]; %guarda o insntante inicial
            voc=true;
        end
        if(se(i)>threshold && voc==true)
            fim_voc=[fim_voc (ini/Fs+te(i))]; %guarda o instante final
            if(min(se(find(te==init_voc(end)):find(te==fim_voc(end))))>min_threshold)
                init_voc(end)=[];
                fim_voc(end)=[];
            end
            if(size(fim_voc,2)>1)
                if(init_voc(end)-fim_voc(end-1)<15*10^-3)%separacao entre vocalizacoes tem de ser maior do que 15 ms, se nao considera se so uma vocalizacao (artigo: Classification of mouse ultrasonic vocalizations using deep learning)
                    init_voc(end)=[];
                    fim_voc(end-1)=[];
                end
            end
            voc=false;
        end
    end
end

if(size(init_voc,2)>size(fim_voc,2))
    fim_voc=[fim_voc,signal_len/Fs];
end

if(pos_process)
end

% Guardar caracteristicas de cada vocalização
peak_frequency_list=zeros(size(init_voc,2),1);
min_frequency_list=zeros(size(init_voc,2),1);
freq_init_list=zeros(size(init_voc,2),1);
freq_end_list=zeros(size(init_voc,2),1);
bandwith_list=zeros(size(init_voc,2),1);
mean_frequency_list=zeros(size(init_voc,2),1);
ste_list=zeros(size(init_voc,2),1);
Energy_dB_list=zeros(size(init_voc,2),1);
for m=1:size(init_voc,2)
    [y_voc,~] = audioread([path name],[ceil(init_voc(m)*Fs) ceil(fim_voc(m)*Fs)]);
    y_voc=filter_signal(y_voc,Fs,cut_freq);% filtragem do sinal
    y_voc=pre_emphasis_filter(y_voc,-0.3);%pre-emphasis filter
    
    feat=Voc_characteristics(y_voc,Fs);
    
    peak_frequency_list(m,1)=feat(1);
    min_frequency_list(m,1)=feat(2);
    freq_init_list(m,1)=feat(3);
    freq_end_list(m,1)=feat(4);
    bandwith_list(m,1)=feat(5);
    mean_frequency_list(m,1)=feat(6);
    ste_list(m,1)=feat(7);
    Energy_dB_list(m,1)=feat(8);
end

disp([name,' done!'])
timeElapsed = toc;
disp(['Time Elapsed ->', num2str(timeElapsed),' s'])
disp('Saving to excell...')


path_save='C:\Users\Asus\Documents\UNIVERSIDADE\Tese\Matlab\Interface';
folderName=[path_save,'\Segmentation Results (Spectral Entropy)'];
if ~exist(folderName, 'dir')
    mkdir(folderName);
end

data = datestr(datetime(now,'ConvertFrom','datenum'));
data=replace(data,':','.');

saving_directory=folderName;% diretoria para guardar ficheiro excell com vocalizacoes

filename = [saving_directory,'\',data,'-',name,'_vocalizations.xls'];


header={'#','Begining (s)','End(s)','Duration','Peak Frequency','Min Frequency','Mean Frequency','F(0)','F(end)',...
    'Delta frequency','Short Time Energy','Energy(dB)','Class','','','SampleRate','Cut Freq','Thresh1','Thresh2','Path','Filename'};

xlswrite(filename,header,'Folha1','A1');
try
    xlswrite(filename,init_voc','Folha1','B2');
    xlswrite(filename,fim_voc','Folha1','C2');
    xlswrite(filename,(1:1:size(init_voc,2))','Folha1','A2');
    xlswrite(filename,(fim_voc-init_voc)','Folha1','D2');
    xlswrite(filename,peak_frequency_list,'Folha1','E2');
    xlswrite(filename,min_frequency_list,'Folha1','F2');
    xlswrite(filename,mean_frequency_list,'Folha1','G2');
    xlswrite(filename,freq_init_list,'Folha1','H2');
    xlswrite(filename,freq_end_list,'Folha1','I2');
    xlswrite(filename,bandwith_list,'Folha1','J2');
    xlswrite(filename,ste_list,'Folha1','K2');
    xlswrite(filename,Energy_dB_list,'Folha1','L2');
    xlswrite(filename,NaN(size(init_voc,2),1),'Folha1','M2');%-4*ones(size(init_voc,2),1)
    xlswrite(filename,{Fs},'Folha1','P2');
    xlswrite(filename,{cut_freq},'Folha1','Q2');
    xlswrite(filename,{threshold},'Folha1','R2');
    xlswrite(filename,{min_threshold},'Folha1','S2');
    xlswrite(filename,{path},'Folha1','T2');
    xlswrite(filename,{name},'Folha1','U2');
catch
    %disp('No vocalizations detected!')
end

end