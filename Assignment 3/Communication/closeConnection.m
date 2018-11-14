function err = closeConnection(socket)
% Close a TCP connection to the robot
    if(isequal(get(socket, 'Status'), 'closed'))
        disp('Socket closed already ... moving on')
        err = true;
        return;
    end

    try
        % send close signal
%         out = query(socket, 'Closing Socket...');  
%         disp(out);
        
%         pause(0.2);
        fclose(socket);
        err = false;
    catch
        warning('Socket close failed');
        err = true;
    end  
end