%% JPEG to Hypercube


jpegFiles = dir('*.jpg'); 
numfiles = length(jpegFiles);
mydata = cell(1, numfiles);

for k = 1:numfiles 
  mydata{k} = imread(jpegFiles(k).name); 
end

cube = zeros(256,256,numfiles);

for k = 1:numfiles
  cube(:,:,k) = mydata{1,k}(:,:,1);
end


