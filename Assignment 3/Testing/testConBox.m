conImg = imread('conIm6.jpg');

figure(2)

imshow(conImg);
[lines, ~, ~] = detectConBox(conImg);

hold on 
    
for k = 1:length(lines)
       xy = [lines(k).point1; lines(k).point2];
       plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');

       % Plot beginnings and ends of lines
       plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
       plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');

end

hold off

gridX = linspace(lines(1).point1(1), lines(2).point1(1), 5);
conGridX = gridX(2:end-1);
conGridY = linspace(lines(1).point1(2), lines(1).point2(2), 7);

