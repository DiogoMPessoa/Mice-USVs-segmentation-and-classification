function n=number_f_steps(y,Fs)
%y=pre_emphasis_filter(y,-0.3);%pre-emphasis filter

f1 = figure('visible', 'off');%
spectrogram(y,256,128,1024,Fs,'yaxis','MinThreshold',-110);
%fsst(y,Fs,'yaxis')

set(gca,'XDir','normal');
set(gca,'YDir','normal');
box(gca,'off')
set(gca,'Visible','off')
%colormap(1-gray)
F = getframe;
%close
close(f1)%

%F.cdata = rgb2gray(imresize(F.cdata,[160 160]));
a=F.cdata;

a=a(:,:,2);%escolher apenas o canal verde
bw=imbinarize(a,0.3);
a=bwmorph(medfilt2(bw),'open');
se=strel('disk',15);
%imshow(imclose(a,se))
b=imclose(a,se);
cc=bwconncomp(b);
%imshow(imclose(a,se))
regions=regionprops(cc,'all');%regions

segment_areas=cell2mat({regions.Area});
segment_eccentricity=cell2mat({regions.Eccentricity});
segment_solidity=cell2mat({regions.Solidity});

%threshold=250;%area em pixeis
%threshold=size(a,2)*0.15;
threshold=max(segment_areas)*0.2;

n=length(find(segment_areas>threshold & segment_eccentricity>0.9))-1; %number of frequency steps

if(n<0)
    n=0;
end