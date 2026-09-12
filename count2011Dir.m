function metrics = count2011Dir(pxlSize, p1min,p1max,p2min,p2max,p3min,p3max,minIn,cutoff);

% counts2011Dir selects labelled protein aggregate areas in retinal images
%
% user can select min/max ranges for certain morphological parameters to
% facilitate the detection
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose a folder for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed and saved to disk together with a .MAT file containing all
% metrics and a .TXT file with some of the metrics
%
% SYNOPSIS   metrics = counts2011Dir(p1min,p1max,p2min,p2max,p3min,p3max,cutoff)
%
% INPUT      p1min   :    lower boundary of parameter one (area)
%            p1max   :    upper boundary of parameter one (area)
%            p2min   :    lower boundary of parameter two (perimeter)
%            p2max   :    upper boundary of parameter two (perimeter)
%            p3min   :    lower boundary of parameter three (intensity at
%            centroid)
%            p3max   :    upper boundary of parameter three (intensity at
%            centroid)
%            minIn   :    minimal pixel intensity in any aggregate
%            cutoff  :    automated threshold correction
%            pxlSize :    number of microns per pixel
%
% OUTPUT     metrics     :    The morphology and other metrics for all
% segmented aggregates within the selected directory with its subfolders
%
% DEPENDENCES   count2011Dir uses {Gauss2D, cutFirstHistMode}
%
% example run: metrics = count2011Dir;
%
% Alexandre Matov, November 26th, 2022
%%
if nargin<2
    pxlSize = 0.09; % microns - was 0.08 but found in my notes 0.09
end
if nargin<6
    p1min = 500; % min area in pixels (default 500)
    p1max = 8000; % max area in pixels (default 8000)
    p2min = 120; % min perimeter around the aggregate (default 120)
    p2max = 400; % max perimeter around the aggregate (dafault 400)
    p3min = 1000; % min perimeter around the aggregate (default 6000)
    p3max = 65000; % max perimeter around the aggregate (dafault 20000)
end
if nargin<5
    minIn = 3600; % min pixel intensity in aggregates
end
if nargin<6
    cutoff = 1.25; % histogram cutoff factor
end
PixelSize = 0.09 ; % microns per pixel

