function metrics = count2011Sift(sP,pxlSize, p1min,p1max,p2min,p2max,p3min,p3max,ratio,cutoff);

% counts2011Sift selects labelled protein aggregate areas in retinal images
%
% user can select min/max ranges for certain morphological parameters to
% facilitate the detection
%
% STEPS:
% 1) run the program my writing its name with the input parameters in
% brackets
% 2) you will be promped to choose an image for analysis from your computer
% 3) segmented figure with selected aggregates areas labeled with metrics
% will be displayed and saved to disk together with a .MAT file containing all
% metrics and a .TXT file with some of the metrics
%
% SYNOPSIS   metrics = counts2011Sift(#sP)
%
% INPUT      #sP   :    number of strongest SIFT keypoints to be displayed
%
%
% OUTPUT     metrics     :    Features (coordinates, scale, orientation) and descriptors (128-dimentional
% vector)
%
% DEPENDENCES   count2011SIFT uses {Matlab native functions}
%
% example run: metrics = count2011Test;
%
% Alexandre Matov, January 6th, 2023
%%

[fileName,dirName] = uigetfile('*.tif','Julie, please select a TIF file for analysis');
aux1 = imread([dirName,filesep,fileName]);
%aux1 = imread('A:\Amydis\Glaucoma SDEB Eye #2\Bottom\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01\GC 090622-2 Bottom 1 40x 2011 Ab-647 01-Image Export-01_ChS1-T2_ORG.tif');
if nargin==0
        sP = 2; % SIFT strongest points (number)
end
if nargin<2
    pxlSize = 0.09; % microns - was 0.08 but found in my notes 0.09
end
if nargin<6
    p1min = 500; % min area in pixels (default 500)
    p1max = 8000; % max area in pixels (default 8000)
    p2min = 120; % min perimeter around the aggregate (default 120)
    p2max = 400; % max perimeter around the aggregate (dafault 400)
    p3min = 270; % min perimeter around the aggregate (default 6000)
    p3max = 65000; % max perimeter around the aggregate (dafault 20000)
end
if nargin<5
    ratio = 2; % area over the perimeter ratio (default 6.3)
end
if nargin<6
    cutoff = 1.25; % histogram cutoff factor
end

Igray = Gauss2D(double(aux1),1); % filtering of high frequency background noise
Iblur = Gauss2D(double(aux1),4); % filtering of background nonspecific intensity
Idiff = Igray - Iblur; % difference of gaussians
Idiff(find(Idiff<0))=0; % clipping of negative values
%figure, imshow(Igray,[]);
% automated selection of pixels which belong to foreground
[cutoffInd, cutoffV] = cutFirstHistMode(Igray,0);

threshold = cutoffV*cutoff;
%I = rgb2gray(I);
I = Igray>threshold;

X = bwlabel(I.*Igray);
BWoutline = bwperim(X);
Segout = Igray;
Segout(BWoutline) = 65535;
figure,imshow(Segout,[])
title('Aggregates outline contour is displayed in white on the original image');

points = detectSIFTFeatures(aux1);
h=figure, imshow(aux1);
hold on;
plot(points.selectStrongest(sP))
x = round(points.selectStrongest(sP).Location(:,1));
y = round(points.selectStrongest(sP).Location(:,2));
A = (x-1).*size(aux1,2)+y;
stats = regionprops(X,'all'); %
match = struct();
for i = 1:length(stats)
    B = stats(i).PixelIdxList;
    Lia = ismember(A,B); % SIFT,pixelIDlist
    match(i).list = Lia;
    %D=createDistanceMatrix(M,N)
end
hold on
ind = find([match.list]);%find(Lia);


% Open/create text files
    fid=fopen([dirName,fileName(1:end-4),datestr(now, 'dd-mmm-yyyy'),'metricsSIFT.txt'],'a+');
    fprintf(fid,'Selection based on the SIFT detector  \n');
    fprintf(fid,'(the metrics are in square microns for the area and microns for the rest) \n');

for m = 1:length(ind)
    le = length(ind);
    if fix(ind(m)/le)<ind(m)/le
        indStats(m) = fix(ind(m)/le) + 1 ;
    %indStats(m) = (ind(m)-mod(ind(m),le)) /length(ind) + mod(ind(m),le) %cialata chast
    elseif fix(ind(m)/le)==ind(m)/le
        indStats(m) = ind(m)/le ;
    end
    plot(stats(indStats(m)).Centroid(1),stats(indStats(m)).Centroid(2),'r*')
                      text(stats(indStats(m)).Centroid(1)+50,stats(indStats(m)).Centroid(2)+50,[num2str(round(stats(indStats(m)).Area*pxlSize*pxlSize*10)/10)],'Color','r');

 %plot(stats(ind).Centroid(1),stats(ind).Centroid(2),'r*')
 
            fprintf(fid,'----------------------------------------------------------------\n');
            fprintf(fid,' Aggregate area | Aggregate perimeter | Length of major axis');% | MnAx | Eccen | CentI | CentX | CentY \n');
            fprintf(fid,'%6.1f %6.0f %6.0f \n',stats(indStats(m)).Area*pxlSize*pxlSize,stats(indStats(m)).Perimeter*pxlSize,stats(indStats(m)).MajorAxisLength*pxlSize);%,stats(indStats(m)).MinorAxisLength*pxlSize,stats(indStats(m)).Eccentricity, aux1(round(x),round(y)),x,y);

