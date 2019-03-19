function [Data,Params,videoFrame] = initializepoints(Data,Params)
%% joshrbaxter@gmail.com


%% read in video
iniFrame = Data.trackFrames(1);
% read in video file
videoFileReader = vision.VideoFileReader(Data.trialName);
for i = 1:iniFrame % step through to starting frame
    videoFrame = step(videoFileReader);
end
videoFrame = imcrop(videoFrame,Params.imCropRect);
videoFrame = rgb2gray(videoFrame);

%% get user input and define trackable points for all landmarks
videoFrame0 = videoFrame;
getuserinput = true;
% Data.frame(1) = [];
while getuserinput
    videoFrame = videoFrame0;
    Data.frame(iniFrame).videoFrame = videoFrame;
    for i = 1:3
        if Data.manual == 0 %auto tracking
            [Data,Params] = trackablepoints(Data,videoFrame,Params,i);
        else % manual tracking
            [Data,Params] = trackablepoints_manual(Data,videoFrame,Params,i);
        end
    end
    close gcf
    
    pts1 = Data.frame(iniFrame).pts{1};
    pts2 = Data.frame(iniFrame).pts{2};
    pts3 = Data.frame(iniFrame).pts{3};
    
    nPts1 = size(pts1,1);
    nPts2 = size(pts2,1);
    nPts3 = size(pts3,1);
    
    Data.frame(iniFrame).points = [pts1;pts2;pts3];
    Data.frame(iniFrame).group = [1*ones(nPts1,1);2*ones(nPts2,1);3*ones(nPts3,1)];
    Data.frame(iniFrame).oPts = [nPts1;nPts2;nPts3];
    
    % calculate fascicle info
    Data.frame(iniFrame).fascicle = calculatefascicle(Data.frame(iniFrame),Params);
    
    % plot points
    videoFrame = plottrial(Data,videoFrame,Params,iniFrame);
    figure('Position',Params.figPos)
    imshow(videoFrame)
    
    % plot and ask user for approval
    button = questdlg('Confirm points and lines','','Yes','No','Yes');

    if strcmp(button,'Yes')
        release(videoFileReader);
        close gcf
%         returnData = Data.frame(iniFrame); % output processed data
        return;
    end
    % otherwise repeat loop
    close gcf

end

end


