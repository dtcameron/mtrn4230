% Pass it the data array and the number you want
% Returns the BPY, BPX or -1 if invalid number
function [i] = GetTablePos(Num, Data)

    [i, j] = ind2sub(size(Data(:,6)), find(Data(:,6) == Num));
    
    if (isempty(i))
        i = -1;
    end
    return