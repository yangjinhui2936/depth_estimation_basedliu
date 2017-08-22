dataPath = 'E:/Unreal4/IndustrialCityImage/images_rotate_15';
dataFileInfo = dir([dataPath,'/*.png']);

postfix = '.png';
postfixLen = length(postfix);

strFormat = '%08d';

num = length(dataFileInfo);
fid = fopen('train_rotate.txt','wt');
fidtest = fopen('test_rotate.txt','a');
for indx = 1:num
    imgName = dataFileInfo(indx).name;
    imgNo = uint32(str2double(imgName(1:length(imgName)-postfixLen)));
    if mod(imgNo,2) == 1
        depthNo = imgNo + 1;
        depthName = [num2str(depthNo,strFormat),postfix];
        if randi(9,1) == 9
            fprintf(fidtest,'%s/%s %s/%s\n',dataPath,imgName,dataPath,depthName);
        else
            fprintf(fid,'%s/%s %s/%s\n',dataPath,imgName,dataPath,depthName);
        end
    end
end
fclose(fid);
fclose(fidtest);