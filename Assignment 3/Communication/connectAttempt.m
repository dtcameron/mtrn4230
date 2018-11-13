function socket = connectAttempt(address, port)
%   function socket = connectAttempt(address, port)
%       
%
%
%
%
    socket = tcpip(address, port);
    set(socket, 'ReadAsyncMode', 'continuous');
    set(socket, 'Timeout', 0.5);
    
    try
        disp(['FROM connectAttempt: Opening a TCP connection to ', address, ' on port ', num2str(port)]);
        fopen(socket);
        disp(['FROM connectAttempt: Connected to ', address, ' on port ', num2str(port)]);
    catch
        disp(['FROM connectAttempt: Could not open TCP connection to ', address, ' on port ', num2str(port)]);
    end
    
end