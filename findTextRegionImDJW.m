function[bwCompIm] = findTextRegionImDJW(im, response, visualize)
% by Ashish K L
[maxRow, maxCol] = size(im);

bwCompIm = uint8(zeros(size(im)));

    
thresh = 1.5; % I am not sure of the meaning :-)

bboxes = response.bbox;

for i=1:size(bboxes, 1)
  if bboxes(i,5) > thresh && bboxes(i,3) > 0 && bboxes(i,4) > 0
    if(visualize)
        rectangle('Position', bboxes(i, 1:4), 'EdgeColor', 'g', 'LineWidth', 2);
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

  end
end
end



