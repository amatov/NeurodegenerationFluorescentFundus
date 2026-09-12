function metrics = autofluorescenceNHP

% autofluorescenceNHP selects autofluorescent puncta in NHP retinal images
% 
% user can select min/max ranges for certain morphological parameters to
% facilitate the detection
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose an image for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed and saved to disk together with a .MAT file containing all
% metrics and a .TXT file with some of the metrics
%
% SYNOPSIS   metrics = autofluorescenceNHP
%
% INPUT      aux  :    raw image
%
%            
% OUTPUT     Multiple images showing different transforms/selection methods
%
% DEPENDENCES   metrics = autofluorescenceNHP uses {Gauss2D, cutFirstHistMode}
%
% example run: metrics = metrics = autofluorescenceNHP;
%
% Alexandre Matov, November 6th, 2022

%Igray = Gauss2D(double(imread('A:\Amydis\GC01.tif')),1);
%aux = imread('A:\Amydis\AMYDIS FIH - COHORT 1\3\FF OD POSTDOSE\POST DOSE OD_016.tif');
%aux = imread('A:\Amydis\AMYDIS FIH - COHORT 1\2\FF OD\POST DOSE_012.tif');

%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_000.tif');
% aux = imread('A:\Amydis\NHP Data for Alex\Cyno 180424\Cyno1_004.tif');
% EDIT: hardcoded absolute path to the original author's machine
aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191797\Cyno1_000.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191800\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191815\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191817\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191823\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200188\Cyno 200188_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200188\Cyno2_005.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200190\Cyno2_003.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200193\Cyno2_003.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200217\Cyno2_003.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200251\Cyno2_006.tif');

%aux = imread('A:\Amydis\Glaucoma SDEB Eye #2\Bottom\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01_ChS1-T2_ORG.tif');
%aux = imread('A:\Amydis\SNR Images for Intensity\57 CON\Untitled57_c2.tif');

aux1 = rgb2gray(aux);
%s = 1500;
s = 1500;%700;
Igray = Gauss2D(double(aux1(1:s,:)),1);
Iblur = Gauss2D(double(aux1(1:s,:)),4);
Idiff = Igray - Iblur;
Idiff(find(Idiff<0))=0; % clipping

imbw=im2bw(Idiff);
X = bwlabel(imbw);
    stats = regionprops(X,'all'); %
    aux2 = X.*double(aux1(1:s,:));
    figure,imshow(aux2,[0 max(Idiff(:))/4])
    mD = max(Idiff(:));

    aux3 = Idiff>mD/2;%/2 for 1st image
    figure,imshow(aux3,[])
    
    s=regionprops(X,Idiff,'MaxIntensity');
    max([s.MaxIntensity])%  41.6973 (of 255 or so)
[value,indx]=max([s.MaxIntensity]) %indx 857
    hold on 
    x = stats(indx).Centroid(1);
    y = stats(indx).Centroid(2);
    pxlSize = 7;
    %plot(stats(indx).Centroid(1),stats(indx).Centroid(2),'y*')
       text(x+12,y+12,[num2str(round(stats(indx).Perimeter*pxlSize))],'Color','r');
                      text(x+50,y+50,[num2str(round(stats(indx).Area*pxlSize*pxlSize*10)/10)],'Color','g');
                       text(x+80,y+80,[num2str(value)],'Color','y');% display aggregatte max intensity
                           title(['perimeter in microns (red), area in square microns (green), max. intensity in arbitrary units (yellow)']);

    figure, imshow(Idiff,[0 max(Idiff(:))/3])%/4 for 1st image
       hold on 
    plot(stats(indx).Centroid(1),stats(indx).Centroid(2),'r*')

figure,imshow(double(aux1(1:end,:)),[])
figure, imshow(Idiff,[0 mD/4])
BW3 = bwmorph(Idiff,'skel',Inf);
 auxT = BW3.*Igray;
figure, imshow(auxT,[])
%Igray = double(imread('A:\Amydis\GC01.tif'));
%figure,imshow(Igray,[])
    [cutoffInd, cutoffV] = cutFirstHistMode(Igray,0);

threshold = cutoffV;
%I = rgb2gray(x);
I = Igray>50;%145;%(threshold*2);
imshow (I);
figure,imshow(I.*Igray,[])
%I = imresize(I,.5); 
%imshow(I)
%title('Original Image')

mask = zeros(size(I));
mask(25:end-25,25:end-25) = 1;
imshow(mask)
title('Initial Contour Location')
bw = activecontour(I,mask,1300);
imshow(bw)
title('Segmented Image, 300 Iterations')

X = bwlabel(bw);
%     warningState = warning;
%     warning off all
%     intwarning off
    stats = regionprops(X,'all'); %

        % Initialize 'feats' structure
    feats=struct(...
        'pos',[0 0],...                  % Centroid - [y x]
        'ecc',0,...                      % Eccentricity
        'ori',0);   % Orientation

    for j = 1:length(stats)
        feats.pos(j,1) = stats(j).Centroid(1);
        feats.pos(j,2) = stats(j).Centroid(2);
        feats.ecc(j,1) = stats(j).Eccentricity;
        feats.ori(j,1) = stats(j).Orientation;
        feats.len(j,1) = stats(j).MajorAxisLength;
    end
    figure,imshow(Igray.*bw,[])
    hold on
    imcontour(bw,3)
    for i = 1:length(stats)
        if (stats(i).Area>500)
            x=stats(i).Centroid(1);
            y=stats(i).Centroid(2);
               % plot(x,y,'r','LineWidth',2);

   % rectangle('Position',[x-40, y - 40, 81,81],'EdgeColor','r');
%           text(stats(i).Centroid(1)+10,stats(i).Centroid(2)+10,[num2str(stats(i).Area)],'Color','r');

   % plot(x,y,'r','LineWidth',2);
        end
    end

        goodFeats = find(15<(feats.len));  
        
        
    featNames = fieldnames(feats);
    for field = 1:length(featNames)
        feats.(featNames{field}) = feats.(featNames{field})(goodFeats,:);
    end
