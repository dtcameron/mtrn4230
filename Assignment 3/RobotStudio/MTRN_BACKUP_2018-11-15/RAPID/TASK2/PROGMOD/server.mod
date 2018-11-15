MODULE server    

    ! The socket connected to the client.
    VAR socketdev client_socket;
    
    ! The host and port that we will be listening for a connection on.
    PERS string host := "127.0.0.1";
    PERS string action := "SC";
    PERS robjoint joints := [0,0,0,0,0,0];
    PERS num joggingjoints{6} := [0,0,0,0,0,0];
    PERS num jogdir{3} := [0,0,0];
    PERS robtarget target_pos;
    PERS speeddata speed;
    PERS num busy := 0;
    PERS robtarget glob_pos := [[0,0,0],[0,0,-1,0],[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
    PERS robtarget current_pos;
    PERS pos targetpos;
    PERS num targetang;
    PERS num interrupt1 := 0;
    PERS num interrupt2 := 0;
   
    CONST num port := 1025;
    
    PROC Main ()
        speed := v100;
        IF RobOS() THEN
            host := "192.168.125.1";
        ELSE
            host := "127.0.0.1";
        ENDIF
        !host := "127.0.0.1";
        MainServer;
        
    ENDPROC

    PROC MainServer()
        
        VAR string received_str;
        ListenForAndAcceptConnection;
        WHILE TRUE DO
            AwaitMessage;
        ENDWHILE


        CloseConnection;
		
    ENDPROC
    
    PROC AwaitMessage()
        ! --------------------
        ! This funciton is the main waiting loop for the server, it will wait untill it recieves a message from the matlab client and then act on it
        ! --------------------
        
        
        !VAR string received_str;
        VAR string received_str := "FC";
        !VAR num joints{6} := [0,0,0,0,0,0];
        
        VAR num target := -1;
        VAR num val := -1;
        VAR string lastcommand := ""; 
        VAR string splitstring{1024};
        VAR num n_results;
        VAR string a;
        VAR string b;
        VAR string c;
        VAR string d;
        VAR bool ok;
        
        !VAR pos targetpos;
        VAR orient targetquat;
        
        !received_str := "F|SM|[175,0,147]|[0,0,-1,0]|";
        
        SocketReceive client_socket \Str:=received_str \Time:=3;
        
        strSplit received_str,"|",splitstring,n_results;

        !Split received_str,splitstring,n_results;

        IF splitstring{1} = "F" THEN
            TEST splitstring{2}
            CASE "SC":
                action := "SC";
            CASE "BI":
                action := "BI";
            CASE "BO":
                action := "BO";
            CASE "SM":
                action := "SM";                
                ok := StrToVal(splitstring{3},targetpos);
                !ok := StrToVal(splitstring{4},targetquat);
                !target_pos := [targetpos, targetquat,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CASE "MC": !complex move (use for picking up)
                action := "MC";
                ok := StrToVal(splitstring{3},targetpos);
                !ok := StrToVal(splitstring{4},targetquat);
                !target_pos := [targetpos, targetquat,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CASE "TM": !trace move
                action := "TM";
                ok := StrToVal(splitstring{3},targetpos);
                !ok := StrToVal(splitstring{4},targetquat);
                !target_pos := [targetpos, targetquat,[0,0,0,0],[9E+09,9E+09,9E+09,9E+09,9E+09,9E+09]];
            CASE "SE": !suction stop
                action := "SE";
            CASE "SS": !suction start
                action := "SS";
            CASE "HP": !move to home position
                action := "HP";
            CASE "CP": !move to calib position
                action := "CP";
            CASE "RO": !Reorientation
                action := "RO";
                ok := StrToVal(splitstring{3},targetang);
            CASE "PA": !Pause
                interrupt1 := interrupt1 + 1;
            CASE "RE": !Resume
                interrupt2 := interrupt2 + 1;
            CASE "ST": !Stop
                action := "ST";
            ENDTEST
        ENDIF
       
        !get action
        
        !perform action
        
        !reply
            
        ! Send the string back to the client, adding a line feed character.
        SocketSend client_socket \Str:=GetRobStatus(lastcommand);
        
        ERROR
        IF ERRNO = ERR_SOCK_CLOSED THEN
            SocketClose client_socket;
            ListenForAndAcceptConnection;
            RETRY;
        ELSEIF ERRNO = ERR_SOCK_TIMEOUT THEN
            SocketClose client_socket;
            SetDO DO10_1, 0;
            SetDO DO10_2, 0;
            SetDO DO10_3, 0;
            SetDO DO10_4, 0;
            ListenForAndAcceptConnection;
            RETRY;
        ENDIF
    ENDPROC
    
    PROC strSplit(string str, string split, var string result{*}, var num n_results)
        VAR num pos := 1;
        VAR num next := 1;
        FOR i FROM 1 TO dim(result,1) DO
            result{i} := "";
        ENDFOR 
        n_results := 0;
        FOR i FROM 1 TO dim(result,1) DO
            next := StrFind(str,pos,split);
            result{i} := StrPart(str, pos, next -pos);
            n_results := n_results +1;
            IF next > StrLen(str) THEN
                RETURN;
            ENDIF
            pos := next +1;
        ENDFOR
    ENDPROC
    
    PROC Split(string str, VAR string bits{*}, VAR num n_bits)
        VAR num position := 1;
        VAR num next_position := 1;
        FOR i FROM 1 TO dim(bits, 1) DO
            bits{i} := "";
        ENDFOR
        n_bits := 0;
        FOR i FROM 1 TO dim(bits, 1) DO
            next_position := StrFind(str, position, "|");
            bits{i} := StrPart(str, position, next_position - position);
            n_bits := n_bits + 1;
            IF next_position > StrLen(str) THEN
                RETURN;
            ENDIF
            position := next_position + 1;
        ENDFOR
    ENDPROC
    
    FUNC string GetRobStatus(string lastcommand)
        ! ------------------
        ! This function expects the last command that was sent to the robot and returns a string representation of the robots status,
        ! ready to be sent back to the matlab client
        
        
        VAR string output := "B|";
        VAR robtarget robPos;
        VAR string temp := "";
        VAR jointtarget robJoint;
        
        !BUSY BIT
        output := output + NumToStr(busy,0) + "\0A";
        
        !ROBOT POSITION
        !robPos := CRobT(\Tool:=tSCup);
        !output := output + ValToStr(robPos.rot) + "|" + ValToStr(robPos.trans) + "|";
        !robJoint := CJointT();
        !output := output + ValToStr(robJoint.robax) + "\0A";
        
        RETURN output;
        
        
    ENDFUNC
    
    PROC batchSetDigitalO(string target)
        ! -----------
        ! This function takes in a 4 long binary string, breaks it down for each digital io value and then uses another function to set it
        setDigitalIO 1, StrToByte(Strpart(target,1,1));
        setDigitalIO 2, StrToByte(Strpart(target,2,1));
        setDigitalIO 3, StrToByte(Strpart(target,3,1));
        setDigitalIO 4, StrToByte(Strpart(target,4,1));
    ENDPROC
    
    
    
    PROC setDigitalIO(num target, num value)
        ! this function takes in a target io suffic and a value and then sets the digital output with the target suffix with the given value
        !TEST target
        !CASE 1:
        !    DO10_1 := value;
        !CASE 2:
        !    DO10_2 := value;
        !CASE 3:
        !    DO10_3 := value;
        !CASE 4:
        !    DO10_4 := value;
        !ENDTEST
    ENDPROC
    
    
    FUNC num Decode2Bytes(string chars)
        ! this function takes in a string of length 4 and then returns its CHAR representation of that string -32772 - 32711
        VAR byte data_buffer{5};
        VAR string big := "";
        
        VAR string little := "";
        VAR num bigNum := 0;
        VAR num littleNum := 0;
        VAR num result := 0;
        big := StrPart(chars,3,2);
        little := StrPart(chars,1,2);
        bigNum := StrToByte(big\Hex);
        littleNum := StrToByte(little\Hex);
        
        result := bigNum *255 + littleNum;
        result := result - Round(pow(2,16)-1/2);
        RETURN result;
    ENDFUNC
    
    FUNC string Encode2String(num in)
        ! this function takes in a numerical value 0-65535 and then returns a 4 byte hexstring that represents that value
        VAR string out;
        VAR string a;
        VAR string b;
        VAR num last;
        VAR num first;
        !in := in + 35535;
        !in := round((in/360)*Pow(2, 16)-1);
        !in := in/360;
        !in := round(in / 65535);
        !last := in MOD 256;
        !first := Round((in-last)/256);
        !out := ByteToStr(first\Hex) +  ByteToStr(last\Hex); 
        
        
        
        RETURN out;
    ENDFUNC
    
    PROC ListenForAndAcceptConnection()
        !this function is used to (re)connect to a socket
        
        ! Create the socket to listen for a connection on.
        VAR socketdev welcome_socket;
        SocketCreate welcome_socket;
        
        ! Bind the socket to the host and port.
        SocketBind welcome_socket, host, port;
        
        ! Listen on the welcome socket.
        SocketListen welcome_socket;
        
        ! Accept a connection on the host and port.
        SocketAccept welcome_socket, client_socket \Time:=1000;
        
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
    

ENDMODULE
