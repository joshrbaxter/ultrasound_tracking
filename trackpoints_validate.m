
function DataValidate = trackpoints_validate(Data,Params)
%%
DataValidate.manual = Data.manual;
DataValidate.validate = 1;
DataValidate.trialName = Data.trialName;

% set tracking frames
[~,trialName,~] = fileparts(Data.trialName);


% default frames to track
frameInd = [Data.trackFrames(1):Params.manualFrameStep:Data.trackFrames(end)];

% 

if Params.isbiodex % is a biodex trial
    isIsometric = contains(trialName,'isometric'); % update frame info for isometric trials
    if isIsometric
        [maxVal,maxFrame] = max(abs(Data.torque));
        frameInd = [frameInd(1):1:maxFrame]';
        % validate isometric trials with cyclepercent
        isoFramesFraction = frameInd / length(frameInd);
        [minresidual,isoFractionInd] = min(abs(isoFramesFraction - Params.validateFramePercent));
        frameInd = frameInd(isoFractionInd);
    elseif ~isIsometric
        if contains(Params.validateFrameType,'position')
            [minresidual,frameInd] = min(abs(Data.position - Params.validateFrameVal));
            DataValidate.position = Data.position(frameInd);
        elseif contains(Params.validateFrameType,'cyclepercent')

        end
    end
else
    % not a biodex trial...
%     isWalk = contains({'walk','jog'},trialName);
%     if isWalk
        isoFramesFraction = frameInd / length(frameInd);
        [minresidual,isoFractionInd] = min(abs(isoFramesFraction' - Params.validateFramePercent));
        frameInd = frameInd(isoFractionInd);
%     end
end

%% Track points over trial

%initialize while loop count
nFrames = length(frameInd);
n = 0;
% videoFrame = plottrial(Data,videoFrame,Params,n-1);
% imshow(videoFrame)
% hold on
frameCount = 1;

% Initialize video reader
videoFileReader = vision.VideoFileReader(Data.trialName);

DataValidate.trackFrames = frameInd;
DataValidate.imageTime = Data.imageTime(frameInd);


while ~isDone(videoFileReader) % tracking and plotting main
    
    % get the next frame
    frame2track = frameInd(frameCount);
    while n < frame2track
        videoFrame0 = step(videoFileReader);
        n = n + 1;
    end
    
    videoFrame0 = imcrop(videoFrame0,Params.imCropRect);
    videoFrame = videoFrame0;
    
    % store frame n points and group data
    DataValidate.frame(frameCount).points = [];
    DataValidate.frame(frameCount).group = [];
    
    % plot previous fascicle and aponeurosis lines
    videoFrame = plottrial(Data,videoFrame,Params,n,[1,2]);
    
    % put fascicle intersection to approximate what fascicle to evaluate
    deepFascPts = Data.frame(n).fascicle.insertionDeep_px;
    videoFrame = insertMarker(videoFrame,deepFascPts,'x','color','white','size',12);
    
    imshow(videoFrame)
    hold on

    for i1 = 1:2 % 1 = deep, 2 = superficial aponeurosis
        for i2 = 1:2 % 1 = left, 2 = right side of aponeursis
        %transfer data to DataValidate structure
        DataValidate.frame(frameCount).pts{i1}(i2,:) = [Data.frame(n).fascicle.plotInsertions(i1).x(i2),Data.frame(n).fascicle.plotInsertions(i1).y(i2)];
        end
    end
    
     for i1 = 3 % redraw fascicles
         iTitle = sprintf('Select %s - frame %d of %d',Params.landmarkString{i1},n,frameInd(end));
         title(iTitle)
         iLine = imline();
         DataValidate.frame(frameCount).pts{i1} = iLine.getPosition();
     end
    
    % calculate fascicle angle and length
    DataValidate.frame(frameCount).fascicle = calculatefascicle(DataValidate.frame(frameCount),Params);
    
    %update 
    videoFrame = plottrial(DataValidate,videoFrame0,Params,frameCount);
    
    
    frameCount = frameCount + 1;
    if frameCount > nFrames
        break; % finished tracking
    end
end

% Clean up
release(videoFileReader);
close gcf
% reset plotting params
% Params.plotPoints = plotPointsHold;
% Params.displayPtRetention = displayPtRetentionHold;

end
