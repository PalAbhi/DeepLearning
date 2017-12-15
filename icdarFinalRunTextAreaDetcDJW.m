clear;
imtool close all;

%%
% add path section 
addpath(genpath('../finetune'));
addpath('../../matconvnet-1.0-beta23/TextAnalysis/CommonFunctions');


%%
% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat

%%
icdarDir = '../../matconvnet-1.0-beta23/TextAnalysis/ICDAR03/SceneTrialTest/';
[ s ] = xml2struct( fullfile(icdarDir,'locations.xml'));
numOfFiles =  size(s.tagset.image,2);


imageTextAreaDbDJW = cell(numOfFiles, 3); % Name, Boxes and Time
   
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);
    
for fileIdx = 1:numOfFiles
    fileIdx
    imInfo = s.tagset.image{1,fileIdx};
    fileName = imInfo.imageName.Text;    
    completeFileName = fullfile(icdarDir, fileName);
    img = imread(completeFileName);
    [h, w, ~] = size(img);
    %imtool(img);
            
    tStart = tic;      
    responses = computeResponses(img, filterStack);
    boxes = findBoxesFull(responses);
    tElapsed = toc(tStart)
    
    imageTextAreaDbDJW{fileIdx, 1} = fileName;
    imageTextAreaDbDJW{fileIdx, 2} = boxes;
    imageTextAreaDbDJW{fileIdx, 3} = tElapsed;
    
    imtool close all;
    procCompIdx = fileIdx; 
end

%%
save('../../matconvnet-1.0-beta23/TextAnalysis/GenData/icdarImTextAreaDbDJW.mat', 'procCompIdx', 'imageTextAreaDbDJW');
