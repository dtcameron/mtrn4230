function out = detectBlocks(rgb)
    blockSize = 54;

    % Erase the background
    rgb(1:220, :, :) = 80;
    
    %find the properties of hte blocks
    [centroids, colors, shapeM, img] = findBlocks(rgb);
    angBlock = detectOrientation(centroids, img, blockSize);
    [shapes, letters, angBlock] = detectSymbol(centroids, angBlock, colors, shapeM, blockSize);

    % Fix the letter angles if they're out of range 180 to -180
    angBlock = wrapAngles(angBlock);

    % Reachability
    reachable = isReachable(centroids);
    out = sortrows([centroids, angBlock, colors, shapes, letters, reachable]);
    
end

%-------------------------BLOCK DETECTION ------------------------
function [centroids, colors, shapeMasks, img] = findBlocks(rgb)
    %this function will: find the block centroid
    %                    segment the block 
    %                    return single blocks for NN
    
    hsv = rgb2hsv(rgb);
    xyz = rgb2xyz(rgb);

    % array of filter anonymous functions  -> for later
    filters = {2, @orangeM, 300, 1749, 55;
        3, @yellowM, 300, 1749, 55;
        4, @greenM, 300, 1749, 55;
        5, @blueM, 300, 1749, 55;
        6, @purpM, 300, 1749, 55;
        1, @redM, 300, 1749, 55;
        0, @whiteM, 150, 1199, 45};

    canvas = true(1200, 1600);
    numFilt = size(filters, 1);
    masks = false(numFilt, 1200, 1600);
    shapeMasks = false(numFilt, 1200, 1600);
    blocks = double.empty(0, 4);
    
    for i = 1:numFilt
        % see what blocks each filter detects, compile them together and
        % remove all the random ass shit
        maskFunctions = filters{i, 2};
        masks(i, :, :) = canvas & maskFunctions(hsv, xyz);
        shapeMasks(i, :, :) = bwareafilt(squeeze(masks(i, :, :)), [filters{i, 3}, filters{i, 4}]) & bwpropfilt(squeeze(masks(i, :, :)), 'MajorAxisLength', [0, filters{i, 5}]);
        canvas = canvas & ~imdilate(squeeze(shapeMasks(i, :, :)), strel('disk', 3, 4));
        regions = regionprops('table', squeeze(shapeMasks(i, :, :)), 'Centroid');
        numRegions = size(regions, 1);
        if size(regions, 1) > 0
            newBlock = [table2array(regions(:, 1)), repmat(filters{i, 1}, numRegions, 1), vecnorm(table2array(regions(:, 1)) - [800, 600], 2, 2)];
            blocks = [blocks; newBlock];
        end
    end

    blocks = sortrows(blocks, 4, 'descend');
    
   % remove all the random ass shit (dots from the grid)
    img = ~(canvas & squeeze(masks(7, :, :)));
    img = imclose(img, strel('disk', 5, 4));
    img = imopen(img, strel('disk', 5, 4));

    centroids = blocks(:, 1:2);
    colors = blocks(:, 3);
end

function block = isolateBlock(img, centroid, rot, blockSize)
    %cut an area around the block
    
    winSize = blockSize * sqrt(2);
    img = padarray(img, ceil([winSize / 2, winSize / 2]));
    
    
    rotated = imrotate(imcrop(img, [centroid, winSize, winSize]), rot);
    
    offCut = (size(rotated) - blockSize) / 2;
    block = imcrop(rotated, [offCut(1:2), blockSize, blockSize]);
    
end

