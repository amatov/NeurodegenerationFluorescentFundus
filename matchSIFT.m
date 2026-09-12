function [matchMetricSIFT,matchMetricSURF] = matchSIFT(scale,theta)

% matchSIFT(scale,theta) matches labelled protein aggregate areas in retinal
% images based on SIFT and SURF detectors
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose an image for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed 
%
% SYNOPSIS   metrics = matchSIFT(scale,theta)
%
% INPUT   scale : difference in scale between the two images to be matched
%         theta : rotational difference between the images to be matched
%
% OUTPUT     metrics     :    Feature matching figures
%
% DEPENDENCES   matchSIFT uses {Matlab native functions}
%
% example run: metrics = matchSIFT;
%
% Alexandre Matov, December 26th, 2022

%I1 = imread('A:\Amydis\AMYDIS FIH - COHORT 1\3\FF OS PREDOSE\PREDOSE OS_000.tif');% BAD detection
%I2 = imread('A:\Amydis\AMYDIS FIH - COHORT 1\3\FF OD PREDOSE\PREDOSE_000.tif');

% good example
%I1 = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_000.tif');
% EDIT: hardcoded absolute path to the original author's machine
I1 = imread('A:\Amydis\NewDataJan2023\Cyno 170395\Cyno1_005.tif');
% EDIT: hardcoded absolute path to the original author's machine
I2 = imread('A:\Amydis\NewDataJan2023\Cyno 170395\Visit 2\Cyno1_012.png');

%I1 = imread('A:\Amydis\NHP Data for Alex\Cyno 191815\Cyno1_004.tif');
%I1 = imread('A:\Amydis\NHP Data for Alex\Cyno 180424\Cyno1_001.tif');

%I2 = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_004.tif');
%I2 = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_000.tif');

%Ip = imread('A:\Amydis\NewDataJan2023\Cyno 191815\Visit 2\Cyno1_003.png');
%Ip = imread('A:\Amydis\NewDataJan2023\Cyno 180424\Visit 2\Cyno1_001.png');
%Ip = imread('A:\Amydis\NewDataJan2023\Cyno 200251\Visit 2\Cyno2_001.png');
%imwrite(Ip,'A:\Amydis\NewDataJan2023\Cyno 180424\Visit 2\Cyno1_001.tif');
%I2 = imread('A:\Amydis\NewDataJan2023\Cyno 180424\Visit 2\Cyno1_001.tif');
%I2 = imread('A:\Amydis\NewDataJan2023\Cyno 191815\Visit 2\Cyno1_003.tif');

I1 = rgb2gray(I1);
I2 = rgb2gray(I2);
I1 = I1(1:1500,10:end);
%I2 = I2(1:800,10:end);
%I1 = I1(1:1200,1:end);
I2a = I2(1:700,10:end);
scale = 2 ;
I2b = imresize(I2a,scale); % Try varying the scale factor.
theta = -0;%20;
% Note that imrotate rotates images in a counterclockwise direction when
% you specify a positive angl8 of rotation. To rotate the image clockwise,
% specify a negative theta.
I2 = imrotate(I2b,-theta); % Try varying the angle, theta.

%Find the SIFT features.
points1 = detectSIFTFeatures(I1);
points2 = detectSIFTFeatures(I2);
%points1 = detectSURFFeatures(I1);
%points2 = detectSURFFeatures(I2);

%Extract the features.
[f1,vpts1] = extractFeatures(I1,points1);
[f2,vpts2] = extractFeatures(I2,points2);

%Retrieve the locations of matched points.
[indexPairsSIFT, matchMetricSIFT]  = matchFeatures(f1,f2);%,'MatchThreshold',1,'MaxRatio',1) ;
matchedPoints1 = vpts1(indexPairsSIFT(:,1));
matchedPoints2 = vpts2(indexPairsSIFT(:,2));

%Display the matching points. The data still includes several outliers, but you can see the effects of rotation and scaling on the display of matched features.
figure; showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
legend("matched points 1","matched points 2");
%------------------------------------
ptsOriginal = detectSURFFeatures(I1);
ptsDistorted = detectSURFFeatures(I2);

%Extract feature descriptors.
[featuresOriginal,validPtsOriginal] = extractFeatures(I1,ptsOriginal);
[featuresDistorted,validPtsDistorted] = extractFeatures(I2,ptsDistorted);

%Match features by using their descriptors.
[indexPairsSURF, matchMetricSURF] = matchFeatures(featuresOriginal,featuresDistorted);

%Retrieve locations of corresponding points for each image.
I1M = validPtsOriginal(indexPairsSURF(:,1));
I2M = validPtsDistorted(indexPairsSURF(:,2));

%Show putative point matches.
figure
showMatchedFeatures(I1,I2,I1M,I2M);
title('Putatively matched points (including outliers)');

%estimate transformation
[tform, inlierIdx] = estgeotform2d(I2M,I1M,'similarity');
inlierDistorted = I2M(inlierIdx,:);
inlierOriginal = I1M(inlierIdx,:);

%Display matching point pairs used in the computation of the transformation.
figure;
showMatchedFeatures(I1,I2,inlierOriginal,inlierDistorted);
title('Matching points (inliers only)');
legend('ptsOriginal','ptsDistorted');


%Find the corners.
points1 = detectHarrisFeatures(I1);
points2 = detectHarrisFeatures(I2);

%Find SIFT features
%points1 = detectSIFTFeatures(I1);
%points2 = detectSIFTFeatures(I2);


%Extract the neighborhood features.
[features1,valid_points1] = extractFeatures(I1,points1);
[features2,valid_points2] = extractFeatures(I2,points2);

%Match the features.
indexPairs = matchFeatures(features1,features2);

%Retrieve the locations of the corresponding points for each image.
matchedPoints1 = valid_points1(indexPairs(:,1),:);
matchedPoints2 = valid_points2(indexPairs(:,2),:);

%Visualize the corresponding points. You can see the effect of translation between the two images despite several erroneous matches.
figure; 
showMatchedFeatures(I1,I2,matchedPoints1,matchedPoints2);
