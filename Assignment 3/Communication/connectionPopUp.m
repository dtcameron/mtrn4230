function response = connectionPopUp()

    opts.Interpreter = 'tex';
    opts.Default = 'Quit';

    answer = questdlg('Retry Connection?', ...
        'Re-Connection Prompt', ...
        'Re-Connect','Quit',opts);
    % Handle response
    switch answer
        case 'Re-Connect'
            disp(['Retrying Connections...'])
            response = 1;
        otherwise 
            disp(['Quitting Program'])
            response = 0;
    end

end