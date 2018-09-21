MODULE server    

    ! The socket connected to the client.
    VAR socketdev client_socket;
    
    ! The host and port that we will be listening for a connection on.
    PERS string host := "127.0.0.1";
    PERS string action := "";
    PERS robjoint joints := [0,0,0,0,0,0];
    PERS num joggingjoints{6} := [0,0,0,0,0,0];
    PERS num jogdir{3} := [0,0,0];
    PERS speeddata speed;
    
    CONST num port := 1025;
    
    PROC Main ()
        speed := v100;
        IF RobOS() THEN
            host := "192.168.125.1";
        ELSE
            host := "127.0.0.1";
        ENDIF
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
        
        SocketReceive client_socket \Str:=received_str;
        
        
        ! Await for a message and then process it once it comes in
        IF StrPart(received_str,1,1) = "F" THEN
            TEST StrPart(received_str,2,1)
            CASE "C": !status check
                lastcommand := "C";
            CASE "D": !set all digital outputs to this
                lastcommand := "D";
                batchSetDigitalO(StrPart(received_str, 3, 4));                
            CASE "T": !toggle individual digital output
                lastcommand := "D";
                target := StrToByte(StrPart(received_str, 3, 1));
                val := StrToByte(StrPart(received_str, 4, 1));
                setDigitalIO target, val;
            CASE "P": !move to specified pose
                lastcommand := "P";
                action := "p";
                joints := [
                    Decode2Bytes(StrPart(received_str,3,2)),
                    Decode2Bytes(StrPart(received_str,5,2)),
                    Decode2Bytes(StrPart(received_str,7,2)),
                    Decode2Bytes(StrPart(received_str,9,2)),
                    Decode2Bytes(StrPart(received_str,11,2)),
                    Decode2Bytes(StrPart(received_str,13,2))];
                    
            CASE "J": !jog joint
                lastcommand := "J";
                joggingjoints := [
                    Decode2Bytes(StrPart(received_str,3,2)),
                    Decode2Bytes(StrPart(received_str,5,2)),
                    Decode2Bytes(StrPart(received_str,7,2)),
                    Decode2Bytes(StrPart(received_str,9,2)),
                    Decode2Bytes(StrPart(received_str,11,2)),
                    Decode2Bytes(StrPart(received_str,13,2))];

                
            CASE "L": !jog linear 
                lastcommand := "L";
                jogdir := [
                    StrToByte(StrPart(received_str,3,2)),
                    StrToByte(StrPart(received_str,5,2)),
                    StrToByte(StrPart(received_str,7,2))
                
                ];
            CASE "A": !pause jogging (arrette)
                lastcommand := "A";
                StorePath;
                StopMove;
            CASE "R": !resume jogging 
                lastcommand := "R";
                RestoPath;
                StartMove;
            CASE "H": !
                lastcommand := "H";
                StopMove;
                ClearPath;
            DEFAULT:
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
            ListenForAndAcceptConnection;
            RETRY;
        ENDIF
    ENDPROC
    
    FUNC string GetRobStatus(string lastcommand)
        ! ------------------
        ! This function expects the last command that was sent to the robot and returns a string representation of the robots status,
        ! ready to be sent back to the matlab client
        
        
        VAR string output := "B";
        VAR jointtarget jointsout;
        VAR string temp := "";
        !DI
        !Status
        output := output + "1111";
        !Prev command
        output := output + lastcommand;
        !Safety
        output := output + lastcommand; !
        output := output + lastcommand;
        output := output + lastcommand;
        output := output + lastcommand;
        output := output + lastcommand;
        !DIO
        output := output + ByteToStr(DO10_2); !vac sol
        output := output + ByteToStr(DO10_1); !vac pump
        output := output + ByteToStr(DO10_3); !con run
        output := output + ByteToStr(DO10_4); !con dir
        output := output + ByteToStr(DI10_1); !Con stat
        !Joints
        jointsout := CJointT();
        
        output := output + Encode2String(jointsout.robax.rax_1);
        output := output + Encode2String(jointsout.robax.rax_2);
        output := output + Encode2String(jointsout.robax.rax_3);
        output := output + Encode2String(jointsout.robax.rax_4);
        output := output + Encode2String(jointsout.robax.rax_5);
        output := output + Encode2String(jointsout.robax.rax_6);
        
        
        
        
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
        TEST target
        CASE 1:
            DO10_1 := value;
        CASE 2:
            DO10_2 := value;
        CASE 3:
            DO10_3 := value;
        CASE 4:
            DO10_4 := value;
        ENDTEST
    ENDPROC
    
    
    FUNC num Decode2Bytes(string chars)
        ! this function takes in a string of length 2 and then returns its CHAR representation of that string
        VAR byte data_buffer{5};
        VAR string big := "";
        
        VAR string little := "";
        VAR num bigNum := 0;
        VAR num littleNum := 0;
        VAR num result := 0;
        big := StrPart(chars,2,1);
        little := StrPart(chars,1,1);
        bigNum := StrToByte(big\Char);
        littleNum := StrToByte(little\Char);
        
        result := bigNum *255 + littleNum;
        result := result*180/pi;
        RETURN result;
    ENDFUNC
    
    FUNC string Encode2String(num in)
        ! this function takes in a numerical value 0-65535 and then returns a 2 byte charstring that represents that value
        VAR string out;
        VAR string a;
        VAR string b;
        VAR num last;
        VAR num first;
        !in := round((in/360)*Pow(2, 16)-1);
        in := in/360;
        in := round(in * 65535);
        last := in MOD 256;
        first := Round((in-last)/256);
        out := ByteToStr(first\Hex) +  ByteToStr(last\Hex); 
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
        SocketAccept welcome_socket, client_socket \Time:=WAIT_MAX;
        
        ! Close the welcome socket, as it is no longer needed.
        SocketClose welcome_socket;
        
    ENDPROC
    
    ! Close the connection to the client.
    PROC CloseConnection()
        SocketClose client_socket;
    ENDPROC
    

ENDMODULE