%------------------------ BLOCK FEATURE EXTRACT ----------------------
function orient = detectOrientation(centroids, blocksArea, blockSize)
    %find the orientation of a block
    orient = zeros(size(centroids, 1), 1);
    

    for i = 1:size(centroids, 1)
        %try 3 orient and narrow it down slowly until the one with the
        %most non zero (i.e. most block) is found, and keep that one
        
        % if its a square it hsould theoretically fit the whole
        %thing we crop out
        
        pass1 = 30;
        
        anonFunc = @(x) nnz(isolateBlock(blocksArea, centroids(i, :), x, blockSize));
        angles = [-pass1 0 pass1];
        [~, index] = max(arrayfun(anonFunc, angles));
        
        angles = angles(index) - 10:10:angles(index) + 10;
        [~, index] = max(arrayfun(anonFunc, angles));
        
        angles = angles(index) - 3:3:angles(index) + 3;
        [~, index] = max(arrayfun(anonFunc, angles));
        
        angles = angles(index) - 1:1:angles(index) + 1;
        [~, index] = max(arrayfun(anonFunc, angles));
        
        
        orient(i) = angles(index);
       
        %create a square that is perfectly sized, and rotate using orientation the
        %found
        squareMask = true(blockSize, blockSize);
        squareMask = imrotate(squareMask, -orient(i));
        sizeMask = size(squareMask);
        
        mask = false(size(blocksArea));
        mask(1:sizeMask(1), 1:sizeMask(2)) = squareMask;
        mask = imtranslate(mask, centroids(i, :) - sizeMask / 2);
        
        %add to the canvas
        blocksArea = blocksArea & ~mask;
    end
end

function [shapes, letters, orientOut] = detectSymbol(centroids, orient, colors, shapeM, blockSize)
    % finds whatever is on the block
    
    shapes = zeros(size(centroids, 1), 1);
    letters = zeros(size(centroids, 1), 1);
    angles = zeros(size(centroids, 1), 1);

    colorMaskArr = [7, 6, 1, 2, 3, 4, 5];

    masks = shapeM(colorMaskArr(colors + 1), :, :);

    shalf = sqrt(1/2);
    sthreeq = sqrt(3/4);
    
    shapeT = [shalf, sthreeq, 1,   sthreeq, shalf, sthreeq, 1, sthreeq;         %square
                       1,     sthreeq, shalf, sthreeq, 1, sthreeq, shalf, sthreeq;       
                       1, 1, 1, 1, 1, 1, 1, 1;                                           
                       1, sthreeq, 1/2, sthreeq, 1, sthreeq, 1/2, sthreeq;
                       1/2, sthreeq, 1, sthreeq, 1/2, sthreeq, 1, sthreeq;
                       1, 3/4, 1, 3/4, 1, 3/4, 1, 3/4];

    coords = createShapeAutis();

    for i = 1:size(centroids, 1)
        if (colors(i) ~= 0) % if its a colour block
            shapes(i) = detectShape(isolateBlock(squeeze(masks(i, :, :)), ...
                                    centroids(i, :), orient(i), blockSize), shapeT, coords);
        else %it's a letter
            [letters(i), angles(i)] = detectLetter(isolateBlock(squeeze(masks(i, :, :)), ....
                                      centroids(i, :), orient(i), blockSize - 10));
        end
    end
    
    orientOut = orient + angles;
end

function [letter, angle] = detectLetter(blockImg)
    % USE OCR - to determine which orientation has the best confidence, and
    % use that to determine the final rotation.
    % rotates in 90 degree angles
    
    % Also finds the best letter
    alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    letter = 'A';
    angle = 0;
    bestConf = 0;
    
    for rot = 0:90:270
        ocrDetails = ocr(blockImg, 'TextLayout', 'Word', 'CharacterSet', alphabet);
        [conf, ind] = max(ocrDetails.CharacterConfidences);
        if conf > bestConf
            letter = ocrDetails.Text(ind);
            angle = rot;
            bestConf = conf;
        end
        blockImg = rot90(blockImg);
    end

    letter = double(letter) - double('A') + 1;
end

function [shape] = detectShape(blockImg, shapeTemp, coord)
    crossSect = cellfun(@(x) sum(improfile(bwareafilt(blockImg, 1), x(1:2), x(3:4), 50)), coord)';
    shape = knnsearch(shapeTemp, crossSect / max(crossSect));
end

