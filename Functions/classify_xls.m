function classify_xls(filename)

table = readtable(filename, 'VariableNamingRule', 'preserve');

Fs = table.SampleRate(1);
name_signal = table.Filename{1};
path_signal = table.Path{1};


features_all_USVs=zeros(128,size(table,1));
for i=1:size(table,1)
    [y_voc,Fs] = audioread([path_signal,'\',name_signal],[ceil(table.("Begining(s)")(i)  *Fs), ceil(table.("End(s)")(i) * Fs)]);
    
    y_voc = filter_signal(y_voc,Fs,30000);% signal filtering
    y_voc = pre_emphasis_filter(y_voc,-0.3);%pre-emphasis filter
    
    feat_max = USV_characteristics(y_voc,Fs,'max');
    feat_max = feat_max';
    
    feat_ACA = features_toolbox_ACA(y_voc,Fs);
    feat_ACA = feat_ACA';
    
    im_array = ImageFromVoc(y_voc,Fs,0);
    feat_LBP = extractLBPFeatures(im_array)';
    
    feat=[feat_max;feat_ACA;feat_LBP];

    features_all_USVs(:,i) = feat;
end

Mdl = load('TreeEnsembleModel.mat');
Mdl = Mdl.Mdl;
best_features_idx = load('Relief80Tree.mat');
best_features_idx = best_features_idx.best_features_idx;

features_all_USVs = features_all_USVs(best_features_idx,:);

labels_class = {'Complex','One_FS','M_FS','Up','Down','Flat','Short','Chevron','Rev_Chev',' Composite'};

[labels_predicted,~,~] = predict(Mdl,features_all_USVs');
labels_predicted_str = cell(size(labels_predicted));

for i = 1:size(labels_predicted_str)
    labels_predicted_str{i} = labels_class{labels_predicted(i)};
end
table.Class = labels_predicted_str;

delete(filename)
writetable(table, filename, 'Sheet', 1, 'Range', 'A1')

end



