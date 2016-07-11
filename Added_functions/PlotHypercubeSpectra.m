function [ A ] = PlotHypercubeSpectra( hypercube,a,b )
% choose pixels to plot in hypercube
%   hypercube is the hypercube data, a is used as an index to select a
%   frame from the hypercube, from which to select a crop.
%   b selects the number of points to plot
%   data is saved in A, each row is a set of X,Y coordinates from ginput

A = zeros(b,2);
frame = hypercube(:,:,a);

F2 = figure('Visible','off');
F =figure;
imshow(frame,[]);

for i= 1: b
    
[X,Y] = ginput(1);
A(i,1:2) = [X,Y];
F2.Visible = 'on';
figure(F2);
hold on;
plot(squeeze(hypercube(Y,X,:)));
hold off;
figure(F)
end




end

