img = imread('tabIm7.jpg');

figure(1)
imshow(img);

blockSpace = 55;

x0 = 550; y0 = 286;
x1 = 1048; y1 = 781;

gridX = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 9));
gridY = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 9));
%--------------------------------------------------------------------

x0 = 419; y0 = 286;
x1 = 474; y1 = 616;

gridP1X = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 1));
gridP1Y = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 6));
%----------------------------------------------------------------------

x0 = 1125; y0 = 288;
x1 = 1180; y1 = 621;

gridP2X = round(linspace(x0 + blockSpace/2, x1 - blockSpace/2, 1));
gridP2Y = round(linspace(y0 + blockSpace/2, y1 - blockSpace/2, 6));