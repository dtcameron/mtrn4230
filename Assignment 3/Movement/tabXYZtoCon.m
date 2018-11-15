function tabXYZtoCon(app, x ,y)
    if isempty(app.boxCentroid)
       disp('FROM XYZtoCon: No box detected');
       return;
    end
    
    coords = imgToGlob([x y], 1);
    coords(3) = coords(3) + fZ;
    tQuat = double([0 0 -1.0 0]);
    
    data = createMovDataString(coords, tQuat);
    initCmd = createCmdString('SM', data);
    
    coords = imgToGlob(app.boxCentroid, 0);
    coords(3) = coords(3) + 60;
    tQuat = double([0 0 -1.0 0]);
            
    data = createMovDataString(coords, tQuat);
    destCmd = createCmdString('SM', data);
    
    % create suction comnands ---------------------------------
    % ---------------------------------------------------------
    sucOnCmd = createCmdString('SS', 'on');
    sucOffCmd = createCmdString('SE', 'off');

    % PUT IT OUT TO QUEUE ------------------------------------
    % --------------------------------------------------------
    app.queue = sendToQueue(app.queue, initCmd);
    app.queue = sendToQueue(app.queue, sucOnCmd);
    app.queue = sendToQueue(app.queue, destCmd);
    app.queue = sendToQueue(app.queue, sucOffCmd);

    
end