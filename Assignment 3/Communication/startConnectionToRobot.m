function [socket, connectType] = startConnectionToRobot()
% function [socket, connectType] = startConnectionToRobot()
%       Will attempt to start a connection to the robot/simulation
%       Open a TCP connection to the robot.
%       
%       INPUTS: None
%
%       OUTPUTS: 
%           SOCKET
%           Is a MATLAB obj of type socket for the further TCPIP
%           communications
%
%           CONNECTTYPE
%           An indication of the type of connection established, either 0,
%           1 or 2
%               1 = Real Robot
%               0 = RS simulation (fake)
%               2 = error (no connection established)

    % The robot's details:
    % Real Robot     '192.168.125.1'
    % Fake Robot     '127.0.0.1'
    % Port           '1025'
    
    RSAddress = '192.168.125.1111111111111';
    FakeAddress = '127.0.0.1';
    robotPort = 1025;
    
    % try connect ot RS
    socket = connectAttempt(RSAddress, robotPort);
    if(isequal(get(socket, 'Status'), 'open'))
        connectType = 1;
    else

    %try connect to simulation RS
        socket = connectAttempt(FakeAddress, robotPort);
        if(isequal(get(socket, 'Status'), 'open'))
            connectType = 0;
        else
            connectType = 2;                
        end

    end
          
end


