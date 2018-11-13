function [boardBlocks, OG, ir] = centroidToBoardBP(blockProps)
%     converts a image coordinate from the tabCam to a grid BP in the 9x9
%     grid
%
%     INPUTS: blockProps is detected blocks from camera image propcessing
%     
%     OUTPUTS: boardBlocks is a struct containing
%               .desig is an array of block grid designations (i.e. 'A5')
%               .details is an array with the associated
%               characteristics (basically just blockProps without
%               reachability
%         
%              OG is the new 9x9x6 occupancy grid
%                 1 is the occupation boolean of the OG grid
%                 2 is the type (i.e. shape or letter)
%                 3 is the orientation (from -pi/4 to pi/4)
%                 4 is the x centroid
%                 5 is the y centroid
%                 6 is an index for listing

    
    % ------------ CONSTANTS --------------
    % The following are in IMG pixel coords (not local or global frames)
    % [x0 y0] is the top left corner of board 
    % [x1 y1] is the bottom right corner of the baord
    x0 = 550; y0 = 286;
    x1 = 1048; y1 = 781;
    blockSpace = 55;
    
    %create grid boundaries
    gridX = round(linspace(x0 + blockSpace, x1, 9));
    gridY = round(linspace(y0 + blockSpace, y1, 9));
    
    %centers of blocks for checking in case of overlap
%     centreX = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 9));
%     centreY = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 9));
    
    %array of grid letters
    %gridXDesig = ["A","B","C","D","E","F","G","H","I"];
    gridXDesig = ["1","2","3","4","5","6","7","8","9"];
    gridYDesig = ["1","2","3","4","5","6","7","8","9"];
        
    % take the centroids of the blocks
    centroids = blockProps(:,1:2);
    %kill any out of bounds centroids while remmebering hte inrange ones
    ir = find(~(centroids(:,1) < x0 | centroids(:,1) > x1 | centroids(:,2) < y0 | centroids(:,2) > y1));
    oor = centroids(:,1) < x0 | centroids(:,1) > x1 | centroids(:,2) < y0 | centroids(:,2) > y1;
    centroids(oor,:) = [];
    
    %OUTPUT: blocksDesig
    boardBlocks.desig = [];
    boardBlocks.details = [];
    
    %OUTPUT: OG
    %1 is the occupation boolean of the OG grid
    %2 is the type (i.e. shape or letter)
    OG = NaN(9,9,6);
    
    % out index hack
    outInd = 1;
        
    for i = 1:size(centroids,1)
        % remember the saved indexes
        ind = ir(i);
        %for each point
        x = blockProps(ind,1);
        y = blockProps(ind,2);
        
        %find where the x,y points lie in the occupancy grid and find it's
        %designation
        xDesig = find(x<gridX, 1);
        yDesig = find(y<gridY, 1);
        gridDesig = strcat(gridXDesig(xDesig), gridYDesig(yDesig));
        
        % if the position is already occupied don't replace it (outIndex hack)
        if (OG(yDesig,xDesig,1) == 1)
            continue;
        end

        %assign attributes to appropriate grid spaces
        OG(yDesig,xDesig,1) = 1; %1 is occupied
        OG(yDesig,xDesig,2) = blockProps(ind,4); %take the block type
        OG(yDesig,xDesig,3) = blockProps(ind,3); %orientation
        OG(yDesig,xDesig,4) = blockProps(ind,1); %x
        OG(yDesig,xDesig,5) = blockProps(ind,2); %y
        OG(yDesig,xDesig,6) = outInd; %index
        
        %populate the list of grid designations
        boardBlocks.desig = [boardBlocks.desig; gridDesig];
        boardBlocks.details = [boardBlocks.details; blockProps(ind,[1:4 6])]; %everything except reach
        outInd = outInd + 1;
    end
    
    
    
end