function depthmap = UnCodeDepthImage(imd)
    [row, col, channels] = size(imd);
    depthmap = single(zeros(row,col));
    cl1 = single(imd(:,:,1)); %R channel
    cl2 = single(imd(:,:,2)); %G channel
    cl3 = single(imd(:,:,3)); %B channel
    
    depthmap = (cl1*(2^16) + cl2*(2^8) + cl3)/(2^3); % divider depends on unreal4 material expression
end
