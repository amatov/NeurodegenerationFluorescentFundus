% EDIT: hardcoded absolute path to the original author's machine
addpath(genpath(['A:\Amydis\NewDataJan2023']));

% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_TMK1

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_TMK1


% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_MKN7

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_MKN7
%----------------

% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_SNU1

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_SNU1

% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_AZ521

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_AZ521

% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_MKN45

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_MKN45
%------------

% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_SCH

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_SCH


% this function create profile.mat in each image directory; profile.mat stores file names in each channel
createproc_GC_HS746T

% this function invokes sc_handseg.m, to crop each individual region
handseg_GC_HS746T
%----------------

% cell level feature calculation
SC_CellLevelFeatures_Wrapper

% combine features and do t-test
TTest_Features

