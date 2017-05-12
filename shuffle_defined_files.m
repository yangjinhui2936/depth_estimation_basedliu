%shuffle files
fileName = 'train.txt';

fid = fopen(fileName,'r');

fileCount = 0;
filesArray = cell(0);
while ~feof(fid)
    line = fgetl(fid);
    fileCount = fileCount + 1;
    filesArray{fileCount} = line;
end

order = randperm(fileCount);
filesArray = filesArray(order);

fclose(fid);

fid = fopen(fileName,'w');

for indx = 1:fileCount
    data = filesArray{indx};
    fprintf(fid,'%s\n',data);
end

fclose(fid);