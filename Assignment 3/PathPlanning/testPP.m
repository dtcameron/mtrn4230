function Opath = testPP()
close all;
MAP = [ 2  2  2  2  2  2  2  2  2
       -1  2  2  2  2  2  2  2  2
       -1 -1 -1 -1 -1 -1 -1  2 -1
       -1  2  2  2  2  2  2  2 -1
       -1  2 -1 -1 -1 -1 -1  2 -1
       -1  2  2  2 -1  2  2  2  2
        2 -1  2 -1 -1 -1 -1 -1 -1
        2 -1  2  2  2  2  2  2  2
        2 -1  2  2  2  2  2  2  2]';
Opath = pathplanning(MAP, 1, 1, 8, 9);
end