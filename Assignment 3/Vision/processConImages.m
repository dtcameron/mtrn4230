    conImg = imread('conIm9.jpg');

    figure(2)
    imshow(conImg);
    
        %converyer ROI is in x 520 to 1220, y 0 to 700
    conImg(700:end, :) = 0;
    conImg(:, 1:520,:) = 0;
    conImg(:, 1220:end ,:) = 0;
    
        hsv = rgb2hsv(conImg);
    xyz = rgb2xyz(conImg);
    
    
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
    end
    
    


        
%     BWconImg = whiteM(0, conImg);
    

    figure(3)
    imshow(canvas);
    
function white = whiteM(~, xyz)
%     white = imclose(bwareaopen(xyz(:, :, 1) >= 0.281233, 134), strel('disk', 2, 4));
    white = imclose(bwareafilt(xyz(:, :, 1) >= 0.281233, [50 500]), strel('disk', 2, 4));
    white = imerode(white, ones(3));
    white = imdilate(white, ones(5));
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

function red = redM(RGB, ~)
%createMask  Threshold RGB image using auto-generated code from colorThresholder app.
%  [BW,MASKEDRGBIMAGE] = createMask(RGB) thresholds image RGB using
%  auto-generated code from the colorThresholder app. The colorspace and
%  range for each channel of the colorspace were set within the app. The
%  segmentation mask is returned in BW, and a composite of the mask and
%  original RGB images is returned in maskedRGBImage.

% Auto-generated by colorThresholder app on 02-Nov-2018
%------------------------------------------------------


% Convert RGB image to chosen color space
I = rgb2hsv(RGB);

% Define thresholds for channel 1 based on histogram settings
channel1Min = 0.903;
channel1Max = 0.062;

% Define thresholds for channel 2 based on histogram settings
channel2Min = 0.244;
channel2Max = 0.667;

% Define thresholds for channel 3 based on histogram settings
channel3Min = 0.518;
channel3Max = 1.000;

% Create mask based on chosen histogram thresholds
sliderBW = ( (I(:,:,1) >= channel1Min) | (I(:,:,1) <= channel1Max) ) & ...
    (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
    (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
red = sliderBW;


end
