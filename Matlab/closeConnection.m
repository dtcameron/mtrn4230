function closeConnection(socket)
% move robot to home position, avoid collision, set all DOs to 0 , close
% connection
    fclose(socket);

end