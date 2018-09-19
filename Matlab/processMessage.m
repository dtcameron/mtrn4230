function [status, safety, DIO, joints] = processMessage(x)
    %[status, safety, DIO, joints] = processMessage(x)
    %decodes the message coming back from RS
    %gives a status struct, binary safety and DIO, 1 x 6 joint angle array in radians

    status.Head = x(1);
    status.Status  = [x(2) x(3) x(4) x(5)];
    status.PrevCmd = x(6);
    
            % Estop LC  Mot   HtE   MTE
    safety = [x(7) x(8) x(9) x(10) x(11)]; %doesn't need additional processing
    
    DIO = [x(12) x(13) x(14) x(15) x(16)]; %also doesn't need additional processing
    
    rawJoints = [x(17:18);     ... % J1
              x(19:20);     ... % J2
              x(21:22);     ... % J3
              x(23:24);     ... % J4
              x(25:26);     ... % J5
              x(27:28);];       % J6
    % WILL NEED PROCESSING VIA decodeJoint
    joints = decodeJoints(rawJoints)

end
