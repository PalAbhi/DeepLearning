clear;
imtool close all;


addpath(genpath('../finetune'));
addpath('../../matconvnet-1.0-beta23/TextAnalysis/CommonFunctions');

load('../../matconvnet-1.0-beta23/TextAnalysis/GenData/theTextGTDb.mat');

% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat
%srcFiles = dir('F:\SceneTextCNN_demo\SceneTextCNN_demo\detectorDemo\models\scene\*.jpg');
%for i=1:length(srcFiles)
    %img = imread('./22.JPG');
    fileName = 'In5.png';
    %dir = '../../matconvnet-1.0-beta23/TextAnalysis/ChennaiDBAnalysis/OnlyTextImages/TextRemaining/';    
    %dir = '../../matconvnet-1.0-beta23/TextAnalysis/ChennaiDBAnalysis/OnlyTextImages/TextSelected/';    
    dir = '~/Ubuntu/Latex/IJDAR2017/Version0.5/RES/';    
    img = imread(fullfile(dir, fileName));
    imshow(img);
    tStart = tic;
    fprintf('Constructing filter stack...\n');
    filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);
    
    %%
    scales = [1.5,1.2:-0.1:0.1];  % orig
    %scales = [1.2:-0.1:0.7];    
    scales = [1.2, 1, 0.8];    
    fprintf('Computing responses...\n');    
    responses = computeResponses(img, filterStack, scales);
    %%
    fprintf('Finding lines...\n');
    boxes = findBoxesFull(responses, scales);
    
    grayIm = rgb2gray(img);
    
    %[finalBwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(grayIm, img, boxes, 1, 1);
    [finalBwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(grayIm, boxes, 1, 1);
    bwTextAreaIm = logical(finalBwCompIm);
    imtool(bwTextAreaIm);
    imtool(grayIm.*finalBwCompIm);
    imtool(pureTextIm);
    maskedRgbImage = bsxfun(@times, img, cast(finalBwCompIm, 'like', img));
    imtool(maskedRgbImage);
  
    %pureTextIm2 = findOnlyTextImUsingKasarBinarize(grayIm, finalBwCompIm, 0);
    %imtool(pureTextIm2);
    
    %% Find similarity
    textAreaPIL = findPixelIdxList(bwTextAreaIm);
    pureTextPIL = findPixelIdxList(pureTextIm);
    [textAreaSim, pureTextSim] = findSimilarityMeasure( theTextGTDb, fileName, textAreaPIL, pureTextPIL)
    
    %%
    tElapsed = toc(tStart);   
%end