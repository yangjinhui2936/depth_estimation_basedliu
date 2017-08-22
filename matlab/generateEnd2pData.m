function generateEnd2pData(definedTxt, savepathNoExten, spSize, sampleNumPerImage,imageSize, dpScale, dpBais, fileSelector)
%fileSelector: [startNo setp maxNum]

[imageNameArray,depthNameArray] = ReadDefinationFile(definedTxt);
%savepath = 'train_city7_10.h5';
%sampleNumPerImage = 950;
%spSize = 32;
totalImagNum = length(imageNameArray);

firstImageNo = fileSelector(1);
imgeStep = fileSelector(2);
imageChunksz = fileSelector(3);

dataFileCount = totalImagNum/(imgeStep*imageChunksz);

%imageSize = [224 224];

imageData = zeros(imageSize(1), imageSize(2), 3, sampleNumPerImage, 10); 
depthData = zeros(1, sampleNumPerImage, 10);

firstNo = firstImageNo;
endNo = firstImageNo + imgeStep*imageChunksz;

for  fileIndx = 1:dataFileCount
    savepath = [savepathNoExten,'_',num2str(fileIndx),'.h5'];
    
    count = 0;
    imgWithBorder = zeros(800+imageSize(1),1200+imageSize(2),3);
    for indx = firstNo:imgeStep:endNo
        imagepath = char(imageNameArray{indx});
        depthpath = char(depthNameArray{indx});

        img = imread(imagepath);

        codeDepth = imread(depthpath);
        depthMap = DepthMaskTest(UnCodeDepthImage(codeDepth),80,80,20000,20000); %depth over 20000 cm is regularized to 20000

        %img = im2double(img);
        depthMap = depthMap/100; % use meter as measurement
        depthMap = (log10(depthMap)-dpBais)/dpScale; %normalize depth to [0 1]

        tic

        sp_info=gen_supperpixel_info(img, spSize);
        sp_num = sp_info.sp_num;
        centroids = ComputeSpCentroid(sp_info);
        img_size = sp_info.img_size;

        %img = single(img) - 128;
        img = im2double(img); %normalize

        imgWithBorder(imageSize(1)/2+1:img_size(1)+imageSize(1)/2, imageSize(2)/2+1:img_size(2)+imageSize(2)/2, :) = img;

        imgWithBorder(1:imageSize(1)/2, :, :) = imgWithBorder(imageSize(1):-1:imageSize(1)/2+1, :, :);
        imgWithBorder(img_size(1)+imageSize(1)/2 + 1:img_size(1)+imageSize(1), :, :) =...
                imgWithBorder(img_size(1)+imageSize(1)/2:-1:img_size(1)+1, :, :);
        imgWithBorder(:, 1:imageSize(2)/2, :) = imgWithBorder(:, imageSize(2):-1:imageSize(2)/2+1, :);
        imgWithBorder(:, img_size(2)+imageSize(2)/2+1:img_size(2)+imageSize(2), :) =...
                imgWithBorder(:, img_size(2)+imageSize(2)/2:-1:img_size(2)+1, :);   

        count = count+1;
        for i = 1:sampleNumPerImage

            if sp_num >= i
                centerX = centroids(i,1);
                centerY = centroids(i,2);
            else
                temp = randi(sp_num);
                centerX = centroids(temp,1);
                centerY = centroids(temp,2);
            end

            imgcrop = imgWithBorder(centerY+1:centerY+imageSize(1), centerX+1:centerX+imageSize(2), :);
            depthcrop = depthMap(centerY, centerX);
            imageData(:,:,:,i,count) = imgcrop;
            depthData(:,i,count) = depthcrop;

        end
        disp(['image No. ',num2str(indx),' done..']);
        toc

    end

	%shuffle data
	order = randperm(count);
	imageData = imageData(:, :, :, :, order);
	depthData = depthData(:, :, order); 

    %write h5df file
	created_flag = false;
	totalct = 0;

     for batchCount = 1:count
         imgs = imageData(:, :, :, :, batchCount);
         depths = depthData(:, :, batchCount); 

         startloc = struct('dat',[1,1,1,totalct+1], 'lab', [1,totalct+1]);
         curr_dat_sz = store2hdf5(savepath, imgs, depths, ~created_flag, startloc, sampleNumPerImage);
         created_flag = true;
         totalct = curr_dat_sz(end);
     end

      h5disp(savepath);
    end

    firstNo = endNo + imageChunksz; %should be +imgeStep
    endNo = firstNo + imgeStep*imageChunksz;
    %reset h5df file writing options
    created_flag = false;
    totalct = 0;
end