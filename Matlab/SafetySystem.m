function SafetySystem(app, safety)
% modify error lamp and display error message
% should be called after every message decoding

if any(safety)
    app.ERRORLamp.Color = 'r';
    if safety(1) == 1
        app.ErrorStateText.Value = 'Emergency stop activated';
    elseif safety(2) == 1
        app.ErrorStateText.Value = 'Light curtain activated';
    elseif safety(3) == 1
        app.ErrorStateText.Value = 'Motors off';
    elseif safety(4) == 1
        app.ErrorStateText.Value = 'Hold to enable not pressed';
    elseif safety(5) == 1
        app.ErrorStateText.Value = 'Motion task not running/Execution Error';
    end
else
    app.ERRORLamp.Color = 'g';
    app.ErrorStateText.Value = '';
end

end
