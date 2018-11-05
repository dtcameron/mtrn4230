function globalc = imgToGlob(imgc,cam)
    % imgc - x,y coords
    % cam - 1 for table , 0 for conveyor
    % globalc - coord rel to robot

    if size(imgc,2) ~= 2
        imgc = imgc';
    end
    
    load('aTabCameraParam.mat', 'mainCameraParams');
    load('aConCameraParam.mat', 'ConvCameraParams');
    
    globalc = zeros(size(imgc,1),3);

    %% Loading camera params based on which camera was used
    if cam == 1
        parameters = mainCameraParams;
        offs = [175 0 157];
        randpoint = [799 288];
        sc = 1.53;
        ang = 0.75;
    else
        parameters = ConvCameraParams;
        offs = [-36 280 32];
        randpoint = [661 474];
        sc = 1.33;
        ang = 0.5;
    end
    
    ang = -deg2rad(ang);
    Rotm = [cos(ang), -sin(ang), randpoint(1)-(cos(ang)*randpoint(1))+(sin(ang)*randpoint(2)); sin(ang), cos(ang), randpoint(2)-(sin(ang)*randpoint(1))-(cos(ang)*randpoint(2));0 0 1];
    imgc = undistortPoints(imgc,parameters);
    imgc(:,3) = 1;
    temp = Rotm * imgc';
    temp = temp';
    globalc(:,1:2) = [(temp(:,2)-randpoint(2))./sc,(temp(:,1)-randpoint(1))./sc];
    globalc(:,1:3) =globalc(:,1:3) + offs(1:3);

end