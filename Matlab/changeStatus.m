function cmd = changeStatus(statusType)
    % Sends status to change
    % Will toggle that status
    %
    % STATUS CHANGE, command type (G)
    % List of Statuses:   (IN THIS ORDER)
    %                   
    %    'Confirmation'     (1)
    %    'Connected'        (2)              
    %    'Paused'          (3)
    %    'Awaiting'         (4)
    
    invalid = 0;
    
    switch(statusType) 
        case 'Confirmation'
            binary = '1000';
        case 'Connected'
            binary = '0100';
        case 'Paused'
            binary = '0010';
        case 'AwaitingCommand'
            binary = '0001';
        otherwise
            binary = '0000';
            invalid = 1;
    end

    
    %check if it's a valid one
    if (invalid == 0)
        binary = char(binary);
        cmd = createCmdString('G',binary);
    else
        cmd = createCmdString('C');
        disp('Invalid Cmd String, defaulting to status checking')
    end
    

end