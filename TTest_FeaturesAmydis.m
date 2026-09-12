cellline = {'Optos','ExVivo','InVivo' };
% EDIT: hardcoded absolute path to the original author's machine
imgroot = 'A:\Amydis\';


bins = [256 128 64 32 16 8];
rates = [1];

method.id = 3;
method.resolution = 6.45/40; 
method.celllevel=1;
method.thresmethod = 'lowcommon';

for i=1:length(cellline)
    dirs = dir([imgroot filesep cellline{i}]);    dirs([1 2]) = [];
    ALL_feats = [];
    for j=1:length(dirs)
        method.procfilesmatname = [pwd filesep 'meta' cellline{i} filesep dirs(j).name filesep 'procfiles.mat'];
        method.resultdir = [pwd filesep 'meta' cellline{i} filesep dirs(j).name];
        method.celllevel=1;
        
        for b=1:1%length(bins)
            for r=1:1%length(rates)
                method.har_intbins = bins(b);   method.downsamplerate = rates(r);
                [this.feat, names, slfnames] = SC_Retrieve_Features(method);
                ALL_feats = [ALL_feats; this.feat];
            end
        end
    end
    if i == 1
        CTL_feats = ALL_feats(1:50,:);% number of images TMK1
        TMK1c = ALL_feats(1:50,:);
        DTX_feats = ALL_feats(53:102,:);
        TMK1d = ALL_feats(53:102,:);
    elseif i == 2
        CTL_feats = ALL_feats(1:29,:);% number of images MKN7
        MKN7c = ALL_feats(1:29,:);
        DTX_feats = ALL_feats(31:59,:);
        MKN7d = ALL_feats(31:59,:);
    elseif i == 5
        CTL_feats = ALL_feats(1:30,:);% number of images MKN45
        MKN45c = ALL_feats(1:30,:);
        DTX_feats = ALL_feats(31:60,:);
        MKN45d = ALL_feats(31:60,:);
    else
        CTL_feats = ALL_feats(1:30,:);% number of images SNU1 or AZ521
        DTX_feats = ALL_feats(31:60,:);
        if i == 3
            AZ521c = ALL_feats(1:30,:);
            AZ521d = ALL_feats(31:60,:);
        elseif i == 4
            SNU1c = ALL_feats(1:30,:);
            SNU1d = ALL_feats(31:60,:);
        elseif i == 6
            SCHc = ALL_feats(1:30,:);
            SCHd = ALL_feats(31:60,:);
        elseif i == 7
            HS746Tc = ALL_feats(1:30,:);
            HS746Td = ALL_feats(31:60,:);
        end
    end
    % keyboard
%     p2 = zeros(21,200);
%     for j = 1 : 200

% % FIND IF ITS UP OR DOWN - 21 features - 21 values
% TMK1ch =  sign(median(TMK1c,1) -  median(TMK1d,1))
% MKN7ch =  sign(median(MKN7c,1) -  median(MKN7d,1))
% MKN45ch =  sign(median(MKN45c,1) -  median(MKN45d,1))
% AZ521ch =  sign(median(AZ521c,1) -  median(AZ521d,1))
% SNU1ch =  sign(median(SNU1c,1) -  median(SNU1d,1))
% SCHch =  sign(median(SCHc,1) -  median(SCHd,1))
% HS746Tch =  sign(median(HS746Tc,1) -  median(HS746Td,1))
 
 




    [H, p] = ttest(CTL_feats, DTX_feats, 0.01);
%     p = p*21% Correction by the number of features
%     p2(:,j) = p1';
%     end
%     p = mean (p2,2);
    %     figure, boxplot([CTL_feats(:,1)/1000,DTX_feats(:,1)/1000,CTL_feats(:,2)/10000000,DTX_feats(:,2)/10000000,CTL_feats(:,3)/10000,DTX_feats(:,3)/10000,...
    %         CTL_feats(:,4)*10,DTX_feats(:,4)*10,...
    %         CTL_feats(:,5)*5,DTX_feats(:,5)*5,CTL_feats(:,6),DTX_feats(:,6),...
    %         CTL_feats(:,8)*10,DTX_feats(:,8)*10,...
    %         CTL_feats(:,9)/100,DTX_feats(:,9)/100,...
    %         CTL_feats(:,13)*100,DTX_feats(:,13)*100],'notch','on','whisker',1.5,  ...
    %     'widths', 0.8, 'labels', {'1','1D', '2','2D','3','3D','4','4D',...
    %     '5','5D','6','6D','8','8D','9','9D','13','13D', },...
    %      'positions' , [ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35])
    %    ylim([-1 15])
    % ylabel('13 Feat of MT Texture After 100nM DTX');
    % title(cellline{i})
    
