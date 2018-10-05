% An example of how your function will be called, and what it should
% output.
% image_file_path is the absolute path to the image that you should
% process. This should be used to read in the file.
% image_file_name is just the name of the image. This should be written to
% the output file.
% output_file_path is the absolute path to the file where you should output
% the name of the file as well as the blocks that you have detected.
% program_folder is the folder that your function is running in.
% Your block detection.
function out = detectBlocks(img)
    

    [colourCNN, letterCNN, shapeCNN, binLetterCNN] = importCNNs();

    % find centroids
    [centroidL, areaBoxL, orientationL, maskedLImg, letterType] = detectLetterBlocks(img);
    [centroidS, areaBoxS, orientationS, maskedSImg, shapeType] = detectShapeBlocks(img);

    %debugging NOT IN USE
    types = [letterType; shapeType];
    bounds = [areaBoxL; areaBoxS];

    % make sure their going left to right
    centroids = sortrows([[centroidL; centroidS] types], 1,'ascend');

    oor = find(centroids(:,2) < 220);
    centroids(oor,:) = [];

    types = centroids(:, 3);
    centroids = centroids(:, 1:2);
    out = [];

    for i = 1:size(centroids(:,1))
        %angle finding
        block = isolateBlock(centroids(i,:), img);

        angle = blockAngle(block, centroids(i,:));
               
        %block classification
        try
        colour = str2double(classifyColour(colourCNN, block));
        catch
            colour = 0;
        end

        if ((colour ~= 0) && (types(i) == 1)) % if its a colour block
            try
            shape = str2double(classifyShape(shapeCNN, block));
            catch
            shape = 1;
            end
            
            letter = 0;

        else %it's a letter
            colour = 0;
            shape = 0;
            
            try
            letter = str2double(classifyLetter(letterCNN, block));
            catch
            letter = 'A';
            end
        end

        %reachability
        reachable = isReachable(centroids(i,:));

        blockOut = [centroids(i,1) centroids(i,2) angle ...
                  colour shape letter reachable];
        out = [out; blockOut];


        %alph(binLetter)
    end

end


% This is an example of how to write the results to file.
% This will only work if you store your blocks exactly as above.
% Please ensure that you output your detected blocks correctly. A
% script will be made available so that you can run the comparison
% yourselves, to test that it is working.

%------------------------ BLOCK FEATURE EXTRACT ----------------------

function block = isolateBlock(centroid, img)
    % crops a block from the image and returns: 
    % 77x77x3 picture of block and surroundings


    cropBound = [centroid(1) - 38, centroid(2) - 38, ...
                        76       ,          76     ];
    
    block = imcrop(img, cropBound);
    
    try
    if ~isequal(size(block), [77 77 3])
        block = imresize(block, [77 77]);
    end
    catch  
    end
    
end

function angle = blockAngle(block, centroid)
    % finds the orientation of a block

    binaryBlockImg = binaryLOutlineMask(block);
    
    binaryEdge = edge(binaryBlockImg, 'canny');
    [outX,outY] = find(binaryEdge == 1);
    
    block(:,:,:) = 0;
    
    for i = 1:size(outX,1)
        block(outX(i),outY(i), 1)  = 0;
        block(outX(i),outY(i), 2)  = 0;
        block(outX(i),outY(i), 3)  = 255;
    end
    
    block = rgb2gray(block);
    block = imbinarize(block);

    [H, T, R] = hough(block);
    peaks = houghpeaks(H, 5);
    lines = houghlines(block, T, R, peaks, 'MinLength', 15);
    
    bestD = Inf;
    
    for i = 1:size(lines, 2) %for each line
        
        % PERPINDICULAR DISTANCE FINDING
        % find the equation of the line
        x = [lines(i).point1(1) lines(i).point2(1)];
        y = [lines(i).point1(2) lines(i).point2(2)];
        
        X = 38;
        Y = 38;
        
        if (x(1) ~= x(2))
            c = [[1; 1]  x(:)]\y(:);
            m = c(2);
            b = c(1);

            A = m;
            B = -1;
            C = b;

            ad = (abs(A*X + B*Y + C))/sqrt(A*A + B*B);
        else
            ad = abs(X-x(2));
        end
        
        if (abs(23 - ad) < abs(23 - bestD))
            bestD = ad;
            bestInd = i;
            angle = lines(bestInd).theta;
        end
               
        %wrap to 45 degrees
        if angle > 45 
           angle = angle - 90;
        elseif angle < -45
           angle = angle + 90; 
        end
        
%         %plot
%         figure(2), imshow(block), hold on
%  
%         xy = [lines(i).point1; lines(i).point2];
%         plot(xy(:,1),xy(:,2), 'LineWidth', 2,'Color','green');
%          
%         plot(xy(1,1),xy(1,2), 'LineWidth', 2,'Color','yellow');
%         plot(xy(2,1),xy(2,2), 'LineWidth', 2,'Color','red');
%        
    end

    angle = angle * pi/180;
    
