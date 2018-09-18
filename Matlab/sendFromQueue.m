function queue = sendFromQueue(queue, socket)
  %takes the first command on the queue and sends

  cmdToSend = queue(1)
  queue(1) = [];
  
  fwrite(socket, cmdToSend);
  
end
