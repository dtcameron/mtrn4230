function [BPX, BPY] = nextAvailBlock(boardType, boardOG)
    BPX = -1;
    BPY = -1;
    switch boardType
        case 'main'
           [freeY, freeX]  = find(~isnan(boardOG));
           if (~isempty(freeY))
               BPX = freeX(1);
               BPY = freeY(1);
           end
        case 'P1'
           [freeY, freeX]  = find(~isnan(boardOG));
           if (~isempty(freeY))
               BPX = freeX(1);
               BPY = freeY(1);
           end
        case 'P2'
           [freeY, freeX]  = find(~isnan(boardOG));
           if (~isempty(freeY))
               BPX = freeX(1);
               BPY = freeY(1);
           end
        otherwise
            fprintf('FROM BPtoCoord: %s is not a valid board type\n', boardType);
    end
        
end