end

function reachable = isReachable(centroid)
    origin = [805, 26];
    reach = 832.4;
        
    if hypot(centroid(1) - origin(1), centroid(2) - origin(2)) < reach;
        reachable = 1;
    else
        reachable = 0;
    end
end

%-------------------------BLOCK DETECTION ------------------------

function [centroids, areaBox, orientation, maskedImg, type] = detectLetterBlocks(img)
    %this function will: find the block centroid
    %                    segment the block 
    %                    return single blocks for NN
    % NOTE ITS ONLY FOR LETTER BLOCKS


%convert into relevant colour spaces
    imgRGB =  img;

    %first detect the blocks and their properties themselves
%   This is done by binarizing/filtering the image
     binaryBlockImg = binaryLBlockMask(imgRGB);
        
    %binaryBlockImg = GaussianFilter(binaryBlockImg, 3, 5); %gaussian fulters
    binaryBlockImg = bwareaopen(binaryBlockImg, 50);
    binaryBlockImg = imerode(~binaryBlockImg, ones(4));
    binaryBlockImg = imdilate(binaryBlockImg, ones(5));
    binaryBlockImg = ~binaryBlockImg;
    %bwfilt to keep things in a range
    maskedImg = binaryBlockImg;


    %find the properties of the qwirkle blocks
    blocks = regionprops(binaryBlockImg, 'Area', 'BoundingBox', ...
                         'Centroid', 'Image', 'Orientation');
    centroids = [];
    areas = [];
    areaBox = [];
    orientation = [];
    type = [];
    
    for i = 1:size(blocks,1)
        if (blocks(i).Area < 800 && blocks(i).Area > 100)  
            centroids = [centroids; blocks(i,:).Centroid];
            areas = [areas blocks(i).Area];
            areaBox = [areaBox; blocks(i).BoundingBox];
            orientation = [orientation blocks(i).Orientation]; 
            type = [type; 0]; %letter
        end
    end
    
%     figure(10)
%     imshow(binaryBlockImg)
        
end

function [centroids, areaBox, orientation, maskedImg, type] = detectShapeBlocks(img)
        %this function will: find the block centroid
    %                    segment the block 
    %                    return single blocks for NN
    % NOTE ITS ONLY FOR LETTER BLOCKS


%convert into relevant colour spaces
    imgRGB =  img;
    
%first detect the blocks and their properties themselves
%   This is done by binarizing/filtering the image
     RBYOBlockImg = binaryRBYOBlockMask(imgRGB);
     GPBlockImg = binaryGPBlockMask(imgRGB);
     GBlockImg = binaryGBlockMask(imgRGB);
     
     %OR all the filteres together to get all the shapes (hopefully)
     binaryBlockImg = RBYOBlockImg | GPBlockImg | GBlockImg;

    %binaryBlockImg = GaussianFilter(binaryBlockImg, 3, 5); %gaussian fulters
    binaryBlockImg = bwareaopen(binaryBlockImg, 50);
    binaryBlockImg = imerode(~binaryBlockImg, ones(4));
    binaryBlockImg = imdilate(binaryBlockImg, ones(5));
    binaryBlockImg = ~binaryBlockImg;

    maskedImg = binaryBlockImg;
      
    %find the properties of the qwirkle blocks
    blocks = regionprops(binaryBlockImg, 'Area', 'BoundingBox', ...
                         'Centroid', 'Image', 'Orientation');
    centroids = [];
    areas = [];
    areaBox = [];
    orientation = [];
    type = [];
    
    for i = 1:size(blocks,1)
        if (blocks(i).Area < 2000 && blocks(i).Area > 300)  
            centroids = [centroids; blocks(i,:).Centroid];
            areas = [areas blocks(i).Area];
            areaBox = [areaBox; blocks(i).BoundingBox];
            orientation = [orientation blocks(i).Orientation];
            type = [type; 1];
        end
    end
    
    %debugging - plot the centroids
%     figure(11)
%     imshow(binaryBlockImg)
    
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


% ------------------------ NEURAL NET -------------------------------
function [colourCNN, letterCNN, shapeCNN, binLetterCNN] = importCNNs()

    colourCNN = load('colourCNN.mat', 'colourCNN');
    colourCNN = colourCNN.colourCNN;
    
    letterCNN = load('letterCNNRGB.mat', 'letterCNN');
    letterCNN = letterCNN.letterCNN;
    
    binLetterCNN = load('letterCNNBin.mat', 'letterCNN');
    binLetterCNN = binLetterCNN.letterCNN;
    
    shapeCNN = load('shapeCNN.mat', 'shapeCNN');
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

function letter = classifyBLetter(CNN, block)
    letter = classify(CNN, block);
    letter = string(letter);
    letter = regexp(letter, '\d\d?', 'match');

end