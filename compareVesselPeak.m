function [outputArg1,outputArg2] = compareVesselPeak(inputArg1,inputArg2)
 
% compareVesselPeak compares the localization of bright pixels in AMDX-2011P retinal images
% 
%
% SYNOPSIS  compareVesselPeak
%
% INPUT      I    :  raw image 
%         
% OUTPUT     pixel intensity ranges figures
%
% DEPENDENCES   compareVesselPeak uses {Matlab native functions}
%
% example run: compareVesselPeak;
%
% Alexandre Matov, February 8th, 2023

% EDIT: hardcoded absolute path to the original author's machine
Ipeak2 = imread('A:\Amydis\NewDataJan2023\Cyno 200188\Cyno2_004.tif');
% EDIT: hardcoded absolute path to the original author's machine
Ipeak5 = imread('A:\Amydis\NewDataJan2023\Cyno 200188\Cyno2_005.tif');
I2 = rgb2gray(Ipeak2);
I=I2(1:1500,:);%700,:);or 1500 for ex vivo
%I = imread('A:\Amydis\NewDataJan2023\Cyno 200188\Cyno2_001.tif');
%I = I(1:1500,:);
I = double(I); 
 figure,imshow(I,[])
%list = find(I>240);
%Ivess = I(list);
Ivess = I>200 & I<=240;
figure,imshow(Ivess,[])
%Igray = Gauss2D(double(aux1),1); % filtering of high frequency background noise
