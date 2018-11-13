function cmd = createCmdString(cmdType, data)
    %appends the stuff needed plus an MATLAB to RS header
    % cmdType must be a char designating the command type
    % MATLAB -> RS
    % data is string
    % cmdType is a string
    %
    % i.e.
    %  Status Check  (SC)

    
    % Check if it's empty, used to send status if empty
    dataEmptyflag = 0;
    
    if ~exist('data','var') && ~exist('cmdType','var')
        dataEmptyflag = 1; 
    end
    
    %append a header
    header = 'F';
    
    %data must be formatted into it's char components already
    if (dataEmptyflag)
        %query a status check during idle ticks
        cmd = {header, 'SC'};
        cmd = strjoin(cmd,'|');
    else
        cmd = {header, cmdType, data}; 
        cmd = strjoin(cmd,'|');
    end
    
    %add a delimiter to the end (before the new line character)
    cmd = strcat(cmd,'|');
    
end