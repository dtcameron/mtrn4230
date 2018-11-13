function processConImages(conImg, ConVidPlot, ConVidAxes)
    set(ConVidPlot(:), 'Visible', 'on');
    hold(ConVidAxes, 'on');
    
    %converyer ROI is in x 520 to 1220, y 0 to 700
    conImg(700:end, :) = 0;
    conImg(:, 1:520,:) = 0;
    conImg(:, 1220:end ,:) = 0;
    
    BWconImg = boxFilt(conImg);
    BWconImg = imfill(BWconImg, 'holes');
    BWconImg = imerode(BWconImg, ones(10));
    
   edgey = edge(BWconImg, 'canny');
   edgey = imdilate(edgey, ones(3));
    
    boxCentroid = regionprops('table', BWconImg, 'Centroid', 'Area');
    [~, ind] = max(boxCentroid.Area);
    centroid = boxCentroid.Centroid(ind,:);
    
    [H, T, R] = hough(edgey);
    peaks = houghpeaks(H, 4);
    lines = houghlines(edgey, T, R, peaks, 'MinLength', 20);
    angle = lines(2).theta;
    for i = 1:size(lines,2)
        if i == 5
            break
        end
        xy = [lines(i).point1; lines(i).point2];
        set(ConVidPlot(i), 'xdata', xy(:,1), 'ydata', xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
    
    set(ConVidPlot(5), 'position', [centroid(1), centroid(2)], 'String', num2str(angle));
    
    hold(ConVidAxes, 'off');
    
end