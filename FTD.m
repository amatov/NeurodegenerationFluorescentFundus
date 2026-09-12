function FTD;

% FTD plots labelled protein aggregate areas in retinal images
% 
% SYNOPSIS   FTD;
%
% INPUT      tiff : raw images
%            OUTPUT     figures     :   Three processed images
%
% DEPENDENCES   count2011Test uses {Gauss2D, cutFirstHistMode}
%
% example run: FTD;
%
% Alexandre Matov, November 18th, 2022

if nargin<2
    pxlSize = 0.08; % microns
end
if nargin<4
    p1min = 500; % min area in pixels (default 500)
    p1max = 8000; % max area in pixels (default 8000)
    p2min = 120; % min perimeter around the aggregate
    p2max = 400; % max perimeter around the aggregate
end
if nargin<5
    minIn = 3600; % min pixel intensity in aggregates
end
if nargin<6
    cutoff = 1.25; % histogram cutoff factor
end

PixelSize = 0.08 ; % microns per pixel

% load images for analysis testing
% EDIT: hardcoded absolute path to the original author's machine
c1 = imread('A:\Amydis\FTD Zoom\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a_c1.tif');
c1 = double(rgb2gray(c1));
% EDIT: hardcoded absolute path to the original author's machine
c2 = imread('A:\Amydis\FTD Zoom\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a_c2.tif');
c2 = double(rgb2gray(c2));
% EDIT: hardcoded absolute path to the original author's machine
c3 = imread('A:\Amydis\FTD Zoom\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a\FTD-TDP RFAC-10 43x 2011 pTDP-594 TDP-647 02a_c3.tif');
c3 = double(rgb2gray(c3));

% EDIT: hardcoded absolute path to the original author's machine
c11 = imread('A:\Amydis\FTD Zoom\AD A-21-150-55 63x 2011 AB594 TDP647 05\AD A-21-150-55 63x 2011 AB594 TDP647 05_c1.tif');
c11 = double(rgb2gray(c11));
% EDIT: hardcoded absolute path to the original author's machine
c33 = imread('A:\Amydis\FTD Zoom\AD A-21-150-55 63x 2011 AB594 TDP647 05\AD A-21-150-55 63x 2011 AB594 TDP647 05_c3.tif');
c33 = double(rgb2gray(c33));

Igray = Gauss2D(c33,1); % filtering of high frequency background noise
Iblur = Gauss2D(c33,4); % filtering of background nonspecific intensity
Idiff = Igray - Iblur; % difference of gaussians
Idiff(find(Idiff<0))=0; % clipping of negative values
%figure, imshow(Igray,[]);
    % automated selection of pixels which belong to foreground
    [cutoffInd, cutoffV] = cutFirstHistMode(Igray,0); 

threshold = cutoffV;%*cutoff;
%I = rgb2gray(I);
I = Igray>threshold;
% figure,imshow (I);
% figure,imshow(I.*Igray,[]);
figure,imshow(I.*c11,[0 105])% 0-105
figure,imshow(I.*c33,[0 105])% 0-86
a
