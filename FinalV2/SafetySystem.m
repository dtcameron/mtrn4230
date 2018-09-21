function errFlag = SafetySystem(app, safety)
% modify error lamp and display error message
% should be called after every message decoding

errFlag = 0;

if any(safety)
    app.ERRORLamp.Color = 'r';
    if safety(1) == 1
        app.ErrorStateText.Value = 'Emergency stop activated';
        errFlag = 1;
    elseif safety(2) == 1
        app.ErrorStateText.Value = 'Light curtain activated';
        errFlag = 1;
    elseif safety(3) == 1
        app.ErrorStateText.Value = 'Motors off';
        errFlag = 1;
    elseif safety(4) == 1
        app.ErrorStateText.Value = 'Hold to enable not pressed';
        errFlag = 1;
    elseif safety(5) == 1
        app.ErrorStateText.Value = 'Motion task not running/Execution Error';
        errFlag = 1;
    end
else
    app.ERRORLamp.Color = 'g';
    app.ErrorStateText.Value = '';
    errFlag = 0;
end

end