end
hold off
title(['SIFT detections in green (scale shown as circle); hist. segmentation area centroid in red (number in um2)']);
saveas(h,[dirName,fileName(1:end-4),datestr(now, 'dd-mmm-yyyy'),'segmentedAggregatesSIFTdetections.tif']);

 % Close text file
fclose(fid);




% h=figure,imshow(I.*Igray,[]);
% hold on
% for j = 1:length(stats)
%          x=stats(j).Centroid(1);
%         y=stats(j).Centroid(2);
%         %plot(x,y,'b*','LineWidth',5);
%         %aux2 = sum([aux1(stats(j).PixelIdxList)]);
%         aux2 = aux1(round(x),round(y));
%         text(x,y,[num2str(aux2)],'Color','b');
%         if aux2 == 42663824
%             AREA = stats(j).Area
%             PERIMETER = stats(j).Perimeter
%             CENTROID_INT = aux1(round(x),round(y));
% 
%             stats(j)
%         end
%     end
% 
%     centroids = cat(1,stats.Centroid);
%     for i = 1: length(stats)
%         aux3(i)= aux1(round(centroids(i,1)),round(centroids(i,2)));
%     end
%     list = find([stats.Perimeter]>p2min & [stats.Perimeter]<p2max & [stats.Area]>p1min & [stats.Area]<p1max & [aux3]>p3min & [aux3]<p3max);
% 
%     %for i = 1:length(stats)
%     %     x=round(stats(i).Centroid(1));
%     %            y=round(stats(i).Centroid(2));
%     %    if Igray(x,y)>3600
%     %               plot(x,y,'r*','LineWidth',2);
%     %    end
%     %end
%     % PLOTS the segmentation figure with the aggregates
%     metrics = stats(1);%:length(list));
%     %statsAgg=0;
%     k=0;
%     % Open/create text files
%     %fid=fopen([dirName,fileName(1:end-4),datestr(now, 'dd-mmm-yyyy'),'metrics.txt'],'a+');
%     %fprintf(fid,'Selection based on (in microns): \n');
%     %fprintf(fid,' MnAre | MxAre | MnPer | MxPer | Mn Ar/Pe  \n');
%     %fprintf(fid,'%6.0f %6.0f %6.0f %6.0f %6.1f \n',p1min*pxlSize*pxlSize,p1max*pxlSize*pxlSize,p2min*pxlSize,p2max*pxlSize,ratio);
%    % fprintf(fid,' MnInt | MxInt  \n');
%    % fprintf(fid,'%6.0f %6.0f  \n',p3min,p3max);
% 
%     % fprintf(fid,'%6.0 %6.0 %6.0f %6.0f %6.0f %6.0f %6.1f \n',p3min,p3max,p1min*pxlSize*pxlSize,p1max*pxlSize*pxlSize,p2min*pxlSize,p2max*pxlSize,6.3);
% 
%     for i = 1:length(list)
%         if stats(list(i)).Area/stats(list(i)).Perimeter>ratio%6.3%was2%4%7.8
%             k=k+1;
%             x=stats(list(i)).Centroid(1);
%             y=stats(list(i)).Centroid(2);
%             %plot(x,y,'b*','LineWidth',5);
%             text(x+12,y+12,[num2str(round(stats(list(i)).Perimeter*pxlSize))],'Color','r');
%             text(x+50,y+50,[num2str(round(stats(list(i)).Area*pxlSize*pxlSize*10)/10)],'Color','g');
%             text(x+80,y+80,[num2str(aux1(round(x),round(y)))],'Color','y');% display aggregatte centroid intensity
%             %fprintf(fid,'----------------------------------------------------------------\n');
%             %fprintf(fid,' Area | Perim | MjAx | MnAx | Eccen | CentI | CentX | CentY \n');
%             %fprintf(fid,'%6.1f %6.0f %6.0f %6.0f %6.2f %6.0f %6.0f %6.0f\n',stats(list(i)).Area*pxlSize*pxlSize,stats(list(i)).Perimeter*pxlSize,stats(list(i)).MajorAxisLength*pxlSize,stats(list(i)).MinorAxisLength*pxlSize,stats(list(i)).Eccentricity, aux1(round(x),round(y)),x,y);
%             metrics(k)=stats(list(i));
%             %writetable(struct2table(statistics), 'test.xls','sheet',k)
%         end
%     end
%     %fprintf(fid,'----------------------------------------------------------------\n');
%     %fprintf(fid,'The number of detected aggregates is:');
%     %fprintf(fid,'%6.0f\n',k);
%     % Close text file
%     %fclose(fid);
%     %plot(metrics(1).PixelList(1,:),'r*')
%     title([num2str(k),' aggregates; perimeter [um] (red), area [um2] (green), centroid intensity [A.U.] (yellow)']);
%     %save([dirName,fileName(1:end-4),datestr(now, 'dd-mmm-yyyy'),'metrics.mat'],'metrics');
%     hold off
%     %saveas(h,[dirName,fileName(1:end-4),datestr(now, 'dd-mmm-yyyy'),'segmentedAggregates.tif']);
% 
% 
% 
% 
%     %writetable(struct2table(metrics), [dirName,filesep,'metrics.xlsx'])
%     %        goodFeats = find(15<(feats.len));
% 
% 
%     %    featNames = fieldnames(feats);
%     %    for field = 1:length(featNames)
%     %        feats.(featNames{field}) = feats.(featNames{field})(goodFeats,:);
%     %    end