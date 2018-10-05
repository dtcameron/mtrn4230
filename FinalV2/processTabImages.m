function processTabImages(img, VidTabPlot, TabVidAxes)
    % PUT IN VIDEO TICK LOOPS
    %processes the table camera for blocks
    hold(TabVidAxes, 'on');
    set(VidTabPlot(:), 'Visible', 'on')

    alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

    %get the imag stuff

    blocks = detectBlocks(img);

    if(isempty(blocks))
        return;
    end

    centroids = round(blocks(:,1:2));
    orient = blocks(:,3);
    symbol = blocks(:,6);

    %finding the reachable blocks to plot
    reachability = blocks(:,7);
    set(VidTabPlot(2), 'xdata', centroids(find(reachability == 1), 1), 'ydata', centroids(find(reachability == 1), 2));
    set(VidTabPlot(1), 'xdata', centroids(find(reachability == 0), 1), 'ydata', centroids(find(reachability == 0), 2));
    length(symbol)
    for i = 1:length(symbol)
        if (symbol(i) < 1 || symbol(i) > 26)
            symbol(i) = 1;
        end
        % draw the labels of the letters and orient
        letterInd = i + 2;
        oriInd = i + 42;
        set(VidTabPlot(letterInd), 'position', [centroids(i,1) centroids(i, 2)], 'String', alphabet(symbol(i)));
        set(VidTabPlot(oriInd), 'position', [centroids(i,1) centroids(i, 2)], 'String', num2str(orient(i)*180/pi));

        % draw the square
        side(1,:) = centroids(i,:) + 26*[cos(orient(i)) sin(orient(i))];
        side(2,:) = centroids(i,:) - 26*[cos(orient(i)+90) sin(orient(i)+90)];
        side(3,:) = centroids(i,:) - 26*[cos(orient(i)) sin(orient(i))];
        side(4,:) = centroids(i,:) + 26*[cos(orient(i)+90) sin(orient(i)+90)];
        side(5,:) = side(1,:);
        
        sideInd = i + 82;
        set(VidTabPlot(sideInd), 'xdata', side(:,1), 'ydata',side(:,2));
    end
    
    % conveyor camera processing
    hold(TabVidAxes, 'off');

end


