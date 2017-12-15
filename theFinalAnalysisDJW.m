clear;
imtool close all;

%%
% add path section 
addpath('../../matconvnet-1.0-beta23/TextAnalysis/CommonFunctions');
load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWFS.mat'); %correct
%load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1.mat');
%load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1_2and1.mat');
%load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1_1and1and_9.mat'); 
%load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1_2and1and_8.mat');%best
%load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1_2and1and_9.mat');
load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/theTextGTDbUpdated.mat');
%%
datasetDir = '../../matconvnet-1.0-beta23/TextAnalysis/ChennaiDBAnalysis/OnlyTextImages/TextSelected/';

%%
numOfFiles =  length(imageTextAreaDbDJW);
    
totalTextAreaSim = 0;
totalTextAreaAcc = 0;
totalTextAreaPre = 0;
totalTextAreaRec = 0;
totalPureTextSim = 0;
totalPureTextAcc = 0;
totalPureTextPre = 0;
totalPureTextRec = 0;

totalTextAreaDt = 0;
totalPureTextDt = 0;
totalTextAreaGt = 0;
totalPureTextGt = 0;
wgtTextAreaPre = 0;
wgtTextAreaRec = 0;
wgtPureTextPre = 0;
wgtPureTextRec = 0;

totalExecTime = 0;
for fileIdx = 1:numOfFiles
    fileIdx;
    onlyFileName = imageTextAreaDbDJW{fileIdx, 1};
    completeFileName = fullfile(datasetDir, onlyFileName);
    img = imread(completeFileName);
    [h, w, ~] = size(img);
    %imshow(img);
    
    grayIm = rgb2gray(img);
    boxes = imageTextAreaDbDJW{fileIdx, 2};
    
    [finalBwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(grayIm, boxes, 0, 1);
    bwTextAreaIm = logical(finalBwCompIm);
    %imtool(bwTextAreaIm);
    %imtool(grayIm.*finalBwCompIm);
    %imtool(pureTextIm);
    
    % Junk - just a try
    %pureTextIm = findOnlyTextImUsingKasarBinarize(grayIm, img, finalBwCompIm, 0);
    
    dtTextAreaPIL = findPixelIdxList(bwTextAreaIm);
    dtPureTextPIL = findPixelIdxList(pureTextIm);
    [textAreaSim, textAreaAcc, textAreaPre, textAreaRec, ...
     pureTextSim, pureTextAcc, pureTextPre, pureTextRec, ...
     gtTextAreaPIL, gtPureTextPIL] = findSimilarityMeasure( theTextGTDb, onlyFileName, dtTextAreaPIL, dtPureTextPIL);
    
    totalTextAreaSim = totalTextAreaSim + textAreaSim;
    totalTextAreaAcc = totalTextAreaAcc + textAreaAcc;
    totalTextAreaPre = totalTextAreaPre + textAreaPre;
    totalTextAreaRec = totalTextAreaRec + textAreaRec;
        
    totalPureTextSim = totalPureTextSim + pureTextSim;
    totalPureTextAcc = totalPureTextAcc + pureTextAcc;
    totalPureTextPre = totalPureTextPre + pureTextPre;
    totalPureTextRec = totalPureTextRec + pureTextRec;
    
    %% Weighted calculation
    dtTextAreaPILCount = size(dtTextAreaPIL,2);
    gtTextAreaPILCount = size(gtTextAreaPIL,2);
    dtPureTextPILCount = size(dtPureTextPIL,2);    
    gtPureTextPILCount = size(gtPureTextPIL,2);

    % numerator
    wgtTextAreaPre = wgtTextAreaPre + textAreaPre*dtTextAreaPILCount;
    wgtTextAreaRec = wgtTextAreaRec + textAreaRec*gtTextAreaPILCount;
    wgtPureTextPre = wgtPureTextPre + pureTextPre*dtPureTextPILCount;
    wgtPureTextRec = wgtPureTextRec + pureTextRec*gtPureTextPILCount;
    
    % denominator
    totalTextAreaDt = totalTextAreaDt + dtTextAreaPILCount;
    totalTextAreaGt = totalTextAreaGt + gtTextAreaPILCount;
    totalPureTextDt = totalPureTextDt + dtPureTextPILCount;
    totalPureTextGt = totalPureTextGt + gtPureTextPILCount;

    totalExecTime = totalExecTime + imageTextAreaDbDJW{fileIdx, 3};
    
    imtool close all;
end

%%

%% Average calculation
avgTextAreaSim = totalTextAreaSim/numOfFiles;
avgTextAreaAcc = 100*totalTextAreaAcc/numOfFiles;
avgTextAreaPre = totalTextAreaPre/numOfFiles;
avgTextAreaRec = totalTextAreaRec/numOfFiles;
avgTextAreaF1s = (2*avgTextAreaPre*avgTextAreaRec)/(avgTextAreaPre+avgTextAreaRec);

avgPureTextSim = totalPureTextSim/numOfFiles;
avgPureTextAcc = 100*totalPureTextAcc/numOfFiles;
avgPureTextPre = totalPureTextPre/numOfFiles;
avgPureTextRec = totalPureTextRec/numOfFiles;
avgPureTextF1s = (2*avgPureTextPre*avgPureTextRec)/(avgPureTextPre+avgPureTextRec);

avgTime = totalExecTime/numOfFiles;

resultStr = sprintf('Average      | Acc %f,  Pre %f,  Rec %f,  F1 %f | Acc %f,  Pre %f,  Rec %f,  F1 %f | Time %f', ...
                    avgTextAreaAcc, avgTextAreaPre, avgTextAreaRec, avgTextAreaF1s, ...
                    avgPureTextAcc, avgPureTextPre, avgPureTextRec, avgPureTextF1s, avgTime);                                
disp(resultStr);

%% Weighted Average calculation
wgtAvgTextAreaPre = wgtTextAreaPre/totalTextAreaDt;
wgtAvgTextAreaRec = wgtTextAreaRec/totalTextAreaGt;
wgtAvgTextAreaF1s = (2*wgtAvgTextAreaPre*wgtAvgTextAreaRec)/(wgtAvgTextAreaPre+wgtAvgTextAreaRec);

wgtAvgPureTextPre = wgtPureTextPre/totalPureTextDt;
wgtAvgPureTextRec = wgtPureTextRec/totalPureTextGt;
wgtAvgPureTextF1s = (2*wgtAvgPureTextPre*wgtAvgPureTextRec)/(wgtAvgPureTextPre+wgtAvgPureTextRec);

resultStr = sprintf('Weighted Avg | Acc %f,  Pre %f,  Rec %f,  F1 %f | Acc %f,  Pre %f,  Rec %f,  F1 %f | Time %f', ...
                    avgTextAreaAcc, wgtAvgTextAreaPre, wgtAvgTextAreaRec, wgtAvgTextAreaF1s, ...
                    avgPureTextAcc, wgtAvgPureTextPre, wgtAvgPureTextRec, wgtAvgPureTextF1s, avgTime); 
disp(resultStr);                 

