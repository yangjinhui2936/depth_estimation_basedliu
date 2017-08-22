%may be not runable, for path problem

% Add caffe/matlab to you Matlab search PATH to use matcaffe
if exist('../+caffe', 'dir')
  addpath('..');
else
  error('Please run this demo from caffe/matlab/demo');
end

caffe.set_mode_gpu();
caffe.set_device(0);

% Initialize the network using trained LeNet for digit image classification
%model_dir = '../../models/Depth_estimation/';
model_dir = '../../examples/Depth_estimation_basedLiu/models/';
net_model = [model_dir 'DepthEst_test_sigmoid_end2p_net.prototxt'];%DepthEst_test_Relu_end2p_net, DepthEst_test_sigmoid_end2p_net
net_weights = [model_dir, 'Model_sigmoid_combinedtune__iter_13600.caffemodel'];%'Model_sigmoid_finetune__iter_12800,Model_sigmoid__iter_11200,finetune/Model_make3d__iter_32000,VirtualDataModel/Model_no_sigmoid_iter_16000.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please prepare trained depth estimation model before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

%process image data
imagePath = 'F:/DeepLearning/Caffe/caffe/examples/Depth_estimation_basedLiu/data/test/tj06.jpg';%'E:/Unreal4/IndustrialCityImage/images_10/00002833.png';
img = imread(imagePath);
spSize = 25;
imageSize = [112, 112]; %size for every batch
imageMaxHei = 800;
imageMaxWei = 1200;

[hei, wei, chl] = size(img);
if hei > imageMaxHei || wei > imageMaxWei
    if hei/imageMaxHei > wei/imageMaxWei
        img = imresize(img, [imageMaxHei, NaN]);
    else
        img = imresize(img, [NaN, imageMaxWei]);
    end
    
    [hei, wei, chl] = size(img);
end

meanInfo = 128;
%imdata = caffe.io.load_image(imagePath);
%imdata = imdata - meanInfo;

tic

sp_info=gen_supperpixel_info(img, spSize);
sp_num = sp_info.sp_num;
centroids = ComputeSpCentroid(sp_info);
img_size = sp_info.img_size;

toc

%img = single(img);
%img = img - meanInfo;
img = im2double(img);

imgWithBorder = zeros(hei+imageSize(1),wei+imageSize(2),chl);
imgWithBorder(imageSize(1)/2+1:img_size(1)+imageSize(1)/2, imageSize(2)/2+1:img_size(2)+imageSize(2)/2, :) = img;
        
imgWithBorder(1:imageSize(1)/2, :, :) = imgWithBorder(imageSize(1):-1:imageSize(1)/2+1, :, :);
imgWithBorder(img_size(1)+imageSize(1)/2 + 1:img_size(1)+imageSize(1), :, :) =...
        imgWithBorder(img_size(1)+imageSize(1)/2:-1:img_size(1)+1, :, :);
imgWithBorder(:, 1:imageSize(2)/2, :) = imgWithBorder(:, imageSize(2):-1:imageSize(2)/2+1, :);
imgWithBorder(:, img_size(2)+imageSize(2)/2+1:img_size(2)+imageSize(2), :) =...
        imgWithBorder(:, img_size(2)+imageSize(2)/2:-1:img_size(2)+1, :); 
    

%batch_size = 50;
%iter_size = 19;
dp_est = zeros(1,sp_num);


%% runable code for depth prediction, but maybe slow
imgcrops = zeros(imageSize(1),imageSize(2),3);

% time to predict depth
tic

for i = 1:sp_num
    centerIndx = i;
    
    centerX = centroids(centerIndx,1);
	centerY = centroids(centerIndx,2);
    
    imgcrops(:,:,:) = imgWithBorder(centerY+1:centerY+imageSize(1), centerX+1:centerX+imageSize(2), :);
    res = net.forward({imgcrops});
    dp_est(i) = res{1};
end

toc

caffe.reset_all();

dpBais = log10(0.8);
dpScale = log10(200) - dpBais;

depthInfo = power(10,(dp_est)*dpScale+dpBais);

pixel_ind_sps = sp_info.pixel_ind_sps;
depthMap = zeros(hei, wei);

for i = 1:sp_num
    depthMap(pixel_ind_sps{i}) = depthInfo(i);
end

tic

fprintf('inpaiting using Anat Levin`s colorization code, this may take a while...\n');
depths_inpaint = do_inpainting(depthMap, uint8(img*255), sp_info);

toc

%% depth index may wrong by code below
%cell_input = cell(1,iter_size);
%for i = 1:iter_size
%    imgcrops = zeros(imageSize(1),imageSize(2),3,batch_size);
%    for j = 1: batch_size
%        centerIndx = i*(batch_size-1)+j;
        
%        if sp_num >= centerIndx
%            centerX = centroids(centerIndx,1);
%            centerY = centroids(centerIndx,2);
%        else
%            temp = randi(sp_num);
%            centerX = centroids(temp,1);
%            centerY = centroids(temp,2);
%        end
        
%        imgcrops(:,:,:,j) = imgWithBorder(centerY+1:centerY+imageSize(1), centerX+1:centerX+imageSize(2), :);
%    end    
    
%    cell_input{i} = imgcrops;
%end

%dp_est = zeros(1,iter_size*batch_size);

%for indx = 1:iter_size
%    res = net.forward(cell_input(indx));
%    dp_est(indx*batch_size:-1:(indx-1)*batch_size+1) = res{1};
%end

%caffe.reset_all();

%dpBais = log10(0.8);
%dpScale = log10(100) - dpBais;

%depthInfo = power(10,(dp_est)*dpScale+dpBais);

%pixel_ind_sps = sp_info.pixel_ind_sps;
%depthMap = zeros(hei, wei);

%for i = 1:sp_num
%    depthMap(pixel_ind_sps{i}) = depthInfo(i);
%end

%%
%h5dat =h5read('F:/DeepLearning/Caffe/caffe/examples/Depth_estimation_basedLiu/data/train_city7_1.h5','\data');
%for i = 1:19
%    cell_input{i} = h5dat(:,:,:,(i-1)*50+1:i*50);
%end
