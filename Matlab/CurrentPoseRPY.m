function [x,y,z,roll,pitch,yaw] = CurrentPose()
k = pi/180;
J(1) = app.Joint1Pos * k;
J(2) = app.Joint2Pos * k;
J(3) = app.Joint3Pos * k;
J(4) = app.Joint4Pos * k;
J(5) = app.Joint5Pos * k;
J(6) = app.Joint6Pos * k;
T = app.irb_120.fkine(J);
rotm = [T.n,T.o,T.a];
temp = T.t;
x = temp(1);
y = temp(2);
z = temp(3);
roll = atan2(rotm(1,2),rotm(1,1));
pitch = atan2(-rotm(1,3)/sqrt((rotm(2,3))^2 +(rotm(3,3))^2));
yaw = atan2(rotm(2,3),rotm(3,3));
end