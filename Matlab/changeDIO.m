function cmd = changeDIO(DIOBinary)
    % Input a DIO string (detailed below)
    % Will set the bits of the corresponding position DIO accordinly
    % i.e. sending '1000'
    % VacSol = 1, VacPump = 0, ConRun = 0, ConDir = 0
    
    % DIO CHANGE (D), command type (D)
    % List of DIO: (IN THIS ORDER)
    %    'VacSol'     (1)
    %    'VacPump'    (2)              
    %    'ConRun'     (3)
    %    'ConDir'     (4)

    invalid = 0;
    
    if numel(DIOBinary) ~= 4
        invalid = 1;
    else
        binary = DIOBinary;
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
