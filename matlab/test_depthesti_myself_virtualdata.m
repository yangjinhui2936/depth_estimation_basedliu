% Add caffe/matlab to you Matlab search PATH to use matcaffe
if exist('F:/DeepLearning/Caffe/caffe/matlab/+caffe', 'dir')
  addpath('F:/DeepLearning/Caffe/caffe/matlab/');
else
  error('No such direction');
end

caffe.set_mode_gpu();
caffe.set_device(0);

% Initialize the network using trained LeNet for digit image classification
model_dir = 'F:/DeepLearning/Caffe/caffe/examples/Depth_estimation_basedLiu/models/';
net_model = [model_dir 'DepthEst_test_sigmoid_end2p_net.prototxt'];
net_weights = [model_dir, 'Model_sigmoid_combinedtune__iter_13600.caffemodel']; 
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please prepare trained depth estimation model before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

%process images
[imagePathArray1, depthPathArray1, ~, ~] =  ReadDefinationFile('test_city.txt');
[imagePathArray2, depthPathArray2, ~, ~] =  ReadDefinationFile('test_rotate_city.txt');
imagePathArray = {imagePathArray1{:}, imagePathArray2{:}};
depthPathArray = {depthPathArray1{:}, depthPathArray2{:}};

imgNum = length(imagePathArray);

spSize = 16;
imageSize = [112, 112]; %size for every batch
imageResize = [480 640];

fileResult = fopen('test_myself_record_virtualdata.txt','w');
evaRel = 0;
evaRms = 0;
evaLog10 = 0;
evaThr1 = 1.8;
evaThr2 = 1.8^2;
evaThr3 = 1.8^3;
evaThrCount1 = 0;
evaThrCount2 = 0;
evaThrCount3 = 0;

for indx = 1:imgNum
    
    tic
    
    imagePath = char(imagePathArray{indx});
    depthPath = char(depthPathArray{indx});
    
    image = imread(imagePath);
    codeDepth = imread(depthPath); 
    depth = DepthMaskTest(UnCodeDepthImage(codeDepth),80,80,20000,20000); %depth over 20000 cm is regularized to 20000
    depth = depth/100;
    
    %resize data
    image = imresize(image, imageResize);
    depth = imresize(depth, imageResize);
    
    %resize image&depth

    sp_info=gen_supperpixel_info(image, spSize);
    sp_num = sp_info.sp_num;
    centroids = ComputeSpCentroid(sp_info);
    img_size = sp_info.img_size;

    image = im2double(image);

    [hei, wei, chl] = size(image);
    
    imgWithBorder = zeros(hei+imageSize(1),wei+imageSize(2),chl);
    imgWithBorder(imageSize(1)/2+1:img_size(1)+imageSize(1)/2, imageSize(2)/2+1:img_size(2)+imageSize(2)/2, :) = image;

    imgWithBorder(1:imageSize(1)/2, :, :) = imgWithBorder(imageSize(1):-1:imageSize(1)/2+1, :, :);
    imgWithBorder(img_size(1)+imageSize(1)/2 + 1:img_size(1)+imageSize(1), :, :) =...
    imgWithBorder(img_size(1)+imageSize(1)/2:-1:img_size(1)+1, :, :);
    imgWithBorder(:, 1:imageSize(2)/2, :) = imgWithBorder(:, imageSize(2):-1:imageSize(2)/2+1, :);
    imgWithBorder(:, img_size(2)+imageSize(2)/2+1:img_size(2)+imageSize(2), :) =...
    imgWithBorder(:, img_size(2)+imageSize(2)/2:-1:img_size(2)+1, :); 

    dp_est = zeros(1,sp_num);

    imgcrops = zeros(imageSize(1),imageSize(2),3);

    % time to predict depth

    for i = 1:sp_num
    centerIndx = i;

    centerX = centroids(centerIndx,1);
    centerY = centroids(centerIndx,2);

    imgcrops(:,:,:) = imgWithBorder(centerY+1:centerY+imageSize(1), centerX+1:centerX+imageSize(2), :);
    res = net.forward({imgcrops});
    dp_est(i) = res{1};
    end

    dpBais = log10(0.8);
    dpScale = log10(200) - dpBais;

    depthInfo = power(10,(dp_est)*dpScale+dpBais);

    pixel_ind_sps = sp_info.pixel_ind_sps;
    depthMap = zeros(hei, wei);

    for i = 1:sp_num
    depthMap(pixel_ind_sps{i}) = depthInfo(i);
    end


    fprintf('inpaiting using Anat Levin`s colorization code, this may take a while...\n');
    depths_inpaint = do_inpainting(depthMap, uint8(image*255), sp_info);
    
    %evaluate the predicted depth
    pixelNum = length(depths_inpaint(:));
    relTemp = sum(abs(depths_inpaint(:) - depth(:))./depths_inpaint(:)) / pixelNum;
    rmsTemp = sqrt(sum((depths_inpaint(:) - depth(:)).^2) / pixelNum);
    log10Temp = sum(abs(log10(depths_inpaint(:)) - log10(depth(:)))) / pixelNum;
    
    thrVec = max(depths_inpaint(:)./depth(:), depth(:)./depths_inpaint(:));
    thr1Temp = length(find(thrVec < evaThr1))/pixelNum;
    thr2Temp = length(find(thrVec < evaThr2))/pixelNum;
    thr3Temp = length(find(thrVec < evaThr3))/pixelNum;
    
    fprintf(fileResult,'%s %f %f %f %f %f %f\n',imagePath, relTemp,rmsTemp,log10Temp,thr1Temp,thr2Temp,thr3Temp);
    
    evaRel = evaRel + relTemp;
    evaRms = evaRms + rmsTemp;
    evaLog10 = evaLog10 + log10Temp;
    evaThrCount1 = evaThrCount1 + thr1Temp;
    evaThrCount2 = evaThrCount2 + thr2Temp;
    evaThrCount3 = evaThrCount3 + thr3Temp;

    toc
    
    fprintf('process %d/%d\n',indx,imgNum);
    
end

evaRel = evaRel/imgNum;
evaRms = evaRms/imgNum;
evaLog10 = evaLog10/imgNum;
evaThrCount1 = evaThrCount1/imgNum;
evaThrCount2 = evaThrCount2/imgNum;
evaThrCount3 = evaThrCount3/imgNum;

fclose(fileResult);
caffe.reset_all();




