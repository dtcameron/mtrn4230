function [x,y] = BPtoCoord(boardType, xBP, yBP)
% function BPtoCoord(boardType, xBP, yBP)
%       Takes a BP coordinate pair (i.e. xBP = "1" and yBP = "1") and the
%       corresponding board, and returns the appropirate coordinates (in
%       pixel coordinates)
%       
%       INPUT: string boardType
%           string argument, either 'main', 'P1' or 'P2', whch specify either the
%           decks or the main board
%
%       INPUT: char xBP,yBP
%           char arguments to refer to the BPs i.e. '1','1'  
%
%       OUTPUTS: double x,y 
%           X and Y are the corresponding X and Y coordinates associated
%           with the centre of the BP (in local pixel coordinates)
%

    blockSpace = 55;

    switch boardType
        case 'main'
            x0 = 550; y0 = 286;
            x1 = 1048; y1 = 781;

            gridX = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 9));
            gridY = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 9));
            
            x = gridX(str2double(xBP));
            y = gridY(str2double(yBP));
            
        case 'P1'
            
            x0 = 420; y0 = 286;
            x1 = 475; y1 = 616;
            blockSpace = 55;

            gridX = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 1));
            gridY = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 6));
            
            x = gridX(str2double(xBP));
            y = gridY(str2double(yBP));
            
        case 'P2'
            x0 = 1125; y0 = 288;
            x1 = 1180; y1 = 621;

            gridX = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 1));
            gridY = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 6));
            
            x = gridX(str2double(xBP));
            y = gridY(str2double(yBP));

        otherwise
            fprintf('FROM BPtoCoord: %s is not a valid board type', boardType);
    end
    
end