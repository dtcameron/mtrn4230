function outData = visionToGUITable(Data)
%INPUT: x, y, theta, type, reachability, num
%OUTPUT: occup, x, y, theta, type, num

    outData = zeros(size(Data,1),size(Data,2));
    outData(:,1) = 1;
    outData(:,2) = Data(:,1);
    outData(:,3) = round(Data(:,2));
    outData(:,4) = round(Data(:,3));
    outData(:,5) = Data(:,4);
    outData(:,6) = Data(:,6);
    
end