%     figure, boxplot([CTL_feats(:,1)/1000,DTX_feats(:,1)/1000,CTL_feats(:,2)/10000000,DTX_feats(:,2)/10000000,CTL_feats(:,3)/10000,DTX_feats(:,3)/10000,...
%         CTL_feats(:,4)/1000,DTX_feats(:,4)/1000,...
%         CTL_feats(:,5)/1000,DTX_feats(:,5)/1000,CTL_feats(:,6),DTX_feats(:,6),...
%         CTL_feats(:,7)*5,DTX_feats(:,7)*5,CTL_feats(:,8)*10,DTX_feats(:,8)*10,...
%         CTL_feats(:,9)/100,DTX_feats(:,9)/100,...
%         CTL_feats(:,10),DTX_feats(:,10),...
%         CTL_feats(:,11)/20,DTX_feats(:,11)/20,...
%         CTL_feats(:,12),DTX_feats(:,12),...
%         CTL_feats(:,13),DTX_feats(:,13)],'notch','on','whisker',1.5,  ...
%         'widths', 0.8, 'labels', {'1','1D', '2','2D','3','3D','4','4D',...
%         '5','5D','6','6D','7','7D','8','8D','9','9D','10','10D','11','11D','12','12D','13','13D', },...
%         'positions' , [ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47, 49, 51])
% %     ylim([-1 3])
%     ylabel('13 Feat of MT Texture After 100nM DTX');
%     title(cellline{i})
%     
%      figure, boxplot([CTL_feats(:,14)/1000,DTX_feats(:,14)/1000,CTL_feats(:,15)/10000000,DTX_feats(:,15)/10000000,CTL_feats(:,16)/10000,DTX_feats(:,16)/10000,...
%         CTL_feats(:,17)*10,DTX_feats(:,17)*10,...
%         CTL_feats(:,18)*5,DTX_feats(:,18)*5,CTL_feats(:,19),DTX_feats(:,19),...
%         CTL_feats(:,20)*5,DTX_feats(:,20)*5,CTL_feats(:,21)*10,DTX_feats(:,21)*10],'notch','on','whisker',1.5,  ...
%         'widths', 0.8, 'labels', {'14','14D', '15','15D','16','16D','17','17D',...
%         '18','18D','19','19D','20','20D','21','21D'},...
%         'positions' , [ 1, 3, 5, 7, 9, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31])
% %     ylim([-1 15])
%     ylabel('8 (#14-21) Feat of MT Texture After 100nM DTX');
%     title(cellline{i})
    
    fileName = [cellline{i} '_CTL_vs_DTX__FULL_SET_T-Test.txt'];
    fid = fopen(fileName ,'w');
    fprintf(fid, '%s\n', ['Cell Line:' cellline{i}]);
    fprintf(fid, 'FeatureName\tp<0.01\tp\n');
    for f_idx = 1:length(names)
        fprintf(fid, '%s\t%d\t%.4f\n', names{f_idx}, H(f_idx), p(f_idx));
    end
    fclose(fid);
    fprintf(1, [fileName ' is created.\n']);
end

% PLOT ONLY CONTROL/UNTREATED 30, 30, 29, 50, 30, 30, 31
aux(1:21)=nan;
data=zeros(21,6);
li = [2,3,4,5,6,7,9,10,11,12,13,14,15,19,20,21];
for i = 1:21
    
      strg=sprintf('%%.%dd',2);
    indxStr=sprintf(strg,i);
    
    SC = [SCHc(:,i);aux(1:end-1)'];
    H= [HS746Tc(:,i);aux(1:end-1)'];
    M=[MKN7c(:,i);aux(1:end)'];
    SN = [SNU1c(:,i);aux(1:end-1)'];
    A = [AZ521c(:,i);aux(1:end-1)'];
    M4 = [ MKN45c(:,i); aux(1:end-1)'];
    
    mSc = mean(SCHc(:,i));
    mH=mean(HS746Tc(:,i));
      mM=mean(MKN7c(:,i)); 
      mSN=mean(SNU1c(:,i));
      mA=mean(AZ521c(:,i));
      mT=mean(TMK1c(:,i));
      
         dSc = mean(SCHd(:,i));
    dH=mean(HS746Td(:,i));
      dM=mean(MKN7d(:,i)); 
      dSN=mean(SNU1d(:,i));
      dA=mean(AZ521d(:,i));
      dT=mean(TMK1d(:,i));
      
      data(i,:) = [mSN-dSN,mT-dT,mA-dA,mM-dM,mSc-dSc,mH-dH];
      
%     figure, boxplot([ SC, H, M ,TMK1c(:,i), SN , A ,M4],'notch','on','whisker',1.5,  ...
%         'widths', 0.8, 'labels', {'SCH','HS746T','MKN7','TMK1','SNU1','AZ521','MKN45'},...
%         'positions' , [ 1, 3, 5, 7, 9, 11, 13 ])
    %    ylim([-1 15])
%     ylabel('All 7 cell lines, untreated');
%     title(['Feature number ',indxStr ])
    clear SC,H,M,SN,A,M4;
        SC = [SCHd(:,i);aux(1:end-1)'];
    H= [HS746Td(:,i);aux(1:end-1)'];
    M=[MKN7d(:,i);aux(1:end)'];
    SN = [SNU1d(:,i);aux(1:end-1)'];
    A = [AZ521d(:,i);aux(1:end-1)'];
    M4 = [ MKN45d(:,i); aux(1:end-1)'];
%     figure, boxplot([ SC, H, M ,TMK1d(:,i), SN , A ,M4],'notch','on','whisker',1.5,  ...
%         'widths', 0.8, 'labels', {'SCH','HS746T','MKN7','TMK1','SNU1','AZ521','MKN45'},...
%         'positions' , [ 1, 3, 5, 7, 9, 11, 13 ])
    %    ylim([-1 15])
    ylabel('All 7 cell lines, 100nM DTX');
    title(['Feature number ',indxStr ])
    
end 
li = [2,3,4,5,6,7,9,10,11,12,13,14,15,19,20,21];

HeatMap(data)
