function CalculateJointAngles()
Tableval = app.TableButton.Value;
        Conveyerval = app.ConveyerButton.Value;
        orientationval = app.EndEffOriOnlySwitch.Value;
        Speed = app.SpeedDropDown.Value;
        if orientationval == 'On'
            Orientationval = 1;
        end
         k = pi/180;
        roll = app.RollEditFiled.Value * k;
        pitch = app.RollEditFiled.Value*k;
        yaw = app.RollEditFiled.Value*k;
    
    Rx = [1,0,0;0,cos(roll),-sin(roll);0,sin(roll),cos(roll)];
    Ry = [cos(pitch),0,sin(pitch);0,1,0;-sin(pitch),0,cos(pitch)];
    Rz = [cos(yaw),-sin(yaw),0;sin(yaw),cos(yaw),0;0,0,1];
    Rotm = Rx*Ry*Rz;
        if Tableval == 1 && Conveyerval == 0 && Orientationval == 0
            HomeT = [0,1,0,175;1,0,0,0;0,0,-1,147;0,0,0,1];
            X = app.XEditFiled.Value;
            Y = app.YEditFiled.Value;
            Z = app.ZEditFiled.Value;
            EfT = [Rotm(1,:),X;Rotm(2,:),Y;Rotm(3,:),Z;0,0,0,1];
            EffT = HomeT * EfT;
        end
        if Conveyerval == 1 && Tableval == 0 && Orientationval == 0
            HomeT = [-1,0,0,0;0,1,0,409;0,0,1,22;0,0,0,1];
            X = app.XEditFiled.Value;
            Y = app.YEditFiled.Value;
            Z = app.ZEditFiled.Value;
            EfT = [Rotm(1,:),X;Rotm(2,:),Y;Rotm(3,:),Z;0,0,0,1];
            EffT = HomeT * EfT;
        end
        if Orientationval == 1
            X = app.endEffectorX;
            Y = app.endEffectorY;
            Z = app.endEffectorZ;
            EfT = [Rotm(1,:),X;Rotm(2,:),Y;Rotm(3,:),Z;0,0,0,1];
        end
       
    app.Jimm = irb_120.ikine(EffT);
     for i = 1:length(app.Jimm)
            if app.Jimm(i) > 360
               app.Jimm(i) = J(i) - 360;
            end
     end
      for i = 1: length(app.Jimm)
          app.Jimm(i) = (app.Jimm(i) / (360)) * ((2^15));
      end
      app.Jimm = [int2chars(app.Jimm(1)) int2chars(app.Jimm(2)) int2chars(app.Jimm(3)) int2chars(app.Jimm(4)) int2chars(app.Jimm(5)) int2chars(app.Jimm(6))];
        outData = [Speed app.Jimm];
        createCmdString(outData);
end