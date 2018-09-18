function prioritySendToRobot(socket, cmd)
%this one skips and queue and send straight to, used for status updates

    fwrite(socket, cmd);

end