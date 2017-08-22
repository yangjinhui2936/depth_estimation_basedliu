definedFiles = {'train_city7.txt','train_city10.txt','train_city12.txt','train_city15.txt','test_city.txt'};

countTotal = 0;
meanImage = zeros(800,1200,3);

num = length(definedFiles);
for i = 1:num
    definedTxt = char(definedFiles{i});
    [imgepaths,~,~,count] = ReadDefinationFile(definedTxt);
    
    disp(['file:', definedTxt]);
    
    tic
    for j = 1:count
        disp(['count:', num2str(j)]);
        imgPath = char(imgepaths{j});
        imgcur = imread(imgPath);
        
        meanImage = meanImage + single(imgcur);
    end
    toc
    
    countTotal = countTotal + count;
end

meanImage = meanImage/countTotal;
meanImage1200x800 = meanImage;

save('meanImageCity1200x800','meanImage1200x800');