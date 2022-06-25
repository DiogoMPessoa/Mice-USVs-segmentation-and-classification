function classify_xls(filename,model)

addpath(genpath('\Classification\ACA-Code-master'))

[~,~,raw]= xlsread(filename);

Fs=raw{2,16};
name_signal=raw{2,21};
path_signal=raw{2,20};

table=raw(2:end,[2,3]);

X=[];
for i=1:length(table)        
    [y_voc,Fs]= audioread([path_signal,'\',name_signal],[ceil(table{i,1}*Fs) ceil(table{i,2}*Fs)]);
    
    y_voc=filter_signal(y_voc,Fs,30000);% filtragem do sinal
    %y_voc=pre_emphasis_filter(y_voc,-0.3);%pre-emphasis filter
    
    
    feat_max=Voc_characteristics(y_voc,Fs,'max');
    feat_max=feat_max';
    
    feat_ACA=features_toolbox_ACA(y_voc,Fs);
    feat_ACA=feat_ACA';
    
    im_array=ImageFromVoc(y_voc,Fs,0);
    feat_LBP=extractLBPFeatures(im_array)';
    
    feat=[feat_max;feat_ACA;feat_LBP];
    
    X=[X,feat];
end

load('SVM_model.mat')
[labels_predicted,~,~] = predict(Mdl,X');

raw(2:end,13)=num2cell(labels_predicted);

xlswrite(filename,raw,'Folha1','A1');



