function startConnectionToRobot(IP)
% Will attempt to start a connection to the robot/simulation

    % The robot's details:
    % Real Robot     '192.168.125.1'
    % Fake Robot     '127.0.0.1'
    % Port           '1025'
    robotIPAddress = IP;
    robotPort = 1025;
    
    % Connection variables 
    confirmFlag = 0;

    % Open a TCP connection to the robot.
    socket = tcpip(robotIPAddress, robotPort);
    set(socket, 'ReadAsyncMode', 'continuous', 'Timeout',1.2);
    fopen(socket);

    % Check if the connection is valid
    if(~isequal(get(socket, 'Status'), 'open'))
        warning(['Could not open TCP connection to ', robotIPAddress, ' on port ', robot_port]);
        return;
    end
    %------------------------------------------------------------------
    
    % Confirmation of robot stuff
    %   Should probably set the robot's status bits here
    %       Set Connected
    %       Set Confirmation
    %
    fwrite(socket, [datestr(datetime('now'),'mmm-dd HH:MM:SS') ... 
                   '. Henlo Robot!.\n']);     %send message
    data = fgetl(socket);     %recieve reply
    fprintf(char(data));     % Print confirmation
    %------------------------------------------------------------------
    %Set the status bits for intialization!!!!
    %Set hte confirmation bit and see if it comes back okay
    initConfMsg = changeStatus('Confirmation');
    fwrite(socket, initConfMsg);
    
    while ()
    
    end

    
    
    
%     % Close the socket.
%     fclose(socket);
    
end
