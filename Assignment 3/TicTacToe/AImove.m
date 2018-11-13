%% Minimax Algorithm implementation
function [bestchild, bestscore] = AImove(elem,player,depth)
bestchild = [];

winflag = gamewinflag(elem);
if (winflag || depth == 0)
    bestscore = finalev(elem,player,depth);
else
    if (player)
        bestscore = -inf;
    else
        bestscore = inf;
    end
    childboard = makechildboard(elem,player);
    temp = 1;
    reqsize = size(childboard,2)/3;
    while temp <=reqsize
        childboard1 = childboard(:,(3*temp - 2): 3*temp);
        presentscore = AImove(childboard1,~player, depth-1);
        if (player)
            if(bestscore<presentscore)
                bestscore = presentscore;
                bestchild = childboard1;
            end
        else
            if(bestscore>presentscore)
                bestscore = presentscore;
                bestchild = childboard1;
            end
        end
        temp = temp + 1;
    end
    
end
        
end


%% Function definitions
function bestscore = finalev(elem,player,depth)
[winflag,winningplayer] = gamewin(elem);
b = -1;
x = 2;
o = 1;
if winningplayer == b
    score = 0;
elseif winningplayer == x
    score = 10 + depth;
else
    score = -10-depth;
end
bestscore = score;

end

function childboard = makechildboard(elem,player)
rowm = 3;
colm = 3;
rowc = 1;
childboard = [];
while rowc <= rowm
    colc = 1;
    while colc <= colm
        if (elem(rowc,colc) == b)
            dboard = elem;
            dboard(rowc,colc) = player;
            childboard = [childboard,dboard];
        end
        colc = colc+ 1;
    end
    rowc = rowc + 1;
end

   
end


function winflag = gamewinflag(elem)
[winflag,bleh] = gamewin(elem);
end