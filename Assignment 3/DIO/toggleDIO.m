function [cmd, queue] = toggleDIO(DIOType, queue)
    % Input a DIO string (detailed below)
    % will toggle that DIO
    % i.e. if vacSol = 1 currently, sending '1000' will toggle vacSol to 0.
    % DIO TOGGLE (TO), command type (TO)
    % List of DIO: (IN THIS ORDER) 
    %    'VacPump'    (1)
    %    'VacSol'     (2)
    %    'ConRun'     (3)
    %    'ConDir'     (4)

    invalid = 0;
    
    switch(DIOType) 
        case '1'
            binary = '1';
            % pump
        case '2'
            binary = '2';
        case '3'
            binary = '3';
        case '4'
            binary = '4';
        otherwise
            binary = '8';
            invalid = 1;
    end
    
    %check if it's a valid one
    if (invalid == 0)
        binary = char(binary);
        cmd = createCmdString('TO',binary);
    else
        %otherwise just status check
        cmd = createCmdString();
        disp('FROM ToggleDIO: Invalid cmdString, defaulting to status checking')
    end
    
    queue = sendToQueue(queue, cmd);
    
end
