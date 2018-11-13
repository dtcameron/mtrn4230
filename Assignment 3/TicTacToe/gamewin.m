function [winflag, player] = gamewin(board)
% Player will be 1 or 2
%winflag will be set to various values
% 1 -win
% 0 - Still in play
% 2 - Draw
temp = board(:);
for player = 1:2
    
if temp(1)==player && temp(4)==player && temp(7)==player
    winflag = 1; 
elseif temp(3)==player && temp(6)==player && temp(9)==player
    winflag = 1;
elseif temp(1)==player && temp(2)==player && temp(3)==player
    winflag = 1;
elseif temp(4)==player && temp(5)==player && temp(6)==player
    winflag = 1;
    elseif temp(2)==player && temp(5)==player && temp(8)==player
    winflag = 1;
elseif  temp(7)==player && temp(8)==player && temp(9)==player
    winflag = 1;
elseif temp(1)==player && temp(5)==player && temp(9)==player
    winflag = 1;
elseif temp(3)==player && temp(5)==player && temp(7)==player
    winflag = 1;
elseif isempty(min(find(temp==-1)))
    winflag = 2;
else
    winflag = 0;
end
end
end