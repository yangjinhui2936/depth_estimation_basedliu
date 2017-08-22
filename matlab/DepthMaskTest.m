function imdp_mask = DepthMaskTest(imdp, mask_minDp, mask_minVal, mask_dp, mask_val)
%    [row, col, channels] = size(imdp);
%    imdp_mask = single(zeros(row, col));
    
    maxIndx = find(imdp > mask_dp);
    minIndx = find(imdp < mask_minDp);
    
    imdp(maxIndx) = mask_val;
    imdp(minIndx) = mask_minVal;
    
    imdp_mask = imdp;
%    for m = 1:row
%        for n = 1:col
%            if imdp(m,n) > mask_dp
%                imdp_mask(m,n) = mask_val;
%            else
%                imdp_mask(m,n) = imdp(m,n);
%            end
%        end
%    end
end