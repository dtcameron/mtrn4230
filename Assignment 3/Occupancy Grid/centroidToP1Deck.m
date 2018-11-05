function [deckBlocks, deckP1] = centroidToP1Deck(blockProps)
    %converts a image centroid coordinate from the tabCam to a grid BP in
    %the P1 deck (if youre facing the board from the robot, itll be the
    %right deck!!!!!)
    % INPUTS: blockProps is detected blocks from camera image propcessing
    % OUTPUTS:deckBlocks is a struct containing
%               .desig is an array of deck designations (i.e. '1' '2')
%               .details is an array with the associated
%               characteristics (basically just blockProps without
%               reachability  
%
%             deckP1 is the new 6x1x3 occupancy grid
%               1 is the occupation boolean of the OG grid
%               2 is the type (i.e. shape or letter)
%               3 is the orientation (from -pi/4 to pi/4)

    
    % ------------ CONSTANTS --------------
    % The following are in IMG pixel coords (not local or global frames)
    % [x0 y0] is the top left corner of board 
    % [x1 y1] is the bottom right corner of the baord
    x0 = 420; y0 = 286;
    x1 = 475; y1 = 616;
    blockSpace = 55;
    
    
    %create grid boundaries
    gridX = round(linspace(x0 + blockSpace, x1, 1));
    gridY = round(linspace(y0 + blockSpace, y1, 6));
    
    % take the centroids of the blocks
    centroids = blockProps(:,1:2);
    % kill any out of bounds centroids (i.e. not in the P1 deck)
    ir = find(~(centroids(:,1) < x0 | centroids(:,1) > x1 | centroids(:,2) < y0 | centroids(:,2) > y1));
    oor = centroids(:,1) < x0 | centroids(:,1) > x1 | centroids(:,2) < y0 | centroids(:,2) > y1;
    centroids(oor,:) = [];
    
    %OUTPUT: deckBlocks
    deckBlocks.desig = [];
    deckBlocks.details = [];
    
    %OUTPUT: deckP1
    %1 is the occupation boolean of the P1 grid
    %2 is the type (i.e. shape or letter)
    deckP1 = zeros(6,1,3);
    deckP1(:,:,2) = 2; %invalid type
    deckP1(:,:,3) = NaN; %invalid angle
    
    for i = 1:size(centroids,1)
        ind = ir(i);
        %for each point
        x = blockProps(ind,1);
        y = blockProps(ind,2);
        
        %find where the x,y points lie in the occupancy grid and find it's
        %designation
        xDesig = find(x<gridX, 1);
        yDesig = find(y<gridY, 1);

        %assign attributes to appropriate grid spaces
        deckP1(yDesig,xDesig,1) = 1; %1 is occupied
        deckP1(yDesig,xDesig,2) = blockProps(ind,4); %take the block type
        deckP1(yDesig,xDesig,3) = blockProps(ind,3); %orientation
        
        deckBlocks.desig = [deckBlocks.desig; string(i)];
        deckBlocks.details = [deckBlocks.details; blockProps(ind,1:4)];
    end
    
end