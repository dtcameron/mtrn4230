function BasicJointanglemove()
      
        app.Jimm(1) = app.Joint1EditField.Value;
        app.Jimm(2) = app.Joint2EditField.Value;
        app.Jimm(3) = app.Joint3EditField.Value;
        app.Jimm(4) = app.Joint4EditField.Value;
        app.Jimm(5) = app.Joint5EditField.Value;
        app.Jimm(6) = app.Joint6EditField.Value;
        Speed = app.SpeedDropDown.Value;
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
