function [queue, out] = sendToRobot(queue, socket, error, robotBusy)
%takes the first command on the queue and sends


    if (~error)
        % if there isn't an error, then send the first thing on the queue
        if isempty(queue)
            % if its empty then create a status check string
            queue = [queue string(createCmdString())];
        end

        if ~robotBusy
            % if the robot isnt busy then pop the action off the queue
            % and prep it to be sent
            cmdToSend = queue(1);
            queue(1) = [];
        else
            % if the robot is busy then ping for a status instead
            cmdToSend = createCmdString();
            disp('FROM SENDTOROBOT: Robot is currently busy, status checking')
        end

    else
        % if theres an error, then ping for status
        % otherwise halt hte queue
        cmdToSend = createCmdString();
        disp('FROM SENDTOROBOT: Robot has an error, status check')
    end

    % send and get a response from the robot
    try
        disp('FROM SENDTOROBOT: Message to send:')
        disp(cmdToSend)
        
        out = query(socket, cmdToSend);
        
        disp('FROM SENDTOROBOT: Recieved response')
        X = sprintf('MESSAGE: %s', out);
        disp(X);
        
    catch

        disp('FROM SENDTOROBOT: Socket is FUCKED');
        out = '';

    end

end
