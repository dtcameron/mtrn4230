function queue = sendToRobot(queue, socket)
  %takes the first command on the queue and sends
  
  if isempty(queue)
    queue(1) = 'FC' %status check by default if empty)
  end

  cmdToSend = queue(1)
  queue(1) = [];
  
  fwrite(socket, cmdToSend);
  
end
