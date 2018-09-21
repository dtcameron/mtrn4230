function processTabImages(img, VidTabPlot, TabVidAxes)
    % PUT IN VIDEO TICK LOOPS
    %processes the table camera for blocks
    hold(TabVidAxes, 'on');
    disp('A');
    set(VidTabPlot(:), 'Visible', 'on')
    disp('B');

    alphabet = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

    %get the imag stuff
    blocks = detectBlocks(img);
    disp('C');

    if(isempty(blocks))
        return;
    end
    disp('D');

    centroids = round(blocks(:,1:2));
    orient = blocks(:,3);
    symbol = blocks(:,6);
    disp('E');

    %finding the reachable blocks to plot
    reachability = blocks(:,7);
    set(VidTabPlot(2), 'xdata', centroids(find(reachability == 1), 1), 'ydata', centroids(find(reachability == 1), 2));
    set(VidTabPlot(1), 'xdata', centroids(find(reachability == 0), 1), 'ydata', centroids(find(reachability == 0), 2));
    disp('F');

    for i = 1:length(symbol)
        if (symbol(i) < 0 || symbol > 26)
            symbol(i) = 1;
        end
        
        % draw the labels of the letters and orient
        set(VidTabPlot(i+2), 'position', [centroids(i,1)+60 centroids(i, 2)], 'String', alphabet(symbol(i)));
        set(VidTabPlot(i+42), 'position', [centroids(i,1)+120 centroids(i, 2)], 'String', num2str(orient(i)*180/pi));
        
        % draw the square
        side(1,:) = centroids(i,:) + 26*[cos(orient(i)) sin(orient(i))];
        side(2,:) = centroids(i,:) - 26*[cos(orient(i)+90) sin(orient(i)+90)];
        side(3,:) = centroids(i,:) - 26*[cos(orient(i)) sin(orient(i))];
        side(4,:) = centroids(i,:) + 26*[cos(orient(i)+90) sin(orient(i)+90)];
        side(5,:) = side(1,:);
        
        set(VidTabPlot(i+82), 'xdata', side(:,1), 'ydata',side(:,2));
    end
    
    % conveyor camera processing
    hold(TabVidAxes, 'off');

end


