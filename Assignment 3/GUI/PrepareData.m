function DataOut = PrepareData(NumIn, DataIn)
% Prepare the data to be shown in GUI
% 
    if (NumIn == 0)
        DataOut = zeros(NumIn,7);
        return;
    end 
    DataOut = zeros(NumIn,7);
    for i=1:NumIn
        [BPY, BPX] = GetBlockPos(i,DataIn);
        temp = DataIn(BPY, BPX, :);
        DO = zeros(1,7);
        DO(1,1)=i;
        for j=2:5
            DO(1,j) = temp(:,:,j);
        end
        DO(1,4) = rad2deg(DO(1,4));
        DO(1,6) = BPX;
        DO(1,7) = BPY;
        DataOut(i,:) = DO;
    end
    return;
end
