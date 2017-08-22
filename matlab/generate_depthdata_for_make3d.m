[imageNameArray,depthNameArray,types] = ReadDefinationFile('test_134.txt'); %train_dataset3.txt
num = length(imageNameArray);

imageSize = [240 320];
labelSize = [30 40];

chunksz = 5;
savepath = 'test.h5';

%uncode depth and resize data
imageData = zeros(imageSize(1), imageSize(2), 3, 1);
depthData = zeros(labelSize(1), labelSize(2), 1, 1);
dataCount = 0;
for indx = 1:num
    imagepath = char(imageNameArray{indx});
    depthpath = char(depthNameArray{indx});
    
    img = imread(imagepath);
    depthMap = [];
    depthdatatype = 1;
    if ~isempty(types)
    	depthdatatype = types(indx); 
    end
%for make3d, there are two format to save depth data. one is saved in .depthMap, the other is saved in the fourth chaneel of .Position3DGrid
%depthdatatype=  0 means depth in the .depthMap; 1 means depth in the .Position3DGrid
    if depthdatatype == 0
        depthdata = load(depthpath);
        depthMap = rot90(depthdata.depthMap); %the depth is in the fourth channel
    end
    if depthdatatype == 1
        depthdata = load(depthpath);
        depthMap = depthdata.Position3DGrid(:,:,4); %the depth is in the fourth channel
    end
    
    imgrs = im2double(imresize(img, imageSize, 'bicubic'));
    depthmaprs = imresize(depthMap, labelSize, 'bicubic');
    norFactor = max(max(depthmaprs));
    depthmaprs = depthmaprs/norFactor;
    
    dataCount = dataCount + 1;
    imageData(:,:,:,dataCount) = imgrs;
    depthData(:,:,1,dataCount) = depthmaprs; %convert measurement to cm
    
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
