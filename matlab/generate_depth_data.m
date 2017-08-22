%% generate data for end2end
%meanData = load('meanImageCity1200x800.mat');
%meanData = meanData.meanImage1200x800;

%generateDepthData('train_city7.txt', 'train_industrial_city7_1.h5', 32, [240 320], [30 40], 4, 0, meanData);
%generateDepthData('train_city7.txt', 'train_industrial_city7_2.h5', 32, [240 320], [30 40], 4, 1, meanData);
%generateDepthData('train_city10.txt', 'train_industrial_city10_1.h5', 32, [240 320], [30 40], 4, 0, meanData);
%generateDepthData('train_city10.txt', 'train_industrial_city10_2.h5', 32, [240 320], [30 40], 4, 1, meanData);
%generateDepthData('train_city12.txt', 'train_industrial_city12_1.h5', 32, [240 320], [30 40], 4, 0, meanData);
%generateDepthData('train_city12.txt', 'train_industrial_city12_2.h5', 32, [240 320], [30 40], 4, 1, meanData);
%generateDepthData('train_city15.txt', 'train_industrial_city15_1.h5', 32, [240 320], [30 40], 4, 0, meanData);
%generateDepthData('train_city15.txt', 'train_industrial_city15_2.h5', 32, [240 320], [30 40], 4, 1, meanData);

%generateDepthData('test_city.txt', 'test_industrial_city.h5', 8, [240 320], [30 40], 4, 2,meanData);

%% compute min depth of all image
%minDepths = zeros(0);
%minDepths(1) = 1.31;
%minDepths(2) = getMinDepth('train_city10.txt');
%minDepths(3) = getMinDepth('train_city12.txt');
%minDepths(4) = getMinDepth('train_city15.txt');

%minDepth = min(minDepths);

%% generate data for end2point
addpath('F:/DeepLearning/DepthLiuFayao/fayao-dcnf-fcsp-f66628a4a991/demo');

baseDir = 'F:/DeepLearning/Caffe/caffe/examples/Depth_estimation_basedLiu/data/';


%generateEnd2pData('test_city.txt', [baseDir,'test_1.h5'], 32, 950 ,[112 112],[1 20 300]);
%generate_end2p_data('test_city.txt', 'test_2.h5', 32, 950 ,[112 112],[300 50 500]);

%depth is regrad ranging in [0.8, 500]
dpBais = log10(0.8);
dpScale = log10(200) - dpBais;

generateEnd2pData('train_city7.txt', [baseDir,'train_city7'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_city10.txt', [baseDir,'train_city10'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_city12.txt', [baseDir,'train_city12'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_city15.txt', [baseDir,'train_city15'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);

generateEnd2pData('train_rotate_city7.txt', [baseDir,'train_rotate_city7'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_rotate_city10.txt', [baseDir,'train_rotate_city10'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_rotate_city12.txt', [baseDir,'train_rotate_city12'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('train_rotate_city15.txt', [baseDir,'train_rotate_city15'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);

generateEnd2pData('test_city.txt', [baseDir,'test_city'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);
generateEnd2pData('test_rotate_city.txt', [baseDir,'test_rotate_city'], 32, 950 ,[112 112], dpScale, dpBais, [1 8 12]);

%generateEnd2pData('train_city7.txt', [baseDir,'train_city7_1.h5'], 32, 950 ,[112 112],[1 8 10], dpScale, dpBais);
%generateEnd2pData('train_city7.txt', [baseDir,'train_city7_2.h5'], 32, 950 ,[112 112],[201 20 400], dpScale, dpBais);
%generateEnd2pData('train_city7.txt', [baseDir,'train_city7_3.h5'], 32, 950 ,[112 112],[401 20 600], dpScale, dpBais);
%generateEnd2pData('train_city7.txt', [baseDir,'train_city7_4.h5'], 32, 950 ,[112 112],[601 20 800], dpScale, dpBais);
%generateEnd2pData('train_city7.txt', [baseDir,'train_city7_5.h5'], 32, 950 ,[112 112],[801 20 1100], dpScale, dpBais);

%generateEnd2pData('train_city10.txt', [baseDir, 'train_city10_1.h5'], 32, 950 ,[112 112],[1 15 200], dpScale, dpBais);
%generateEnd2pData('train_city10.txt', [baseDir, 'train_city10_2.h5'], 32, 950 ,[112 112],[300 10 400], dpScale, dpBais);
%generateEnd2pData('train_city10.txt', [baseDir, 'train_city10_3.h5'], 32, 950 ,[112 112],[500 10 600], dpScale, dpBais);
%generateEnd2pData('train_city10.txt', [baseDir, 'train_city10_4.h5'], 32, 950 ,[112 112],[600 10 700], dpScale, dpBais);

%generateEnd2pData('train_city12.txt', [baseDir,'train_city12_1.h5'], 32, 950 ,[112 112],[1 20 200], dpScale, dpBais);
%generateEnd2pData('train_city12.txt', [baseDir,'train_city12_2.h5'], 32, 950 ,[112 112],[201 20 400], dpScale, dpBais);
%generateEnd2pData('train_city12.txt', [baseDir,'train_city12_3.h5'], 32, 950 ,[112 112],[401 20 600], dpScale, dpBais);
%generateEnd2pData('train_city12.txt', [baseDir,'train_city12_4.h5'], 32, 950 ,[112 112],[601 20 900], dpScale, dpBais);

% generateEnd2pData('train_city15.txt', [baseDir,'train_city15_1.h5'], 32, 950 ,[112 112],[1 20 200], dpScale, dpBais);
% generateEnd2pData('train_city15.txt', [baseDir,'train_city15_2.h5'], 32, 950 ,[112 112],[201 20 400], dpScale, dpBais);
% generateEnd2pData('train_city15.txt', [baseDir,'train_city15_3.h5'], 32, 950 ,[112 112],[401 20 600], dpScale, dpBais);
% generateEnd2pData('train_city15.txt', [baseDir,'train_city15_4.h5'], 32, 950 ,[112 112],[601 20 900], dpScale, dpBais);
% 
% generateEnd2pData('train_city15.txt', [baseDir,'test_city1.h5'], 32, 950 ,[112 112],[1 20 400], dpScale, dpBais);

%definedtxt = 'train_city10.txt';
%savepath = 'train_city7_10.h5';
%sampleNumPerImage = 950;
%spSize = 32;
%imageSize = [224 224];
%fileSelector = [1 5 40]



