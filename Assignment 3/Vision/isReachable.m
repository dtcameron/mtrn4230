function reachable = isReachable(centroid)
%   function reachable = isReachable(centroid)
%       Checks if a centroid is reachable by the robot or not by measuring
%       distance between the robot and the centroid, seeing if the arm is
%       long enough
%
%       INPUT: centroid
%              a double [x y] coordinate pair 
%
%       OUTPUT: reachable
%              boolean 0 or 1 depending on distnace

    origin = [805, 26];
    reach = 832.4;
        
    if hypot(centroid(1) - origin(1), centroid(2) - origin(2)) < reach
        reachable = 1;
    else
        reachable = 0;
    end
end