 baseDir = 'F:/DeepLearning/DepthLiuFayao/fayao-dcnf-fcsp-f66628a4a991/';
 
% run( [baseDir, 'libs/vlfeat-0.9.20/toolbox/vl_setup']);
% 
% dir_matConvNet=[baseDir, 'libs/matconvnet-1.0-beta24/matlab/'];
% addpath(genpath(dir_matConvNet));
% run([dir_matConvNet 'vl_setupnn.m']);

opts = [];
opts.useGpu=true;

if opts.useGpu
    if gpuDeviceCount==0
        disp('WARNNING!!!!!! no GPU found!');
        disp('any key to continue...');
        pause;
        opts.useGpu=false;
    end
end


opts_eval=[];
opts_eval.useGpu = opts.useGpu;
opts_eval.do_show_log_scale=true; 

ds_config.sp_size=16;
ds_config.max_img_edge=600; 
    
%outdoor scene model
trained_model_file = [baseDir, 'model_trained/model_dcnf-fcsp_Make3D']; 
model_trained=load(trained_model_file); 
model_trained=model_trained.data_obj;
    

[imagePathArray1, depthPathArray1, ~, ~] =  ReadDefinationFile('test_city.txt');
[imagePathArray2, depthPathArray2, ~, ~] =  ReadDefinationFile('test_rotate_city.txt');
imagePathArray = {imagePathArray1{:}, imagePathArray2{:}};
depthPathArray = {depthPathArray1{:}, depthPathArray2{:}};

imgNum = length(imagePathArray);
imageResize = [480 640];

fileResult = fopen('test_liu_virtualdata.txt','w');
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


%     fprintf('generating superpixels...\n');
    sp_info=gen_supperpixel_info(image, ds_config.sp_size);

%     fprintf('generating pairwise info...\n');
    pws_info=gen_feature_info_pairwise(image, sp_info);

    ds_info=[];
    ds_info.img_idxes=1;
    ds_info.img_data=image;
    ds_info.sp_info{1}=sp_info;
    ds_info.pws_info=pws_info;
    ds_info.sp_num_imgs=sp_info.sp_num;

    depths_pred = do_model_evaluate(model_trained, ds_info, opts_eval);

%     fprintf('inpaiting using Anat Levin`s colorization code, this may take a while...\n');
    depths_inpaint = do_inpainting(depths_pred, image, sp_info);

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

% fprintf('saving prediction results in: %s\n', result_dir);
% opts_eval.label_norm_info=model_trained.label_norm_info;
% opts_eval.img_file_name='./my_sample';
% do_save_prediction( depths_inpaint, opts_eval);



