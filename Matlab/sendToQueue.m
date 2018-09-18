function queue = sendToQueue(queue, cmd)
    % appends a command (string cmd) to the queue (string[] queue)
    % IMPORTANT NOTE: input cmd will be a double quote string
    %                i.e "WOW" --- CORRECT 
    %                i.e 'WOW' --- wrong
    
    %convert to string is anything else
    cmd = string(cmd);
    
    %append to queue
    queue = [queue cmd];

end