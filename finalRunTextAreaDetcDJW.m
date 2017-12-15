clear;
imtool close all;

%%
% add path section 
addpath(genpath('../finetune'));
addpath('../../matconvnet-1.0-beta23/TextAnalysis/CommonFunctions');

%%
datasetDir = '../../matconvnet-1.0-beta23/TextAnalysis/ChennaiDBAnalysis/OnlyTextImages/TextSelected/';

%%
% load first layer features
load models/detectorCentroids_96.mat
% load detector model
load models/CNN-B64.mat

%%
[ s ] = xml2struct( 'AbsoluteTextMarkedRegion.xml' );
numOfFiles =  size(s.tagset.image,2);
imageTextAreaDbDJW = cell(numOfFiles, 3); % Name, Boxes and Time
   
filterStack = cstackToFilterStack(params, netconfig, centroids, P, M, [2,2,64]);
    
for fileIdx = 1:numOfFiles
    fileIdx
    imInfo = s.tagset.image{1,fileIdx};
    fileName = imInfo.imageName.Text;
    onlyFileName = strrep(fileName,'./FinalDataset/','');
    completeFileName = fullfile(datasetDir, onlyFileName);
    img = imread(completeFileName);
    [h, w, ~] = size(img);
    %imtool(img);
    
    scales = [1.2,1,0.8]; 
    
    tStart = tic;   
    responses = computeResponses(img, filterStack, scales);
    boxes = findBoxesFull(responses, scales);
    
    %responses = computeResponses(img, filterStack);
    %boxes = findBoxesFull(responses);
    
    tElapsed = toc(tStart);
    
    imageTextAreaDbDJW{fileIdx, 1} = onlyFileName;
    imageTextAreaDbDJW{fileIdx, 2} = boxes;
    imageTextAreaDbDJW{fileIdx, 3} = tElapsed;
    
    imtool close all;
end

%%
save('../../matconvnet-1.0-beta23/TextAnalysis/GenData/imageTextAreaDbDJWS1_2and1and_8corr.mat', 'imageTextAreaDbDJW');

