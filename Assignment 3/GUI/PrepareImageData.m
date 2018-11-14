% Prepare the data to be shown in GUI
function DataOut = PrepareImageData(NumIn, DataIn)
    if (NumIn == 0)
        DataOut = zeros(NumIn,3);
        return;
    end
    DataOut = zeros(NumIn,3);
    for i=1:NumIn
        [BPY, BPX] = GetBlockPos(i,DataIn);
        temp = DataIn(BPY, BPX, :);
        DO = zeros(1,3);
        
        for j=2:4
            DO(1,j-1) = temp(:,:,j);
        end

        DataOut(i,:) = DO;
    end
    return;
end
