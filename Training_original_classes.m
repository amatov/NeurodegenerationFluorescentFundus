%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% =======================================================================
% |         Classification of COVID-19 in chest X-ray images             |
% |                    using  DeTraC deep network                        |  
% =======================================================================
% Asmaa Abbas Hassan, Mohammed M. Abdelsamea, and Mohamed Medhat Gaber
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This paper presents Decompose, Transfer, and Compose (DeTraC) workflow,
% for the classification of COVID-19 chest X-ray images.
% DeTraCcan deal with any irregularitiesin the image dataset by
% investigating its class boundaries using a class decomposition mechanism.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input :
%        Dataset B ----> [norm_1,norm_2,COVID19_1,COVID19_2, SARS_1,SARS_2]
% Output:
%         evaluation performance for DeTraC model
%         classifier_Accuracy      (ACC)
%         classifier_sensitivity   (SN) 
%         classifier_specifity     (SP)
%         classifier_specifity     (PPV)
%         The Area Under the Curve (ACC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% step 1 : find the network parameters that can be descriminative
%          between the classes.    
%   TP    % No. true positives
%   FP    % No. false positives 
%   FN    % No. false negatives                                 
%   TN    % No. true negatives 

%  Output :
% 'E:\..................\convnet_checkpoint__   .mat') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% step 2 : using the learned features from step 1 to extract the fetures
%          for each class separetly.  

% load the trained checpoint network that can be descriminated between
% the three classes and determine the layer you want to extract the features
% form it.
% load the images within each class individually and store each class
% as an imageDatastore. 
% specify three separeted variables for each class to contain the activations
% features from the ith images.
%

%  Output :
% Check the Evaluation table to get the pre-trained network
% 'E:\..................\convnet_checkpoint__   .mat') 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load image dataset 
% EDIT: hardcoded absolute path to the original author's machine
dataset_A='F:\..............\dataset_A';

% Create an imageDataStore to read images and store image categories
% in corresponding sub-folders.

dataset_A= imageDatastore(dataset_A,'IncludeSubfolders',true,...
           'FileExtensions','.png','LabelSource','foldernames',...
           'ReadFcn',@readAndPreprocessImage);

% display the amount of samples in each class
tbl = countEachLabel(dataset_A)

%% pre_processing 
dataset_A.ReadFcn= @(filename)readAndPreprocessImage(filename);

%% load pre-trained Network
net=alexnet;

% transfer learning all the parameters from the 
% pre-trained network except the classification output
% will be changed into the new task; in our case CXR: 2 classes

layersTransfer = net.Layers(2:end-3);
      
%% construct the new network for the new classification task
% Add new fully connected layer for 2 classes.
 % Add the softmax layer and the classification layer
% and inisiailize Weights and Bias for the new fully connected layer

New_Layers =[...
imageInputLayer([227 227 3],'Name','input')
            layersTransfer
            fullyConnectedLayer(3,'Name','FC_3','WeightL2Factor',1,...
                    'WeightLearnRateFactor',10,'BiasLearnRateFactor',20)
            softmaxLayer('Name','prob')       
            classificationLayer('Name','coutput')
            ];

New_Layers(23).Weights = randn([3 4096]) * 0.0001;
New_Layers(23).Bias = randn([3 1])*0.0001 + 1; 


%% 
% Shuffle files in ImageDatastore
dataset_A = shuffle(dataset_A);

%% devide the dataset into 2 groups: 70% for trainingset and 30% for testset
[trainingimages,testimages]=splitEachLabel(dataset_A,0.7,'randomize');

%%
% hyper parameters for training the network
maxEpochs = 100;
miniBatchSize = 64;
numObservations = numel(trainingimages.Files);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);

opts = trainingOptions('sgdm',...
                    'Initiallearnrate',0.0001,...
                    'Minibatchsize',miniBatchSize,...   
                    'maxEpoch',maxEpochs,...            
                    'L2Regularization',0.001,...        
                    'Shuffle','every-epoch','Momentum',0.9,...
                    'Plots','training-progress','LearnRateSchedule', 'piecewise', ...    
                    'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', 0.9,'LearnRateDropPeriod',3,...
                    % EDIT: hardcoded absolute path to the original author's machine
                    'CheckpointPath' ,'C:\.........\New folder');
                      
%% Train the network using the training set using GPU Hardware 
tic
[trainedNet,traininfo] = trainNetwork(trainingimages,New_Layers,opts);
toc 
% convert the time into DD:HH:MM:SS
elapsed_time= toc;
timeString = datestr(elapsed_time/(24*60*60), 'DD:HH:MM:SS.FFF');
       
%% the classification performance
% load mat.file from CheckpointPath
% EDIT: hardcoded absolute path to the original author's machine
srcFiles_CheckpointPath = dir('C:\.........\New folder','convnet_checkpoint_*.mat');  
noimages=length(srcFiles_CheckpointPath);

for i=1 : noimages

    
     % EDIT: hardcoded absolute path to the original author's machine
     filename = strcat('C:\.........\New folder\',srcFiles_CheckpointPath(i).name);
     load(filename);
     
    % Classify the test images using the fine-tuned network,
    [predictedlabels,scores] = classify(net,testimages);  

    % Evaluation and composition through the error correction equation.
    %compute the confusion matrix 
   
    [cmat,classNames] = confusionmat(testimages.Labels, predictedlabels); 
    cm = confusionchart(cmat,classNames);
    sortClasses(cm,["COVID_19", "SARS","normal"])
    cmat=cm.NormalizedValues;

    %% compute some statistic parameters 
   [acc, sn, sp, p]= ConfusionMat_MultiClass (cmat,classNames);
   
    %% creates a table from the input variables
     Evaluation_Table(i,:) = table({filename},acc, sn, sp, p);
     
       
end
%% 
