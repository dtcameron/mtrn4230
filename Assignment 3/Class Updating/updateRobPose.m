function [statusEE, statusJoint] = updateRobPose(rawXYZ, rawEEO, rawJoint)
%     [EE, Joints] = function updateRobStatus(rawEE, rawJoint)
%          DECIPHERS the EE and Joints from the processMessage function
%
%       INPUT: rawEE
%          A 
%
%
%
%       OUTPUT: statusEE
%          Is a 1x6 double array which stores the EE XYZ (1:3) and EE
%          orientations (4:6)
%
%       OUTPUT: statusJoint
%          Is a 1x6 double array which stores the joints angles

    statusEE = [0;0;0;0;0;0];
    statusJoint = [0;0;0;0;0;0];

    %xyz position of end effector
    posEE = rawXYZ; %remove [] brackets
    pos = strsplit(posEE,','); %split by comma
    %convert char cells to num array and transpose
    statusEE(1:3) = str2double(pos)'; 
        
    %orientation of end effector
    orientEE = rawEEO; %this is a quaternion
    QuaternCell = strsplit(orientEE,',');%split by comma
    %convert char cells quaternion array
    quaterns = str2double(QuaternCell);
    statusEE(4:6) = quat2eul(quaterns,'XYZ')'; % back to euler angles
    statusEE(4:6) = statusEE(4:6)*180/pi; %convert to radians
    
    %joints of end effector
    poseJoint = rawJoint(2:end-1); %remove [] bracket
    joint = strsplit(poseJoint,',');
    statusJoint.JointPose(:) = str2double(joint)';
        
end