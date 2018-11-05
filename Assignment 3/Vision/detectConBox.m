function [lines, conGridX, conGridY] = detectConBox(conImg)
%   function detectConBox(conImg):
%       Used during image processing, and the outputs are used for loading
%       back into the box. Please be advised that for that step to work its
%       advised that the box be portrait orientated, i.e. |, not -
%
%       INPUTS: conImg
%               a 1600 x 1200 x 3 RGB image taken from the conCamera
%
%       OUPUTS: lines
%               hough transform lines used for debugging
%               
%               conGridX, conGridY
%               double array that represents the two axes of a grid used
%               for BPs

    %converyer ROI is in x 520 to 1220, y 0 to 700
    conImg(700:end, :) = 0;
    conImg(:, 1:600,:) = 0;
    conImg(:, 1160:end ,:) = 0;
    
    BWconImg = boxFilt(conImg);
    BWconImg = imdilate(BWconImg, ones(10));
    BWconImg = imfill(BWconImg, 'holes');
    
    BWconImg = imerode(BWconImg, ones(12));
    
    edgey = edge(BWconImg, 'canny');
    edgey = imdilate(edgey, ones(3));
    
%     boxCentroid = regionprops('table', BWconImg, 'Centroid', 'Area');
%     [~, ind] = max(boxCentroid.Area);
%     centroid = boxCentroid.Centroid(ind,:);
    
    [H, T, R] = hough(edgey);
    peaks = houghpeaks(H, 2);
    lines = houghlines(edgey, T, R, peaks, 'MinLength', 20);
    
    gridX = linspace(lines(1).point1(1), lines(2).point1(1), 5);
    conGridX = gridX(2:end-1);
    conGridY = linspace(lines(1).point1(2), lines(1).point2(2), 5);
        
end