%[fileName,dirName] = uigetfile('*.tif','Julie, please select a TIF file for analysis');
% EDIT: hardcoded absolute path to the original author's machine
dirName = uigetdir('C:\');

cd(dirName)
% EDIT: hardcoded absolute path to the original author's machine
rootdir = dirName;%'A:\Amydis\Glaucoma SDEB Eye #2';
filelistT2 = dir(fullfile(rootdir, '**\*T2_ORG.tif'));
filelistT3 = dir(fullfile(rootdir, '**\*T3_ORG.tif'));
nbTif = length(filelistT2)+length(filelistT3);

for i = 1:nbTif
    if i <= length(filelistT3)
        dirName = filelistT3(i).folder;
        fileName = filelistT3(i).name;
    else
        indx = i - length(filelistT3)
        dirName = filelistT2(indx).folder;
        fileName = filelistT2(indx).name;
    end

    aux1 = imread([dirName,filesep,fileName]);

    Igray = Gauss2D(double(aux1),1); % filtering of high frequency background noise
    Iblur = Gauss2D(double(aux1),4); % filtering of background nonspecific intensity
    Idiff = Igray - Iblur; % difference of gaussians
    Idiff(find(Idiff<0))=0; % clipping of negative values
    figure, imshow(Igray,[]);
    % automated selection of pixels which belong to foreground
    [cutoffInd, cutoffV] = cutFirstHistMode(Igray,0);

    threshold = cutoffV*cutoff;
    %I = rgb2gray(I);
    I = Igray>threshold;
    %imshow (I);
    %figure,imshow(I.*Igray,[]);

    %mask = zeros(sw(ize(I));
    %mask(25:end-25,25:end-25) = 1;
    %imshow(mask)
    %title('Initial Contour Location')
    %bw = activecontour(Igray,mask,300);
    %imshow(bw)
    %title('Segmented Image, 300 Iterations')

    X = bwlabel(I.*Igray);
    stats = regionprops(X,'all'); %

    % Initialize 'feats' structure
    feats=struct(...
        'pos',[0 0],...                  % Centroid - [y x]
        'ecc',0,...                      % Eccentricity
        'ori',0);   % Orientation

    h = figure,imshow(I.*Igray,[]);
    hold on
    for j = 1:length(stats)
        feats.pos(j,1) = stats(j).Centroid(1);
        feats.pos(j,2) = stats(j).Centroid(2);
        feats.ecc(j,1) = stats(j).Eccentricity;
        feats.ori(j,1) = stats(j).Orientation;
        feats.len(j,1) = stats(j).MajorAxisLength;
        %aux2 = aux1(round(stats(j).Centroid(1)),round(stats(j).Centroid(2))),
        x=stats(j).Centroid(1);
        y=stats(j).Centroid(2);
        %plot(x,y,'b*','LineWidth',5);
        aux2 = sum([aux1(stats(j).PixelIdxList)]);
        %  text(x,y,[num2str(aux2)],'Color','b');
    end
    %list = find([stats.Area]>1600 & [stats.Area]<1705)
    %list = find(Igray([stats.Centroid])>2000)
    %list = find([stats.Area]>p1min);
    %list = find([stats.MajorAxisLength]>80);
    %x=[stats.Centroid(1)];
    %y=[stats.Centroid(2)];
    centroids = cat(1,stats.Centroid);
    aux3=[];
    for i = 1: length(stats)
        aux3(i)= aux1(round(centroids(i,1)),round(centroids(i,2)));
    end
    list = find([stats.Perimeter]>p2min & [stats.Perimeter]<p2max & [stats.Area]>p1min & [stats.Area]<p1max & [aux3]>p3min & [aux3]<p3max);

    %for i = 1:length(stats)
    %     x=round(stats(i).Centroid(1));
    %            y=round(stats(i).Centroid(2));
    %    if Igray(x,y)>3600
    %               plot(x,y,'r*','LineWidth',2);
    %    end
    %end
    % PLOTS the segmentation figure with the aggregates
    metrics = stats(1);%:length(list));
    %statsAgg=0;
    k=0;
    % Open/create text files
    fid=fopen([dirName,fileName(1:end-4),floor(now),'metrics.txt'],'a+');
    fprintf(fid,'Selection based on (in microns): \n');
    fprintf(fid,' MnAre | MxAre | MnPer | MxPer | Mn Ar/Pe  \n');
    fprintf(fid,'%6.0f %6.0f %6.0f %6.0f %6.1f \n',p1min*pxlSize*pxlSize,p1max*pxlSize*pxlSize,p2min*pxlSize,p2max*pxlSize,6.3);
    fprintf(fid,' MnInt | MxInt  \n');
    fprintf(fid,'%6.0f %6.0f  \n',p3min,p3max);

    % fprintf(fid,'%6.0 %6.0 %6.0f %6.0f %6.0f %6.0f %6.1f \n',p3min,p3max,p1min*pxlSize*pxlSize,p1max*pxlSize*pxlSize,p2min*pxlSize,p2max*pxlSize,6.3);

    for i = 1:length(list)
        if stats(list(i)).Area/stats(list(i)).Perimeter>2%6.3%4%7.8
            k=k+1;
            x=stats(list(i)).Centroid(1);
            y=stats(list(i)).Centroid(2);
            %plot(x,y,'b*','LineWidth',5);
            text(x+12,y+12,[num2str(round(stats(list(i)).Perimeter*pxlSize))],'Color','r');
            text(x+50,y+50,[num2str(round(stats(list(i)).Area*pxlSize*pxlSize*10)/10)],'Color','g');
            text(x+80,y+80,[num2str(aux1(round(x),round(y)))],'Color','y');% display aggregatte centroid intensity
            fprintf(fid,'----------------------------------------------------------------\n');
            fprintf(fid,' Area | Perim | MjAx | MnAx | Eccen | CentI | CentX | CentY \n');
            fprintf(fid,'%6.1f %6.0f %6.0f %6.0f %6.2f %6.0f %6.0f %6.0f\n',stats(list(i)).Area*pxlSize*pxlSize,stats(list(i)).Perimeter*pxlSize,stats(list(i)).MajorAxisLength*pxlSize,stats(list(i)).MinorAxisLength*pxlSize,stats(list(i)).Eccentricity, aux1(round(x),round(y)),x,y);
            metrics(k)=stats(list(i));
            %writetable(struct2table(statistics), 'test.xls','sheet',k)
        end
    end
    fprintf(fid,'----------------------------------------------------------------\n');
    fprintf(fid,'The number of detected aggregates is:');
    fprintf(fid,'%6.0f\n',k);
    % Close text file
    fclose(fid);
    %plot(metrics(1).PixelList(1,:),'r*')
    title([num2str(k),' aggregates detected, perimeter in microns (red), area in square microns (green), centroid intensity in arbitrary units (yellow)']);
    save([dirName,fileName(1:end-4),floor(now),'metrics.mat'],'metrics');
    hold off
    saveas(h,[dirName,fileName(1:end-4),floor(now),'segmentedAggregates.tif']);
    close all
end