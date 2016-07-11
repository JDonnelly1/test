vidReader = VideoReader('viptraffic.avi');
%Create optical flow object.

opticFlow = opticalFlowLK('NoiseThreshold',0.009);
%Estimate and display the optical flow of objects in the video.

while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);

    flow = estimateFlow(opticFlow,frameGray);
pause
    imshow(frameRGB)
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off
end