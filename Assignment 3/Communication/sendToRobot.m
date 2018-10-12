function [queue, out] = sendToRobot(queue, socket, error)
  %takes the first command on the queue and sends

    
  if (~error)
   if isempty(queue)
     queue = [queue string(createCmdString())]; 
   end
  
    cmdToSend = queue(1);
    queue(1) = [];
    
  else
    % if theres an error, then ping for status
    % otherwise halt hte queue
    cmdToSend = createCmdString();  
  end  
  
  try
      out = query(socket, cmdToSend);
  catch
      
      disp('Socket is FUCKED');
      
  end
  
end
