img = imread('tabIm7.jpg');

figure(1)
imshow(img);

blockProp = detectBlock(img);

hold on
plot(blockProp(:,1), blockProp(:,2), 'g+');
%plot(blockPropsTest(:,1), blockPropsTest(:,2), 'b*');
hold off

[boardBlockInfo, OG] = centroidToBoardBP(blockProp);
[P1Info, deckP1] = centroidToP1Deck(blockProp);
[P2Info, deckP2] = centroidToP2Deck(blockProp);

%--------------------------------------------------------------

