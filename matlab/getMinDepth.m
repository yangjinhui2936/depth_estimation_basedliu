function minDepth = getMinDepth(definedTxt)
    [imageNameArray,depthNameArray] = ReadDefinationFile(definedTxt);
    num = length(depthNameArray);
    
    minDepth = 50000;
    for indx = 1:num

        depthpath = char(depthNameArray{indx});
        codeDepth = imread(depthpath);
        depthMap = DepthMaskTest(UnCodeDepthImage(codeDepth),50000,50000); %depth over 50000 cm is regularized to 50000cm
        depthMap = depthMap/100; % convert depth to [0 500]
        minTemp = min(min(depthMap));
        if minDepth > minTemp
            minDepth = minTemp;
        end
    end
    
    disp(['minDepth:',num2str(minDepth)]);
end
