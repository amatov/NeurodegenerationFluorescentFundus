function metrics = detect2011

% read mean pixel intensity, save .mat output as TXT/XLS (#number of aggregates, etc.), loop over whole TIF
% folder, check if Otsu histogram gives better segmentation, add
% eccentricity as parameter
% 
%
% detect2011 selects labelled protein aggregate areas in retinal images
% 
% user can select min/max ranges for certain morphological parameters to
% facilitate the detection
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose an image for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed and saved to disk together with a TXT file with all
% metrics
%
% SYNOPSIS   metrics = detect2011(p1min,p1max,p2min,p2max,cutoff)
%
% INPUT      p1min   :    lower boundary of parameter one (area)
%            p1max   :    upper boundary of parameter one (area)
%            p2min   :    lower boundary of parameter two (perimeter)
%            p2max   :    upper boundary of parameter two (perimeter)
%            minIn   :    minimal pixel intensity in any aggregate
%            cutoff  :    automated threshold correction
%            
% OUTPUT     metrics     :    The morphology and other metrics for all
% segmented aggregates   
%
% DEPENDENCES   detect2011 uses {Gauss2D, cutFirstHistMode}
%
% example run: metrics = detect2011;
%
% Alexandre Matov, October 19th, 2022

coef = 2;
sigma = 4;
% EDIT: hardcoded absolute path to the original author's machine
I = imread('A:\Amydis\GC01.tif');

    I=double(I);
    aux = Gauss2D(I,1);%1 
    I2 = Gauss2D(I,sigma); %4  
    I3 = aux - I2;
%     I3(find(I3<0))=0; % clipping
    [cutoffInd, cutoffV] = cutFirstHistMode(I2,0);

    I4 = I2>cutoffV*coef; 
figure, imshow(I2,[])
figure, imshow(I4,[])
    X = bwlabel(I4);

    stats = regionprops(X,'all');  
%     warning(warningState)

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

        e1 = [-cos(stats(j).Orientation*pi/180) sin(stats(j).Orientation*pi/180) 0];
        e2 = [sin(stats(j).Orientation*pi/180) cos(stats(j).Orientation*pi/180) 0];
        e3 = [0 0 1];
        Ori = [stats(j).Centroid  0];
        v1 = [-10 10];
        v2 = [-5 5];
        v3 = [0 0];
        [xGrid,yGrid]=arbitraryGrid(e1,e2,e3,Ori,v1,v2,v3);

        Crop(:,:,j) = interp2(I,xGrid,yGrid);
        %         Crop(:,:,j) = interp2(I,xGrid,yGrid,'*linear');

        e1 = [];e2 = [];e3 = []; Ori = []; v1 = []; v2 = []; xGrid = []; yGrid = [];
    end

    Cm = nanmean(Crop,3); % MEAN/REPRESENTATIVE 
    Crop(isnan(Crop))=0;% border effect - some NaN
    Cm1 = bwlabel(Cm);
    statsC = regionprops(Cm1,'all');

%     sC = size(Crop);
%     Cm3d = repmat(Cm,[1,1,size(Crop,3)]);
%     dC = Crop - Cm3d;
%     sqC = dC.^2;
%     ssqC = squeeze(sum(sum(sqC,1),2)); %LIST OF DIFFERENCES AFTER SUBTRACTION

    B = Cm(:); % MEAN EB1
    A = ones(length(B),2); 

    for m = 1:size(Crop,3)
        CR = Crop(:,:,m); 
        A(:,2) = CR(:); % INDIVIDUAL EB1
        goodRows = find(A(:,2) ~= 0 & isfinite(B));
        XX = lscov(A(goodRows,:),B(goodRows));
        RES = B(goodRows) - A(goodRows,:)*XX;
        OUT(m,:) = [mean(RES(:).^2),XX'];
    end

    [Ind,V]=cutFirstHistMode(OUT(:,1),0);% switch to 1 to see HIST

    goodFeats = find(OUT(:,1)<(V*1)); % SPOTS WHICH FIT WELL WITH THE MEAN  

    featNames = fieldnames(feats);
    for field = 1:length(featNames)
        feats.(featNames{field}) = feats.(featNames{field})(goodFeats,:);
    end
 
        
 
        If=Gauss2D(I,1);
        figure, imshow(If(1+aaux:end-aaux,1+aaux:end-aaux),[ ]); 
        title('Scale Space Detection');
        hold on
        NB_FEAT = length(feats.ori)
        for i = 1:length(feats.ori)
            h = quiver(feats.pos(i,1)-aaux,feats.pos(i,2)-aaux,-cos(feats.ori(i)*pi/180),sin(feats.ori(i)*pi/180),3,'r');
            set(h,'LineWidth',2)
        end
% phi = linspace(0,2*pi,50);
%     cosphi = cos(phi);
%     sinphi = sin(phi);
%     
% for k = 1:length(stats) % DONT EXLCLUDE THE SECOND THRESHOLDING YET and does not account for shift / crop 
%         xbar = stats(k).Centroid(1);
%         ybar = stats(k).Centroid(2);
%         e = stats(k).Eccentricity;
%         
%         a = stats(k).MajorAxisLength/2;
%         b = stats(k).MinorAxisLength/2;
%         
%         theta = pi*stats(k).Orientation/180;
%         R = [ cos(theta)   sin(theta)
%             -sin(theta)   cos(theta)];
%         
%         xy = [a*cosphi; b*sinphi];
%         xy = R*xy;
%         
%         x = xy(1,:) + xbar;
%         y = xy(2,:) + ybar;
%         
% 
%             plot(xbar,ybar,'rx','MarkerSize',5,'LineWidth',2);
% 
%         plot(x,y,'r','LineWidth',2);
%     end
%     hold off
        
 
end


