clear;

outDir = '../../OutDirAll/';
allFiles = dir( outDir );
allNames = { allFiles.name }; %% all files & dir

files = {allFiles(~[allFiles.isdir]).name}; %% all files
fileCount = size({allFiles(~[allFiles.isdir]).name}, 2); %% all files count

for fileIndex= 1:fileCount
    fileIndex
    onlyFileName = files{fileIndex};    
    fileName = fullfile(outDir, onlyFileName);
    
    im = imread(fileName);

    im = ~im;
    imwrite(im, fileName, 'tiff'); 
end    
