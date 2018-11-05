function [head, status, safety, DIO, joints, EE] = processMessage(x)
%     [status, safety, DIO, joints] = processMessage(x)
%     decodes the message coming back from RS
%     gives a status struct, binary safety and DIO, 1 x 6 joint angle array in radians
%         message strcut:
%            head - 1 byte, 'F'
%            status - x bytes
%            safety  - x bytes
%            DIO - 4 bytes
%            joints - 12 bytes
%            EE - 12 bytes

    %divide up the message
    a = strsplit(x, '|');
                
    head = char(a(1));
    status = char(a(2));
    safety = char(a(3));
    DIO = char(a(4));
    joints = char(a(5));
    EE = char(a(6));
            
    % WILL NEED furtherPROCESSING VIA decodeJoint
%     joints = decodeJoints(rawJoints);
%     EEcoord = decodeEE(rawEE);

end
