clear;
imtool close all;

%%
% add path section 
addpath('../../matconvnet-1.0-beta23/TextAnalysis/CommonFunctions');

load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/icdarImTextAreaDbDJW.mat');
load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/theIcdarTestGTDb.mat');

%%
icdarDir = '../../matconvnet-1.0-beta23/TextAnalysis/ICDAR03/SceneTrialTest/';
%%
numOfFiles =  length(imageTextAreaDbDJW);
    
totalTextAreaSim = 0;
totalTextAreaAcc = 0;
totalTextAreaPre = 0;
totalTextAreaRec = 0;

totalTextAreaDt = 0;
totalTextAreaGt = 0;
wgtTextAreaPre = 0;
wgtTextAreaRec = 0;

totalTime = 0;

for fileIdx = 1:numOfFiles
    fileIdx;
    onlyFileName = imageTextAreaDbDJW{fileIdx, 1};
    completeFileName = fullfile(icdarDir, onlyFileName);
    img = imread(completeFileName);
    [h, w, ~] = size(img);
    %imshow(img);
    
    grayIm = rgb2gray(img);
    boxes = imageTextAreaDbDJW{fileIdx, 2};
    
    [finalBwCompIm] = findTextRegionImDJW(grayIm, boxes, 0);
    bwTextAreaIm = logical(finalBwCompIm);
    %imtool(bwTextAreaIm);
    %imtool(grayIm.*finalBwCompIm);
    
    
    dtTextAreaPIL = findPixelIdxList(bwTextAreaIm);    
    [textAreaSim, textAreaAcc, textAreaPre, textAreaRec, gtTextAreaPIL] = ...
             icdarFindSimilarityMeasure( theTextRegionGTDb, onlyFileName, dtTextAreaPIL);
    
    totalTextAreaSim = totalTextAreaSim + textAreaSim;
    totalTextAreaAcc = totalTextAreaAcc + textAreaAcc;
    totalTextAreaPre = totalTextAreaPre + textAreaPre;
    totalTextAreaRec = totalTextAreaRec + textAreaRec;
            
    totalTime = totalTime + imageTextAreaDbDJW{fileIdx, 3};
    
    %% Weighted calculation
    dtTextAreaPILCount = size(dtTextAreaPIL,2);
    gtTextAreaPILCount = size(gtTextAreaPIL,2);

    % numerator
    wgtTextAreaPre = wgtTextAreaPre + textAreaPre*dtTextAreaPILCount;
    wgtTextAreaRec = wgtTextAreaRec + textAreaRec*gtTextAreaPILCount;
    
    % denominator
    totalTextAreaDt = totalTextAreaDt + dtTextAreaPILCount;
    totalTextAreaGt = totalTextAreaGt + gtTextAreaPILCount;
    imtool close all;
end

%%
avgTextAreaSim = totalTextAreaSim/numOfFiles;
avgTextAreaAcc = totalTextAreaAcc/numOfFiles;
avgTextAreaPre = totalTextAreaPre/numOfFiles;
avgTextAreaRec = totalTextAreaRec/numOfFiles;
avgTextAreaF1s = (2*avgTextAreaPre*avgTextAreaRec)/(avgTextAreaPre+avgTextAreaRec);

avgTime = totalTime/numOfFiles;

resultStr = sprintf('Average      | Acc %f,  Pre %f,  Rec %f,  F1 %f | Time %f', ...
                    avgTextAreaAcc, avgTextAreaPre, avgTextAreaRec, avgTextAreaF1s, avgTime);
disp(resultStr);

%% Weighted Average calculation
wgtAvgTextAreaPre = wgtTextAreaPre/totalTextAreaDt;
wgtAvgTextAreaRec = wgtTextAreaRec/totalTextAreaGt;
wgtAvgTextAreaF1s = (2*wgtAvgTextAreaPre*wgtAvgTextAreaRec)/(wgtAvgTextAreaPre+wgtAvgTextAreaRec);

resultStr = sprintf('Weighted Avg | Acc %f,  Pre %f,  Rec %f,  F1 %f | Time %f', ...
                    avgTextAreaAcc, wgtAvgTextAreaPre, wgtAvgTextAreaRec, wgtAvgTextAreaF1s, avgTime);
disp(resultStr);                 

