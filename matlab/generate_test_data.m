[imageName7,depthName7] = ReadDefinationFile('train_industrial_city7.txt');
[imageName10,depthName10] = ReadDefinationFile('train_industrial_city10.txt');
[imageName12,depthName12] = ReadDefinationFile('train_industrial_city12.txt');
[imageName15,depthName15] = ReadDefinationFile('train_industrial_city15.txt');


imgNameArray = [imgNameArray;imageName7];
imgNameArray = [imgNameArray;imageName10];
imgNameArray = [imgNameArray;imageName12];
imgNameArray = [imgNameArray;imageName15];