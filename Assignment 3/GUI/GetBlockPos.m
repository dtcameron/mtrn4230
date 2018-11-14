% Pass it the data array and the number you want
% Returns the BPY, BPX or -1 if invalid number
function [iOut, jOut] = GetBlockPos(Num, Data)

    [i, j] = ind2sub(size(Data(:,:,6)), find(Data(:,:,6) == Num));
    if (isempty(i) || isempty(j))
        iOut = -1;
    end
    if (max(size(i)) > 1)
        iOut = i(1,1);
        jOut = j(1,1);
    end
    iOut = i;
    jOut = j;
    return