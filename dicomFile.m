function dicomFile

% dicomFile selects labelled protein aggregate areas in retinal images with
% SIFT
%
% SYNOPSIS   dicomFile
%
% INPUT      I1  :    raw image
%
% OUTPUT     images with Difference of Gaussians transform and SIFT
% detections
%
% DEPENDENCES   dicomFile uses {Matlab native functions}
%
% example run: dicomFile;
%
% Alexandre Matov, January 6th, 2023
%%
% dirName = uigetdir('C:\');
% cd(dirName)
% rootdir = dirName;%'A:\Amydis\Glaucoma SDEB Eye #2';
% filelist = dir(fullfile(rootdir, '*.dcm'));
%-----------------------------------------------
% EDIT: hardcoded absolute path to the original author's machine
I1 = dicomread('A:\Amydis\AMYDIS FIH - COHORT 1\1\OPTOS\01-101_PROBE____01-101_ 1\1.2.826.0.2.139953.3.1.2.3790383533.20220906090530.1610592815.dcm');
%I1 = dicomread('A:\Amydis\AMYDIS FIH - COHORT 1\1\OPTOS\01-101_PROBE____01-101_ 1\1.2.826.0.2.139953.3.1.2.3790383533.20220906090530.1611098917.dcm');
%I1 = dicomread('A:\Amydis\AMYDIS FIH - COHORT 1\1\OPTOS\01-101_PROBE____01-101_ 1\1.2.826.0.2.139953.3.1.2.3790383533.20220906090530.1610592815.dcm');
%----------------------
I = rgb2gray(I1);
%figure, imshow(I,[])
%----------------------
Igray = Gauss2D(double(I),1); % filtering of high frequency background noise
Iblur = Gauss2D(double(I),7); % filtering of background nonspecific intensity
Idiff = Igray - Iblur; % difference of gaussians
Idiff(find(Idiff<0))=0; % clipping of negative values
figure, imshow(Idiff,[0 50]);
%--------------------
 figure
 points = detectSIFTFeatures(I);
 imshow(I); hold on;
plot(points.selectStrongest(5))
%----------------------------------
% info = dicominfo('A:\Amydis\AMYDIS FIH - COHORT 1\1\OPTOS\01-101_PROBE____01-101_ 1\1.2.826.0.2.139953.3.1.2.3790383533.20220906090530.1610592815.dcm');
% Y = dicomread(info);
% figure
% imshow(Y,[]);