clear;
addpath('../../CommonFunctions');
addpath(genpath('../finetune'));


% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat

datasetDir = '../../ChennaiDBAnalysis/OnlyTextImages/AllTextIm/';
outDir = '../../OutDirAll/';
allFiles = dir( datasetDir );
allNames = { allFiles.name }; %% all files & dir

files = {allFiles(~[allFiles.isdir]).name}; %% all files
fileCount = size({allFiles(~[allFiles.isdir]).name}, 2); %% all files count

%currFileIndex = 1;
%save('currFileIndex.mat', 'currFileIndex');
load('currFileIndex.mat');
for fileIndex= currFileIndex:fileCount
    fileIndex
    onlyFileName = files{fileIndex};    
    fileName = fullfile(datasetDir, onlyFileName);

    fileNameWOExtn = strrep(onlyFileName,'.jpg', '');
    fileNameWOExtn = strrep(fileNameWOExtn,'.png', '');
    onlyOutFileName = strcat(fileNameWOExtn,'.tiff');
    outFileName = fullfile(outDir, onlyOutFileName);

    img = imread(fileName);
    
    fprintf('Constructing filter stack...\n');
    filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);
    
    scales = [1.2, 1, 0.8]; 
    
    fprintf('Computing responses...\n');
    responses = computeResponses(img, filterStack, scales);
    %%
    fprintf('Finding lines...\n');
    boxes = findBoxesFull(responses, scales);
    
    fpW=fopen('TextLineLoc.xml','a');
    captureTextLinesInXml(fpW, onlyOutFileName, img, boxes);
    fclose(fpW);

    
    %visualizeBoxes(img, boxes);
    grayIm = rgb2gray(img);
    [finalBwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(grayIm, boxes, 0, 1);
    bwTextAreaIm = logical(finalBwCompIm);
    %imtool(pureTextIm);
    
    imwrite(~pureTextIm, outFileName, 'tiff'); 
    currFileIndex = fileIndex+1;
    save('currFileIndex.mat', 'currFileIndex');
end    
