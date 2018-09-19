function joints = decodeJoints(rawJoints)
    %reconvert the char jointData coming back from RS
    % returns a 1 * 6 (size(Joints)) joint angle array
    % previously, it had been converted from float to int to char
    % going from char to int to float
    
    rawJoint = zeros(1, size(rawJoints,1));
    
    for i = 1:size(rawJoints,1)
        %We are in char mode right now , char -> binary
        binary = [dec2bin(rawJoints(i,1),8) dec2bin(rawJoints(i,2),8)];
        
        % binary -> some int for each joint
        rawJoint(i) = (bin2dec(binary));
    end
    
    % some int to float
    % convx = (rad  /(2*pi))*(2^16-1))
    % rad =  (convx /(2^16-1)) * (2*pi)
    joints = (rawJoint/(2^16-1)) * 2*pi;

    

end