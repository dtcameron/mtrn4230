function joints = decodeJoints(rawJoints)
    %reconvert the char jointData coming back from RS
    % returns a 1 * 6 (size(Joints)) joint angle array
    % previously, it had been converted from float to int to char
    % going from char to int to float
    % raw joints should be a 6 * 2 char array
    
    rawJoints = hex2dec(rawJoints);
    rawJoints = rawJoints';
    
    % some int to float
    % convx = (rad  /(2*pi))*(2^16-1))
    % rad =  (convx /(2^16-1)) * (2*pi)
    joints = (rawJoints/(2^16-1)) * 2*pi;

end
