function depthMin = generateDepthData(definedTxt, savepath, chunksz, imageSize, labelSize, sampleNumPerImage, partType, meanImage)
% chunksz, 32 for train, 8 for test
% sampleNumPerImage, sample count sampled from per image
% partType, 0 for the former half of definedTxt as data, 1 for the latter
%half,2 for all
    [imageNameArray,depthNameArray] = ReadDefinationFile(definedTxt);
    num = length(imageNameArray);
    
    if partType == 0
        firstImageNo = 1;
        lastImageNo = floor(num/2);
        
    end
    if partType == 1
        firstImageNo = floor(num/2)+1;
        lastImageNo = num;
    end
    if partType == 2
        firstImageNo = 1;
        lastImageNo = num;
    end

    %uncode depth and resize data
    imageData = zeros(imageSize(1), imageSize(2), 3, 1);
    depthData = zeros(labelSize(1), labelSize(2), 1, 1);
    dataCount = 0;
    
    meanImagers = imresize(meanImage,3/4);
    for indx = firstImageNo:lastImageNo
        imagepath = char(imageNameArray{indx});
        depthpath = char(depthNameArray{indx});

        img = imread(imagepath);
        imgrs = imresize(img,3/4);
        codeDepth = imread(depthpath);
        depthMap = DepthMaskTest(UnCodeDepthImage(codeDepth),50000,50000); %depth over 50000 cm is regularized to 50000cm
        depthMapres = imresize(depthMap,3/4);

        imgrs = im2double(single(imgrs)-meanImagers);
        depthMapres = depthMapres/100; % convert depth to [0 500]

        [hei, wei,~] = size(imgrs);

        for i = 1:sampleNumPerImage
            offsetH = randi(hei-imageSize(1)-1,1)+1;
            offsetW = randi(wei-imageSize(2)-1,1)+1;

            imgcrop = imgrs(offsetH:offsetH+imageSize(1)-1, offsetW:offsetW+imageSize(2)-1, :);
            depthcrop = imresize(depthMapres(offsetH:offsetH+imageSize(1)-1, offsetW:offsetW+imageSize(2)-1, :), labelSize, 'bicubic');


            %imgrs = imresize(img, imageSize, 'bicubic');
            %depthmaprs = imresize(depthMap, labelSize, 'bicubic');
            dataCount = dataCount + 1;
            imageData(:,:,:,dataCount) = imgcrop;
            depthData(:,:,1,dataCount) = depthcrop;
        end

        display(['indx:',num2str(indx)]);
        %figure,imshow(imgrs);
        %figure,imshow(depthmaprs,[]);
    end

    %shuffle data
    order = randperm(dataCount);
    imageData = imageData(:, :, :, order);
    depthData = depthData(:, :, 1, order); 

    %write h5df file
    created_flag = false;
    totalct = 0;

    for batchCount = 1:floor(dataCount/chunksz)
        chunkBase = (batchCount-1)*chunksz;
        imgs = imageData(:,:,:,chunkBase+1:chunkBase+chunksz);
        depths = depthData(:, :, 1, chunkBase+1:chunkBase+chunksz); 

        startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,1,1,totalct+1]);
        curr_dat_sz = store2hdf5(savepath, imgs, depths, ~created_flag, startloc, chunksz);
        created_flag = true;
        totalct = curr_dat_sz(end);
    end

    h5disp(savepath);
end