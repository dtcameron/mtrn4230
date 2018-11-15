MODULE movement
    PERS string action;
    PERS robjoint joints;
    PERS speeddata speed;
    PERS num jogdir{3};
    PERS num joggingjoints{6};
    PERS robtarget target_pos;
    PERS num busy;
    PERS robtarget glob_pos;
    PERS robtarget current_pos;
    PERS pos targetpos;
    PERS num targetang;
    PERS num interrupt1;
    PERS num interrupt2;
    VAR intnum int1; 
    VAR intnum int2;
    
    PROC Main()
        VAR num Cheight := 300;
        
        CONNECT int1 WITH int_trap1; IPers interrupt1, int1; !connect interrupt
        CONNECT int2 WITH int_trap2; IPers interrupt2, int2;
        
        WHILE TRUE DO
            ! Continuously see what is required to be done, if the server sets an action then perform that action.
            TEST action
            CASE "BI": !box in 
                busy := 1;
                SetDO DO10_4, 1; !move in
                SetDO DO10_3, 1;
                waitTime 10;
                SetDO DO10_3, 0;
                busy := 0;
            CASE "BO": !box out
                busy := 1;
                SetDO DO10_4, 0; !move out
                SetDO DO10_3, 1;
                waitTime 10;
                SetDO DO10_3, 0;
                busy := 0;
            CASE "SM": !simple move
                busy := 1;
                MoveL Offs(glob_pos, targetpos.x, targetpos.y, targetpos.z), v100, fine, tSCup;
                busy := 0;
            CASE "MC": !complex move (use for picking up)
                busy := 1;
                current_pos:= CRobT(\Tool:=tSCup);
                MoveL offs(glob_pos, current_pos.trans.x, current_pos.trans.y, Cheight-current_pos.trans.z), v100, fine, tSCup;
                MoveJ Offs(glob_pos, targetpos.x, targetpos.y, Cheight-targetpos.z), v100, fine, tSCup;
                MoveL Offs(glob_pos, targetpos.x, targetpos.y, targetpos.z), v100, fine, tSCup;
                busy := 0;
            CASE "TM": !trace move
                busy := 1;
                MoveL Offs(glob_pos, targetpos.x, targetpos.y, targetpos.z), v100, fine, tSCup;
                busy := 0;
            CASE "SE": !trace stop
                SetDO DO10_1, 0;
                SetDO DO10_2, 0;
            CASE "SS": !trace stop
                SetDO DO10_1, 1;
                SetDO DO10_2, 1;
            CASE "MJ":
                MoveAbsJ [joints,[9e9,9e9,9e9,9e9,9e9,9e9]], speed, fine, tSCup;
            CASE "JL":
                joglinear;
            CASE "JJ":
                jogjoint;
            !CASE "PA":
                
                !StorePath;
                !StopMove;
            !CASE "RE":
                
                !RestoPath;
                !StartMove;
            CASE "ST":
                StopMove;
                ClearPath;
                joggingjoints := [0,0,0,0,0,0];
                joints := [0,0,0,0,0,0];
            CASE "MC":
                MoveL target_pos, speed, fine, tSCup;
            CASE "MT":
                MoveL target_pos, speed, fine, tSCup;
            CASE "MB":
                MoveL Offs(CRobT(\Tool:=tSCup),0,0,100), speed, fine, tScup;
                MoveL Offs(target_pos, 0,0,100), speed, fine, tSCup;
                MoveL target_pos, speed, fine, tSCup;
            CASE "HP":
                busy := 1;
                MoveToHomePos;
                busy := 0;
            CASE "CP":
                busy := 1;
                MoveToCalibPos;
                busy := 0;
            CASE "RO":
                busy := 1;
                current_pos:= CRobT(\Tool:=tSCup);
                MoveL RelTool(glob_pos, current_pos.trans.x, current_pos.trans.y, current_pos.trans.z \Rz:=targetang), v100, fine, tSCup;
            IF action <> "JL" AND action <> "JJ" AND action <> "PA" THEN
                action := "";
            ENDIF
            ENDTEST
        ENDWHILE
    ENDPROC
    
    PROC joglinear()
        ! this function reads in persistent variables and then sets the robot target to be slightly further away in the requested direction
        ! than the current target
        var robtarget curr_target;
        curr_target := CRobT(\Tool:=tSCup);
        MoveL Offs(curr_target, jogdir{1}*100, jogdir{2}*100, jogdir{3}*100), speed, fine, tSCup;
    ENDPROC

    PROC jogjoint()
        !this function reads in persistent variables and then sets the robot target to be slightly further away in the requested angles
        ! than the current target
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
    
    TRAP int_trap1 ! pause
        StopMove;
    ENDTRAP
    
    TRAP int_trap2 ! pause
        StartMove;
    ENDTRAP
        
    
ENDMODULE
