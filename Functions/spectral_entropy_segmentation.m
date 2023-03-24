function spectral_entropy_segmentation(path, name, cut_freq, threshold, min_threshold, filtering)

path = replace(path, '\', '/'); % for macOS/linux 

if filtering == 0
    cut_freq = NaN;
end

audio_filename = strcat(path, name);
[~,~,ext] = fileparts(audio_filename);

info = audioinfo(audio_filename);
signal_len = info.TotalSamples;
signal_duration = info.Duration;
Fs = info.SampleRate;

% read audio signal and divide into chunks
[audio,Fs] = audioread(audio_filename);

chunk_time = 1; % duration of chunks to compute the spectral entropy
chunk_overlap = 0; % chunks overlap
if chunk_overlap == 0
    chunk_hop = chunk_time;
else
    chunk_hop = chunk_time * chunk_overlap;
end
sample_time = 1/Fs;
divided_audio = divide_audio_chunks(audio,chunk_time,chunk_overlap,sample_time,signal_duration);

% create variables to store spectral entropy
audio_chunk = divided_audio.('chunk_1');
[~,te] = pentropy(audio_chunk,Fs);
number_chunks = nnz(~contains(fieldnames(divided_audio), 't_') & ~contains(fieldnames(divided_audio), 'idx_'));
diff_te = diff(te);
%se_t_resolution = diff_te(1);

% % SE parameters
% %window_size = 128;%ms
% window = 2^13;
% overlap_percentage = 0.50;
% noverlap = round(window*overlap_percentage);
% column_time = (window-noverlap)/Fs;%spectrogram temporal resolution            
% 
% [p,f,t] = pspectrum(audio_chunk,Fs,'spectrogram','FrequencyLimits',[0, Fs/2],'TimeResolution', column_time, 'OverlapPercent', overlap_percentage);
% [pe,te] = pentropy(p,f,t);
% plot(te,pe)
% 
% figure
% [pe_auto,te_auto] = pentropy(audio_chunk,Fs);
% plot(te_auto,pe_auto)

tic
disp(' ')
disp(['File:',name])
disp('Starting...')

% Variables to store spectral entropy and according time vectors
se_all_chunks = [];
t_se_all_chunks = [];

% Extract spectral entropy from all chunks
for chunk = 1:number_chunks
    audio_chunk = divided_audio.(strcat("chunk_",string(chunk)));

    if filtering
         audio_chunk = filter_signal(audio_chunk,Fs,cut_freq);
    end
    [se,te] = pentropy(audio_chunk,Fs);

    te = linspace(0, chunk_time, length(te));

    se_all_chunks = [se_all_chunks; se'];
    t_se_all_chunks = [t_se_all_chunks; te];

end
% create time vectors
for chunk = 2:number_chunks
    idx_hop = find(t_se_all_chunks((chunk - 1), :) > chunk_hop * (chunk - 1), 1, "first");
    if isempty(idx_hop)
        idx_hop = size(t_se_all_chunks,2);
    end

    t_se_all_chunks(chunk, :) = t_se_all_chunks(chunk, :) + t_se_all_chunks((chunk - 1), idx_hop);
end

% create final variables for spectral entropy
t_se_all_chunks = round(t_se_all_chunks,10);
final_time_vector = unique(t_se_all_chunks)';

final_se_vector = NaN(number_chunks, length(final_time_vector));
for chunk = 1:number_chunks
    se_chunk = se_all_chunks(chunk,:);

    if chunk == 1
        final_se_vector(1,1:length(se_chunk)) = se_chunk;
    else        
        idx = find(t_se_all_chunks(chunk,1) < final_time_vector,1); 
        
        final_se_vector(chunk,((idx - 1) : (idx-1)+length(se_chunk) - 1)) = se_chunk;
    end
end

% Remove padding
final_idx = find(final_time_vector<signal_duration,1,"last");
final_se_vector = final_se_vector(:,1:final_idx);
final_se_vector = mean(final_se_vector,1,"omitnan");
final_time_vector = final_time_vector(1:final_idx);

% smooth spectral entropy
final_se_vector = smoothdata(final_se_vector);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Get events onset
% Variables to store USVs temporal onsets
init_USV = [];
end_USV = [];

% get intervals below threshold
mask_bellow_threshold = final_se_vector < threshold;
flag = false;
separation_threshold = 15 * 10^(-3); % join USVs if they are closer

for i = 1:length(mask_bellow_threshold)
    if mask_bellow_threshold(i) == 1 & ~flag
        flag = true;        
        init_USV = [init_USV, final_time_vector(i)]; % store USV initial instant
    elseif mask_bellow_threshold(i) == 0 & flag
        flag = false;        
        end_USV = [end_USV, final_time_vector(i)]; % store USV initial instant

        if(min(final_se_vector( find(final_time_vector == init_USV(end)):find(final_time_vector==end_USV(end))) ) > min_threshold) % second threshold validation
            init_USV(end)=[];
            end_USV(end)=[];
        end

        if(size(end_USV,2)>1)
            if(init_USV(end)-end_USV(end-1)<separation_threshold) % USVs separation
                init_USV(end)=[];
                end_USV(end-1)=[];
            end
        end
    end
end
if(size(init_USV,2)>size(end_USV,2))
    end_USV = [end_USV,final_time_vector(end)];
end

% variable with timestamps
USVs_timestamps = array2table([init_USV', end_USV', end_USV' - init_USV'], 'VariableNames', {'Begin','End','Duration'});


% Extract contour derived metrics/features
peak_frequency_list = zeros(size(USVs_timestamps,1),1);
min_frequency_list = zeros(size(USVs_timestamps,1),1);
freq_init_list = zeros(size(USVs_timestamps,1),1);
freq_end_list = zeros(size(USVs_timestamps,1),1);
bandwith_list = zeros(size(USVs_timestamps,1),1);
mean_frequency_list = zeros(size(USVs_timestamps,1),1);
ste_list = zeros(size(USVs_timestamps,1),1);
Energy_dB_list = zeros(size(USVs_timestamps,1),1);
for m = 1:size(USVs_timestamps,1)
    [y_voc,~] = audioread([path name],[ceil(init_USV(m)*Fs), ceil(end_USV(m)*Fs)]);
    y_voc = filter_signal(y_voc, Fs, cut_freq);% filtragem do sinal
    y_voc = pre_emphasis_filter(y_voc, -0.3);%pre-emphasis filter
    
    feat = USV_characteristics_contour(y_voc,Fs);
    
    % Store USV characteristics
    peak_frequency_list(m,1) = feat(1);
    min_frequency_list(m,1) = feat(2);
    freq_init_list(m,1) = feat(3);
    freq_end_list(m,1) = feat(4);
    bandwith_list(m,1) = feat(5);
    mean_frequency_list(m,1) = feat(6);
    ste_list(m,1) = feat(7);
    Energy_dB_list(m,1) = feat(8);
end

disp([name,' done!'])
timeElapsed = toc;
disp(['Time Elapsed ->', num2str(timeElapsed),' s'])
disp('Saving to excell...')


%%%% Saving segmented USVs
saving_directory=[path, 'Segmentation Results (Spectral Entropy)'];
if ~exist(saving_directory, 'dir')
    mkdir(saving_directory);
end

data = replace(string(datetime("now")),':','_');
xlsx_filename = strcat(saving_directory,'/',data, '_', replace(name, ext, '.xlsx'));


header = {'#','Begining(s)','End(s)','Duration','Peak Frequency','Min Frequency','Mean Frequency','F(0)','F(end)',...
          'Delta frequency','Short Time Energy','Energy(dB)','Class','','SampleRate','Cut Freq','Thresh1','Thresh2','Path','Filename'};

writecell(header, xlsx_filename, 'Sheet', 1, 'Range', 'A1');
try
    % USVs
    writematrix(USVs_timestamps.Begin, xlsx_filename, 'Sheet', 1, 'Range', 'B2');
    writematrix(USVs_timestamps.End, xlsx_filename, 'Sheet', 1, 'Range', 'C2');
    writematrix((1:1:size(USVs_timestamps,1))', xlsx_filename, 'Sheet', 1, 'Range', 'A2');
    writematrix(USVs_timestamps.Duration, xlsx_filename, 'Sheet', 1, 'Range', 'D2');
    writematrix(peak_frequency_list, xlsx_filename, 'Sheet', 1, 'Range', 'E2');
    writematrix(min_frequency_list, xlsx_filename, 'Sheet', 1, 'Range', 'F2');
    writematrix(mean_frequency_list, xlsx_filename, 'Sheet', 1, 'Range', 'G2');
    writematrix(freq_init_list, xlsx_filename, 'Sheet', 1, 'Range', 'H2');
    writematrix(freq_end_list, xlsx_filename, 'Sheet', 1, 'Range', 'I2');
    writematrix(bandwith_list, xlsx_filename, 'Sheet', 1, 'Range', 'J2');
    writematrix(ste_list, xlsx_filename, 'Sheet', 1, 'Range', 'K2');
    writematrix(Energy_dB_list, xlsx_filename, 'Sheet', 1, 'Range', 'L2');
    
    % metadata
    writecell({Fs}, xlsx_filename, 'Sheet', 1, 'Range', 'O2');
    writecell({cut_freq}, xlsx_filename, 'Sheet', 1, 'Range', 'P2');
    writecell({threshold}, xlsx_filename, 'Sheet', 1, 'Range', 'Q2');
    writecell({min_threshold}, xlsx_filename, 'Sheet', 1, 'Range', 'R2');
    writecell({path}, xlsx_filename, 'Sheet', 1, 'Range', 'S2');
    writecell({name}, xlsx_filename, 'Sheet', 1, 'Range', 'T2');
catch
    %disp('No vocalizations detected!')
end

end

%%% Aux functions
function divided_audio = divide_audio_chunks(audio,chunk_time,chunk_overlap,column_time,audio_duration)
%divide audio representations into chunks
time = linspace(0,audio_duration,length(audio))';

n_instants_chunk = round(chunk_time/column_time);
n_instants_overlap = round((chunk_time/column_time)*chunk_overlap);

try
    instants_chunks = buffer(1:length(audio),n_instants_chunk,n_instants_overlap,'nodelay');%determine the instants for the chunks
catch % for the padding cases
    instants_chunks = buffer(1:length(audio),n_instants_chunk,0,'nodelay');%determine the instants for the chunks
end

for i = 1:size(instants_chunks,2)
    idx = instants_chunks(:,i); % get the indexes for each chunk
    idx(idx==0) = [];
    
    if(length(idx) == n_instants_chunk)
        chunk = audio(idx);
        time_chunk = time(idx);
        divided_audio.(['chunk_',num2str(i)]) = chunk;
        divided_audio.(['idx_chunk_',num2str(i)]) = idx;
        divided_audio.(['t_chunk_',num2str(i)]) = time_chunk;
    else %padding
        chunk = [audio(idx);zeros((n_instants_chunk-length(idx)),1)];
        time_chunk = [time(idx); (-1)*ones((n_instants_chunk-length(idx)),1)];
        divided_audio.(['chunk_',num2str(i)]) = chunk;
        divided_audio.(['idx_chunk_',num2str(i)]) = idx;
        divided_audio.(['t_chunk_',num2str(i)]) = time_chunk;
    end
end
end


