function RenameImages(fileReg, prefix, startNum) %fileReg为路径正则式，prefix为文件前缀，startNum为开始文件编号
    fileNames = dir(fileReg);
    len=length(fileNames);
    for i = 1:len
        lastName = fileNames(i).name;
        newName = [];
        if mod(i,2) == 0
             newName = [prefix, num2str(startNum), '_depth.png'];
             startNum = startNum + 1;
        else
            newName = [prefix, num2str(startNum), '.png'];
        end
        
        command = ['rename',' ',lastName,' ',newName];
        status = dos(command);
        if status == 0
            disp([lastName, ' 已被重命名为 ', newName]);
        else
            disp([lastName, ' 重命名失败!']);
        end
    end
end