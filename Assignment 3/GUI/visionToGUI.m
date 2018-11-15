function outOG = visionToGUI(OG)
%INPUT: occup, type, theta, x, y, num
%OUTPUT: occup, x, y, theta, type, num

    outOG = zeros(size(OG,1),size(OG,2),6);
    outOG(:,:,1) = OG(:,:,1);
    outOG(:,:,2) = round(OG(:,:,4));
    outOG(:,:,3) = round(OG(:,:,5));
    outOG(:,:,4) = OG(:,:,3);
    outOG(:,:,5) = OG(:,:,2);
    outOG(:,:,6) = OG(:,:,6);
    
end