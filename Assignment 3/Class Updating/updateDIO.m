function [vacPump, vacSol, conStat, conRun, conDir] = updateDIO(DIO)
    % WILL UPDATE THE DIO FROM STATUS
    % run from any DIO changing button

    vacPump = DIO(1);
    vacSol = DIO(2);
    conStat = DIO(3);
    conRun = DIO(4);
    conDir = DIO(5);

end