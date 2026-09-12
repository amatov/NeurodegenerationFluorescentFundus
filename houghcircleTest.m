function [y0detect,x0detect,Accumulator] = houghcircleTest(I, minR, maxR)

% houghcircleTest selects labelled protein aggregate areas in retinal
% images, which are shaped like circles
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose an image for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed and saved to disk together with a .MAT file containing all
% metrics and a .TXT file with some of the metrics
%
% SYNOPSIS   function metrics = houghcircleTest(I,minR, maxR)
%
%
% INPUT      I       :    raw image
%            minRad  :    smallest circle radius
%            maxRad  :    largest circle radius
%
% OUTPUT     metrics     :    The coordinates and radii of detected circles
%
% DEPENDENCES   houghcircleTest uses {Matlab native functions}
%
% example run: metrics = houghcircleTest;
%
% Alexandre Matov, Januart 6th, 2023

% EDIT: hardcoded absolute path to the original author's machine
A = imread('A:\Amydis\Glaucoma SDEB Eye #2\Bottom\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01_ChS1-T2_ORG.tif');
%A = imread('coins.png');
imshow(A)

[centers, radii, metric] = imfindcircles(A,[3 55]);% [15 30]

n = 2;
centersStrong5 = centers(1:n,:); 
radiiStrong5 = radii(1:n);
metricStrong5 = metric(1:n);

viscircles(centersStrong5, radiiStrong5,'EdgeColor','b');