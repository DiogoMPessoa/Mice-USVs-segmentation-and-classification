function im_array=ImageFromVoc(y,Fs,color)
    f1 = figure('visible', 'off');
    spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
    set(gca,'XDir','normal');
    set(gca,'YDir','normal');
    box(gca,'off')
    set(gca,'Visible','off')
    %colormap(1-gray)
    F = getframe;
    %close
    close(f1)%
    size=250;
    if(color==1)
        F.cdata = imresize(F.cdata,[size size]);
    else
        F.cdata = rgb2gray(imresize(F.cdata,[size size]));
    end
    im_array=F.cdata;
    %     f2 = figure('visible', 'off');%
    %     %figure
    %     imshow(F.cdata)
    %
    %     dir_class=dir(fullfile([mainFolder,'\',num2str(class_voc)],'*.PNG'));
    %     num_fig=length(dir_class)+1;
    %
    %     figure_name=[mainFolder,'\',num2str(class_voc),'\',num2str(num_fig),'.png'];
    %     saveas(gcf,figure_name);
    %
    %     close(f2)%