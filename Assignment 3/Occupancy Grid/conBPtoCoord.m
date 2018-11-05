function [x,y] = conBPtoCoord(conGridX, conGridY, xBP, yBP)
% function BPtoCoord(boardType, xBP, yBP)
%       Takes a BP coordinate pair (i.e. xBP = "1" and yBP = "1") and the
%       corresponding board, and returns the appropirate coordinate
%       
%       INPUT: boardType
%           Can be either 'main', 'P1' or 'P2', whch specify either the
%           decks or the main board

     x = conGridX(str2double(xBP));
     y = conGridY(str2double(yBP));
     
         
end