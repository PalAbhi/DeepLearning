function[bwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(im, response, visualize, applyOtsu)
%function[bwCompIm, pureTextIm] = findTextRegionAndTextOnlyImDJW(im, colorIm, response, visualize, applyOtsu)
% by Ashish K L
[maxRow, maxCol] = size(im);

bwCompIm = uint8(zeros(size(im)));
pureTextIm = logical(false(size(im)));
    
thresh = 1.5; % I am not sure of the meaning :-)

bboxes = response.bbox;

for i=1:size(bboxes, 1)
  if bboxes(i,5) > thresh && bboxes(i,3) > 0 && bboxes(i,4) > 0
    if(visualize)
        rectangle('Position', bboxes(i, 1:4), 'EdgeColor', 'g', 'LineWidth', 2);
        %colorIm = insertShape(colorIm, 'Rectangle', bboxes(i, 1:4), 'LineWidth', 2, 'Color','green');
    end
   
    r1 = round(bboxes(i, 2)); c1 = round(bboxes(i, 1));  
    h = round(bboxes(i, 4)); w = round(bboxes(i, 3));  
    r2 = r1+h-1; c2 = c1+w-1;
    if(r2 > maxRow)
        r2 = maxRow;
    end
    if(c2 > maxCol)
        c2 = maxCol;       
    end
    
    bwCompIm(r1:r2, c1:c2) = 1;
    
    croppedGrayIm = im(r1:r2, c1:c2);
    
    if(applyOtsu)            
        level = graythresh(croppedGrayIm);
        croppedBwIm = imbinarize(croppedGrayIm,level);            
        croppedBwRevIm = ~croppedBwIm;
    
        [actualNumComp, ~, fgDivBg, ~] = findActualComp(croppedBwIm);
        [actualNumCompRev, ~, fgDivBgRev, ~] = findActualComp(croppedBwRevIm);
    
        % Try 1 : by reversing the im
        %if(actualNumComp > actualNumCompRev)
        %    selTextPartIm = croppedBwIm;
        %else
        %    selTextPartIm = croppedBwRevIm;
        %end
        if(fgDivBg < 1)
            selTextPartIm = croppedBwIm;
        else
            selTextPartIm = croppedBwRevIm;
        end
    else        
        %Try 2 : by kasar bin
        selTextPartIm =  ~kasar_binarize(croppedGrayIm, 1);
    end
    
    
    existingPart = pureTextIm(r1:r2, c1:c2);
    pureTextIm(r1:r2, c1:c2) = existingPart | selTextPartIm;

  end
end



