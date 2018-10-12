function cmd = createCmdString(cmdType, data)
    %appends the stuff needed plus an MATLAB to RS header
    % cmdType must be a char designating the command type
    % MATLAB -> RS
    %
    % i.e.
    %  Status Check  (C)
    %  Status Change (G)
    %  Set DIO       (D)
      %
    %  Set Pose      (P)
    %  Jog Joint     (J)
    %  Jog Linear    (L)
    %  Jog Stop      (S)
    
    % Check if it's empty
    dataEmptyflag = 0;
    
    if ~exist('data','var') && ~exist('cmdType','var')
        dataEmptyflag = 1; 
    end
    
    header = 'F';
    
    %data must be formatted into it's char components already
    if (dataEmptyflag)
        cmd = strcat(header, 'SC');
    else
        cmd = strcat(header, cmdType, data);        
    end
    
end