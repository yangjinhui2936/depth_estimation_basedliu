function [imges,depths,types,count] = ReadDefinationFile(filename)
    imges = cell(0); %
    depths = cell(0); %
    types = zeros(0);
    count = 0; % the number of image and depth pair
    
    file = fopen(filename,'r');
    while ~feof(file)
        line = fgetl(file);
        info = split(line, ' ');
        if length(info) >= 2
            imagepath = info(1);
            depthpath = info(2);
            count = count + 1;
            
            imges{count} = imagepath;
            depths{count} = depthpath;
            if length(info) >= 3
                types(count) = str2num(char(info(3)));
            end
        end
    end
    fclose(file);
end
