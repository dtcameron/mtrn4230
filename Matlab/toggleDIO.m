function cmd = toggleDIO(DIOType)
    % Input a DIO string (detailed below)
    % will toggle that DIO
    % i.e. if vacSol = 1 currently, sending '1000' will toggle vacSol to 0.
    
    % DIO CHANGE (D), command type (D)
    % List of DIO: (IN THIS ORDER)
    %    'VacSol'     (1)
    %    'VacPump'    (2)              
    %    'ConRun'     (3)
    %    'ConDir'     (4)

    invalid = 0;
    
    switch(DIOType) 
        case 'VacSol'
            binary = '1000';
        case 'VacPump'
            binary = '0100';
        case 'ConRun'
            binary = '0010';
        case 'ConDir'
            binary = '0001';
        otherwise
            binary = '0000';
            invalid = 1;
    end
    
    %check if it's a valid one
    if (invalid == 0)
        binary = char(binary);
        cmd = createCmdString('D',binary);
    else
        cmd = createCmdString('C')
        disp('Invalid cmdString, defaulting to status checking')
    end
    
end
