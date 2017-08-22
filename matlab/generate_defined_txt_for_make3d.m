imagepath = 'Dataset3_Images/Dataset3_Images';
labelpath = 'depthMapData3';
type = 0;
%for make3d, there are two format to save depth data. one is saved in .depthMap, the other is saved in the fourth chaneel of .Position3DGrid
%depthdatatype=  0 means depth in the .depthMap; 1 means depth in the .Position3DGrid
imgPrefix = 'img';
labPrefix = 'depth';

imgFileInfo = dir([imagepath,'/*.jpg']);
labFileInfo = dir([labelpath,'/*.mat']);
% configuration above may adjust by requirements
%--------------------------------------------------------------

num = length(imgFileInfo);

fid = fopen('train_make3d.txt','wt');
for indx = 1:num
    imgName = imgFileInfo(indx).name;
    labName = labFileInfo(indx).name;
    if isPairForData(imgName, labName, imgPrefix, '.jpg', labPrefix, '.mat')
         fprintf(fid,'%s/%s %s/%s %d\n',imagepath,imgName,labelpath,labName,type);
    else
        for i = 1:num
            labNameTemp = labFileInfo(i).name;
            if isPairForData(imgName,labNameTemp,imgPrefix,'.jpg',labPrefix,'.mat')
                fprintf(fid,'%s/%s %s/%s %d\n',imagepath,imgName,labelpath,labNameTemp,type);
                break;
            end
        end
    end
end

fclose(fid);


