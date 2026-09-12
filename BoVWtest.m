function [trainingSet,testSet] = BoVWtest

% BoVWtest classifies labelled protein aggregate areas in retinal
% images based on the bag of visual words model
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose a folder for analysis from your computer
% 3) classification metrics will be printed on the screen
%
% SYNOPSIS   metrics = BoVWtest(imds,img)
%
% INPUT   imds : path to folders with images from different categories
%         img  : new image to be classified
%
% OUTPUT     metrics     :    trainingSet & testSet 
%
% DEPENDENCES   BoVWtest uses {Matlab native functions}
%
% example run: metrics = BoVWtest;
%
% Creating Bag-Of-Features:
% Image category 1: Cyno 170395
% Image category 2: Cyno 180424
% Image category 3: Cyno 191797
% Image category 4: Cyno 191800
% Image category 5: Cyno 191815
% Image category 6: Cyno 191817
% Image category 7: Cyno 191823
% Image category 8: Cyno 200188
% Image category 9: Cyno 200190
% Image category 10: Cyno 200193
% Image category 11: Cyno 200217
% Image category 12: Cyno 200251
%
% Creating a 500 word visual vocabulary:
% Number of levels: 1
% Branching factor: 500
% Number of clustering steps: 1
%
% Alexandre Matov, December 26th, 2022

%setDir  = fullfile(toolboxdir('vision'),'visiondata','imageSets');
%imds = imageDatastore(setDir,'IncludeSubfolders',true,'LabelSource',...
%    'foldernames');
% EDIT: hardcoded absolute path to the original author's machine
imds = imageDatastore(fullfile("A:\Amydis\NHP Data for Alex"),...
"IncludeSubfolders",true,"FileExtensions",".tif","LabelSource","foldernames");
imshow(preview(imds));
[trainingSet,testSet] = splitEachLabel(imds,0.3,'randomize');

bag = bagOfFeatures(trainingSet);

categoryClassifier = trainImageCategoryClassifier(trainingSet,bag);

confMatrix = evaluate(categoryClassifier,testSet)

mean(diag(confMatrix))

% EDIT: hardcoded absolute path to the original author's machine
img = imread('A:\Amydis\NHP Data for Alex\Cyno 170395\Cyno1_000.tif');
[labelIdx, score] = predict(categoryClassifier,img);

categoryClassifier.Labels(labelIdx)

