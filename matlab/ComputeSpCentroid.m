function centroids = ComputeSpCentroid(sp_info)
%img = imread('my_sample/00002655.png');
%sp_info=gen_supperpixel_info(img, 32);

sp_num = sp_info.sp_num;
img_size = sp_info.img_size;
pixel_ind_sps = sp_info.pixel_ind_sps;

centroids = zeros(sp_num,2);

for i = 1:sp_num
    perCount = length(pixel_ind_sps{i}); %count for every super pixel

    ptIndx = pixel_ind_sps{i};
    x = floor(ptIndx/img_size(1));
    y = mod(ptIndx+img_size(1)-1, img_size(1))+1;
    
    centerX = sum(x)/perCount;
    centerY = sum(y)/perCount;
    
    centroids(i,1) = centerX;
    centroids(i,2) = centerY;
end

centroids = uint32(centroids);

end

%figure,imshow(sp_info.sp_ind_map,[]);
%hold on,plot(centroids(:,1),centroids(:,2),'o'); 