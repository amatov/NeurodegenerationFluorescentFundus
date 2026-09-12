function metrics = activeContTest;

% activeContTest segments the exact contour of hyper-fluorescent areas around the optical nurve 
% 
%
% SYNOPSIS   metrics = activeContTest
%
% INPUT      sigma1  :    standard deviation of the first Gausisan filter
%            sigma2  :    standard deviation of the second Gaussian filter
%        iterations  :    #iterations for the active contour calculation
%
% OUTPUT     Various segmentation figures
%
% DEPENDENCES   activeContTest uses {Gauss2D, cutFirstHistMode}
%
% example run: metrics = activeContTest;
%
% Alexandre Matov, November 6th, 2022

%Igray = Gauss2D(double(imread('A:\Amydis\GC01.tif')),1);
%aux = imread('A:\Amydis\AMYDIS FIH - COHORT 1\3\FF OD POSTDOSE\POST DOSE OD_016.tif');
%aux = imread('A:\Amydis\AMYDIS FIH - COHORT 1\2\FF OD\POST DOSE_012.tif');

%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_000.tif');
% aux = imread('A:\Amydis\NHP Data for Alex\Cyno 180424\Cyno1_004.tif');
% aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191797\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191800\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191815\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191817\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 191823\Cyno1_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200188\Cyno 200188_004.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200188\Cyno2_005.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200190\Cyno2_003.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200193\Cyno2_003.tif');
%aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200217\Cyno2_003.tif');
% EDIT: hardcoded absolute path to the original author's machine
aux = imread('A:\Amydis\NHP Data for Alex\Cyno 200251\Cyno2_006.tif');

%aux = imread('A:\Amydis\Glaucoma SDEB Eye #2\Bottom\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01_ChS1-T2_ORG.tif');
%aux = imread('A:\Amydis\SNR Images for Intensity\57 CON\Untitled57_c2.tif');

aux1 = rgb2gray(aux);
%s = 1500;
s = 750;
Igray = Gauss2D(double(aux1(1:end,:)),1);
Iblur = Gauss2D(double(aux1(1:end,:)),4);
Idiff = Igray - Iblur;
Idiff(find(Idiff<0))=0; % clipping
mD = max(Idiff(:));
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
title('Segmented Image, 1300 Iterations')

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