function reachable = isReachable(centroids)
    origin = [805, 26];
    reach = 832.4;
    
    reachable = vecnorm(centroids - origin, 2, 2) < reach;
end

function angBlock = wrapAngles(angBlock)
    angBlock(angBlock >= 180) = angBlock(angBlock >= 180) - 360;
    angBlock(angBlock < -180) = angBlock(angBlock < -180) + 360;
    angBlock = deg2rad(angBlock);
end

%--------------------------- NEURAL NETWORK ----------------------------------

function [colourCNN, letterCNN, shapeCNN] = importCNNs()

    colourCNN = load('colourCNN.mat', 'colourCNN');
    colourCNN = colourCNN.colourCNN;
    
    letterCNN = load('letterCNNBin.mat', 'letterCNN');
    letterCNN = letterCNN.letterCNN;
    
    shapeCNN = load('shapesCNN.mat', 'shapeCNN');
    shapeCNN = shapeCNN.shapeCNN;
    
end

function colour = classifyColour(CNN, block)
    colour = classify(CNN, block);
    colour = string(colour);
    colour = regexp(colour, '\d\d?', 'match');
end

function shape = classifyShape(CNN, block)
    shape = classify(CNN, block);
    shape = string(shape);
    shape = regexp(shape, '\d\d?', 'match');
end

function letter = classifyLetter(CNN, block)
    letter = classify(CNN, block);
    letter = string(letter);
    letter = regexp(letter, '\d\d?', 'match');

end

% ------------------------- IMAGE MASKS -------------------------------
% Letter Block
function [BW,maskedRGBImage] = binaryLBlockMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 27-Aug-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.000;
channel1Max = 1.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 0.224;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.654;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
% Shape Block / Red Blue Yellow Orange
function [BW,maskedRGBImage] = binaryRBYOBlockMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App. The colorspace and
%  minimum/maximum values for each channel of the colorspace were set in the
%  App and result in a binary mask BW and a composite image maskedRGBImage,
%  which shows the original RGB image values under the mask BW.

% Auto-generated by colorThresholder app on 09-Sep-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.000;
channel1Max = 1.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.264;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.322;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
% Shape Block / Green Purple
function [BW,maskedRGBImage] = binaryGPBlockMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App. The colorspace and
%  minimum/maximum values for each channel of the colorspace were set in the
%  App and result in a binary mask BW and a composite image maskedRGBImage,
%  which shows the original RGB image values under the mask BW.

% Auto-generated by colorThresholder app on 09-Sep-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.252;
channel1Max = 0.867;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.098;
channel2Max = 0.404;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.244;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
% Shape Block / Green
function [BW,maskedRGBImage] = binaryGBlockMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App. The colorspace and
%  minimum/maximum values for each channel of the colorspace were set in the
%  App and result in a binary mask BW and a composite image maskedRGBImage,
%  which shows the original RGB image values under the mask BW.

% Auto-generated by colorThresholder app on 09-Sep-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.246;
channel1Max = 0.412;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.544;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.167;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end
% Letter Block Outline
function [BW,maskedRGBImage] = binaryLOutlineMask(RGB)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder App. The colorspace and
%  minimum/maximum values for each channel of the colorspace were set in the
%  App and result in a binary mask BW and a composite image maskedRGBImage,
%  which shows the original RGB image values under the mask BW.

% Auto-generated by colorThresholder app on 09-Sep-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.000;
channel1Max = 1.000;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.000;
channel2Max = 1.000;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.204;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
BW = sliderBW;

% Initialize output masked image based on input image.
maskedRGBImage = RGB;

% Set background pixels where BW is false to zero.
maskedRGBImage(repmat(~BW,[1 1 3])) = 0;

end

% ------------------------ HELPER FUNCTIONS -------------------------------

