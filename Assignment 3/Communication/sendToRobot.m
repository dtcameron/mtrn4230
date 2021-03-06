function [queue, out, sockError] = sendToRobot(queue, socket, genError, robotBusy)
% function [queue, out, sockError] = sendToRobot(queue, socket, genError, robotBusy)
%   Takes the first command on the queue and sends it out to the robot,
%   waits for a reply
%
%       INPUTS:
%       queue
%           An array of strings used for storing queue cmd strings. One
%           gets popped off and sent 
%
%       socket
%           MATLAB socket object made by startConnectionToRobot(), TCPIP
%
%       genError
%           A  binary flag indicating whether there is an error such as emergency
%           stops, motors, lightcutrain (general) and so on. If on, it will 
%           prevent his function from sending out any movement commands
%
%       robotBusy
%           Binary flag reciveed from RS indicating whether the robot is in the
%           middle of a movement command.
%
%
%       OUTPUTS:
%       queue:
%           The same as input, but will have the first item removed 
%
%       out:
%           A string message recieved from robotStudio
%
%       sockError:
%           A flag set if there has been a communications error

    % Check if the socket is still open
    if(~isequal(get(socket, 'Status'), 'open'))
        sockError = 1;
        out = 'B|';
        disp('FROM MAIN: Socket Error')
    else
        sockError = 0;
    end

    % If no comm errors or general errors, then get a cmd string
    if (~genError) && (~sockError)
        if ~robotBusy
            if isempty(queue)
            % if its empty then add a statusCheck onto the queue
                queue = [queue string(createCmdString())];
            end
            
            % if the robot isnt busy then pop the queue
            cmdToSend = queue(1);
            queue(1) = [];
        else
            % if the robot is busy then ping for a status instead, halting
            % the queue
            cmdToSend = createCmdString();
            disp('FROM SENDTOROBOT: Robot is currently busy - status checking')
            disp(['Currently in queue:' queue])
        end

    elseif (genError) && (~sockError)
        % if theres a general error, then ping for status and halt the
        % queue
        cmdToSend = createCmdString();
        disp('FROM SENDTOROBOT: Robot has a safety error - status checking')
    end

    if (~sockError)
        % send and get a response from the robot
        disp('FROM SENDTOROBOT: Message to send:')
        disp(cmdToSend)
        
        %send off the command
        query(socket, cmdToSend);
        %send status check, just so theres a latency to allow the robot
        %studio to tell us they're busy
        pause(0.01);
        out = query(socket, 'F|SC|');

        disp('FROM SENDTOROBOT: Recieved response')
        fprintf('MESSAGE: %s \n', out);
    end
end
