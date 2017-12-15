%% By saikat
clear;
imtool close all;
addpath('../../CommonFunctions/')
outDir = '../../OutDirAll'
[ s ] = xml2struct( 'TextLineLoc.xml' );
for i = 1:size(s.tagset.image,2)
    fileName = fullfile(outDir,s.tagset.image{1,i}.imageName.Text);
    tempImg = imread(fileName);
    numofRect = size(s.tagset.image{1,i}.taggedRectangles.taggedRectangle,2);
    fh = figure;
    imshow(tempImg,'border', 'tight');
    for j = 1:numofRect
        hold on;
        if(numofRect>1)
            rect = s.tagset.image{1,i}.taggedRectangles.taggedRectangle{1,j}.Attributes;
        else
            rect = s.tagset.image{1,i}.taggedRectangles.taggedRectangle.Attributes;
        end
        rectangle('Position',[str2num(rect.x) str2num(rect.y) str2num(rect.width) str2num(rect.height)],'LineWidth',2,'EdgeColor','g');
    end
    frm = getframe(fh);
    %[path, name, ext] = fileparts(s.tagset.image{1,i}.imageName.Text);
    %imwrite(frm.cdata, [path '/' name '_tagged' ext]);

    close(fh);
end
        