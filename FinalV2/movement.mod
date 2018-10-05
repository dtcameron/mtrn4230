MODULE movement
    PERS string action;
    PERS robjoint joints;
    PERS speeddata speed;
    PERS num jogdir{3};
    PERS num joggingjoints{6};
    PROC Main()
        WHILE TRUE DO
            !here we actually move the robot
            TEST action
            CASE "P":
                MoveAbsJ [joints,[9e9,9e9,9e9,9e9,9e9,9e9]], speed, fine, tSCup;
            CASE "L":
                joglinear;
            CASE "J":
                jogjoint;
            CASE "A":
                StorePath;
                StopMove;
            CASE "R":
                RestoPath;
                StartMove;
            CASE "H":
                StopMove;
                ClearPath;
                joggingjoints := [0,0,0,0,0,0];
                joints := [0,0,0,0,0,0];
            IF action <> "L" AND action <> "J" THEN
                action := "";
            ENDIF
            ENDTEST
        ENDWHILE
    ENDPROC
    
    PROC joglinear()
        var robtarget curr_target;
        curr_target := CRobT(\Tool:=tSCup);
        MoveL Offs(curr_target, jogdir{1}*100, jogdir{2}*100, jogdir{3}*100), speed, fine, tSCup;
    ENDPROC

    PROC jogjoint()
        VAR jointtarget jointsout;
        jointsout := CJointT();
        jointsout.robax.rax_1 := jointsout.robax.rax_1 + joggingjoints{1};
        jointsout.robax.rax_2 := jointsout.robax.rax_2 + joggingjoints{1};
        jointsout.robax.rax_3 := jointsout.robax.rax_3 + joggingjoints{1};
        jointsout.robax.rax_4 := jointsout.robax.rax_4 + joggingjoints{1};
        jointsout.robax.rax_5 := jointsout.robax.rax_5 + joggingjoints{1};
        jointsout.robax.rax_6 := jointsout.robax.rax_6 + joggingjoints{1};
        
        MoveAbsJ jointsout, speed, fine, tSCup;
    ENDPROC
ENDMODULE