function x = vecnorm(x,dim,p)
%VECNORM    Returns vector norms
%
%    Usage:    m=vecnorm(x)
%              m=vecnorm(x,dim)
%              m=vecnorm(x,dim,p)
%
%    Description:
%     M=VECNORM(X) returns the vector L2 norms for X down its first
%     non-singleton dimension.  This means that for vectors, VECNORM and
%     NORM behave equivalently.  For 2D matrices, VECNORM returns the
%     vector norms of each column of X.  For ND matrices, M has equal
%     dimensions to X except for the first non-singleton dimension of X
%     which is size 1 (singleton).  So for X with size 3x3x3, M will be
%     1x3x3 and corresponds to norms taken across the rows of X so
%     M(1,2,2) would give the norm for elements X(:,2,2).
%
%     M=VECNORM(X,DIM) returns the vector L2 norms for matrix X across
%     dimension DIM.
%
%     M=VECNORM(X,DIM,P) specifies the norm length P.  The default is 2.
%
%    Notes:
%     - Note that NORM is an internal function so it is significantly
%       faster than VECNORM (basically if you can, use NORM).
%
%    Examples:
%     % Show the L2 norms of each row and column for a matrix:
%     vecnorm(magic(5),1)
%     vecnorm(magic(5),2)
%
%    See also: NORM

%     Version History:
%        Nov. 12, 2009 - initial version
%        Feb. 10, 2012 - doc update
%
%     Written by Garrett Euler (ggeuler at wustl dot edu)
%     Last Updated Feb. 10, 2012 at 05:45 GMT

% todo:

% default dimension
if(nargin==1 || isempty(dim))
    dim=find(size(x)~=1,1);
    if(isempty(dim)); dim=1; end
end

% check dimension
if(~isscalar(dim) || dim~=fix(dim))
    error('seizmo:vecnorm:badDim','DIM must be a scalar integer!');
end

% default norm length
if(nargin<3 || isempty(p)); p=2; end

% check norm length
if(~isscalar(p) || ~isreal(p))
    error('seizmo:vecnorm:badP','P must be a scalar real!');
end

% get norm
if(p==inf)
    x=max(abs(x),[],dim);
elseif(p==-inf)
    x=min(abs(x),[],dim);
else
    x=sum(abs(x).^p,dim).^(1/p);
end

end

function autis = createShapeAutis()
    c = 27;
    r = 24;
    
    a = (0:pi/8:7*pi/8)';
    autis = num2cell([c + r*cos(a), c - r*cos(a), c + r*sin(a), c - r*sin(a)], 2);
end

%--------------------------- IMAGE MASKS ----------------------------------
function white = whiteM(~, xyz)
    white = imclose(bwareaopen(xyz(:, :, 1) >= 0.281233, 10), strel('disk', 2, 4));
end

function orange = orangeM(hsv, ~)
    orange = hsv(:, :, 1) < 1/12 & hsv(:, :, 2) >= 1/5 & hsv(:, :, 3) >= 1/4;
end

function yellow = yellowM(hsv, ~)
    yellow = hsv(:, :, 1) >= 1/12 & hsv(:, :, 1) < 5/24 & hsv(:, :, 2) >= 1/2 & hsv(:, :, 3) >= 1/2;
end

function green = greenM(hsv, ~)
    green = hsv(:, :, 1) >= 5/24 & hsv(:, :, 1) < 1/2 & hsv(:, :, 2) >= 1/12 & hsv(:, :, 3) >= 1/8;
end

function blue = blueM(hsv, ~)
    blue = hsv(:, :, 1) >= 1/2 & hsv(:, :, 1) < 2/3 & hsv(:, :, 2) >= 1/8 & hsv(:, :, 3) >= 1/8;
end

function purple = purpM(hsv, ~)
    purple = hsv(:, :, 1) >= 2/3 & hsv(:, :, 1) < 5/6 & hsv(:, :, 2) >= 1/8 & hsv(:, :, 3) >= 1/8;
end

function red = redM(hsv, ~)
    red = (hsv(:, :, 1) >= 11/12 | hsv(:, :, 1) < 1/24) & hsv(:, :, 2) >= 1/5 & hsv(:, :, 3) >= 1/4;
end