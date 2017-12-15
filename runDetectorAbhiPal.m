addpath('../../CommonFunctions');
addpath(genpath('../finetune'));


% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat
%srcFiles = dir('F:\SceneTextCNN_demo\SceneTextCNN_demo\detectorDemo\models\scene\*.jpg');
%for i=1:length(srcFiles)
    img = imread('../../ChennaiDBAnalysis/OnlyTextImages/TextSelected/CVcp0XAU4AA7kOO.jpg');
  
    imshow(img);
    tStart = tic;
    fprintf('Constructing filter stack...\n');
    filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);
    
    scales = [1.2, 1, 0.8]; 
    
    fprintf('Computing responses...\n');
    responses = computeResponses(img, filterStack, scales);
    %%
    fprintf('Finding lines...\n');
    boxes = findBoxesFull(responses, scales);
    
    visualizeBoxes(img, boxes);
    grayIm = rgb2gray(img);
    [finalBwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(grayIm, boxes, 0, 1);
    bwTextAreaIm = logical(finalBwCompIm);
    imtool(pureTextIm);
    imwrite(pureTextIm,'1bin.tiff','tiff'); 
    txt = ocr(pureTextIm);
    disp(txt.Text);

    
    [h1] = HProj(pureTextIm);
    [h] = HProj2image(h1, pureTextIm);
    
    
 tElapsed = toc(tStart)