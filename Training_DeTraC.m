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
%        Dataset B ----> [COVID19_1,COVID19_2, SARS_1,SARS_2,norm_1,norm_2]
% Output:
%         evaluation performance for DeTraC model
%         classifier_Accuracy      (ACC)
%         classifier_sensitivity   (SN) 
%         classifier_specifity     (SP)
%         classifier_specifity     (PPV)
%         The Area Under the Curve (AUC)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load images
% EDIT: hardcoded absolute path to the original author's machine
dataset_B='E:\...............\dataset B';

% Create an imageDataStore to read images and store images categories 
% in corresponding sub-folders.

dataset_B= imageDatastore(dataset_B,'IncludeSubfolders',true,...
    'FileExtensions','.png','LabelSource','foldernames',...
    'ReadFcn',@readAndPreprocessImage);

% display the amount of samples in each class
tbl = countEachLabel(dataset_B)

%% pre_processing 
dataset_B.ReadFcn= @(filename)readAndPreprocessImage(filename);

%% Load a pretrained ResNet network
Img_net=resnet18; 

% convert the list of layers in net.Layers into a layer graph.
lgraph = layerGraph(Img_net);

%% Replace the last learnable layer(fully connected layer) and the final 
% classification layer with new layers adapted to the new data set.
% in our work we have 6 classes

[learnableLayer,classLayer] = findLayersToReplace(lgraph);

% The new fully connected layer
% Add the softmax layer and the classification layer 
% inisiailize Weights and Bias for the new fully connected layer

newLearnableLayer =fullyConnectedLayer(6,'Name','new_FC','WeightL2Factor',1,'WeightLearnRateFactor',10,'BiasLearnRateFactor',20);
newLearnableLayer.Weights= randn([6 512]) * 0.0001;
newLearnableLayer.Bias= randn([6 1])*0.0001 + 1; 

% The new classification layer
newClassLayer =classificationLayer('Name','new_classoutput');

% Replace these new layers within the layers lgraph
lgraph = replaceLayer(lgraph,learnableLayer.Name,newLearnableLayer);
lgraph = replaceLayer(lgraph,classLayer.Name,newClassLayer);

% conncet these new layers within the layers lgraph
layers = lgraph.Layers;
connections = lgraph.Connections;
lgraph = createLgraphUsingConnections(layers,connections);

%% 
% Shuffle files in ImageDatastore
dataset_B = shuffle(dataset_B);

%% devide the dataset into 2 groups: 70% for trainingset and 30% for testset
[imdsTrainingSet,imdsTestSet]=splitEachLabel(dataset_B,0.7,'randomize');


%%
% hyper parameters for training the network
maxEpochs = 100;
miniBatchSize = 64;
numObservations = numel(imdsTrainingSet.Files);
numIterationsPerEpoch = floor(numObservations / miniBatchSize);


opts = trainingOptions('sgdm',...
                    'Initiallearnrate',0.0001,...
                    'Minibatchsize',miniBatchSize,...   
                    'maxEpoch',maxEpochs,...            
                    'L2Regularization',0.0001,...
                    'Shuffle','every-epoch','Momentum',0.95,...
                    'Plots','training-progress','LearnRateSchedule', 'piecewise', ...    
                    'LearnRateSchedule', 'piecewise', 'LearnRateDropFactor', 0.95,'LearnRateDropPeriod',5,...
                    % EDIT: hardcoded absolute path to the original author's machine
                    'CheckpointPath' ,'C:\.....................');
                                      
%% Train the network using the training set using GPU Hardware 
tic
[trainedNet,traininfo] = trainNetwork(imdsTrainingSet,lgraph,opts);
toc 
% convert the time into DD:HH:MM:SS
elapsed_time= toc;
timeString = datestr(elapsed_time/(24*60*60), 'DD:HH:MM:SS.FFF');
  
%%
%
% Classification DeTraC model
% load mat.file from CheckpointPath to evaluate the classification performance
% Classify the testset images using the fine-tuned network,
% net:  the new trained parameters
% Evaluation and composition through the error correction equation.
%compute the confusion matrix

for i=1 : noimages

    
      % EDIT: hardcoded absolute path to the original author's machine
      filename = strcat('C:\.........\New folder\',srcFiles_CheckpointPath(i).name);
      load(filename);
           
      [predictedlabels,scores] = classify(net,imdsTestSet);  
      [cmat,classNames] = confusionmat(imdsTestSet.Labels, predictedlabels); 
      cm = confusionchart(cmat,classNames);
      sortClasses(cm,["Covid19_1","Covid19_2","SARS_1","SARS_2","normal_1","normal_2"])
      cmat=cm.NormalizedValues;
     
      %%  error correction equations
      % CompositionClasses : containes reassembling each sub-classes into the original class
      % K                  : class decomposition factor
      % org_classNames     : original classes in dataset_A before decomposition process 
      
       K=2; 
       CompositionClasses= blockproc(cmat,[k k],@(block_struct) sum(block_struct.data(:)));
       org_classNames= categorical({'Covid','SARS','normal'});
                 
      [acc, sn, sp, ppv]= ConfusionMat_MultiClass (CompositionClasses,org_classNames);
      
       %% creates a table from the input variables
       Evaluation_Table(i,:) = table({filename},acc,sn,sp,ppv);
        
end
                   
%% ********************* plot ROc curve *****************
  
targets=grp2idx(imdsTestSet.Labels);

[X,Y,Threshold,AUCpr] = perfcurve(targets, scores(:,1), 1, 'xCrit', 'fpr', 'yCrit', 'tpr');
plot(X,Y)
xlabel('1-specificity'); ylabel('sensitivity');
title(['ROC analysis for DeTraC-ResNet (AUC: ' num2str(AUCpr) ')'])
save('ROc_ DeTraC-ResNet','X','Y','AUCpr');             
    

