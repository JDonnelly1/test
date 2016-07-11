function [ spectra rect ] = AverageSpectra( hypercube, a )

%   Takes the average from each band of the hypercube and returns a vector 

%   hypercube is the hypercube data, a is used as an index to select a
%   frame from the hypercube, from which to select a crop.


[crop, rect] = imcrop(hypercube(:,:, a),[]); % select crop from frame of butane

hypercube_crop = hypercube(rect(2):rect(2)+rect(3),rect(1):rect(1)+rect(4),:);

rectangle('Position',rect);

reshaped_crop = reshape(hypercube_crop, size(hypercube_crop,1)*size(hypercube_crop,2), size(hypercube_crop,3));

spectra = mean(reshaped_crop);


end

