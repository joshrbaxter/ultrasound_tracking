function Data = trackpoints(Data,Params)
%% joshrbaxter@gmail.com
Data.manual = 0;
frameIni = Data.trackFrames(1);
frameEnd = Data.trackFrames(end);
%% read in video

% read in video file
videoFileReader = vision.VideoFileReader(Data.trialName);
for i = 1:frameIni % step through to starting frames
    videoFrame = step(videoFileReader);
end

videoFrame = imcrop(videoFrame,Params.imCropRect);
videoFrame_bw = rgb2gray(videoFrame);

%% get user input and define trackable points for all landmarks

%% Track points over trial

% initialize point tracker
% object 1 is high contrast (black and white) deep aponeourosis
pointTracker = vision.PointTracker('MaxBidirectionalError',Params.userInputMaxBiDirectionalError,...
    'NumPyramidLevels',Params.userInputPyramidLevels,'BlockSize',Params.userInputBlockSize);

points = Data.frame(frameIni).points;
group = Data.frame(frameIni).group;

initialize(pointTracker, points, videoFrame_bw)
% Make a copy of the points to be used for computing the geometric
% transformation between the points in the previous and the current frames
oldPoints = points;


% Display the annotated video frame using the video player object   

if Params.displayTracking
    videoPlayer  = vision.VideoPlayer('Position',Params.figPos);
    step(videoPlayer, videoFrame);
end

%indexing for redefining points
redefineInd = frameIni*[1;1;1];

%initialize while loop count
n = frameIni+1;

while ~isDone(videoFileReader) % tracking and plotting main
%     disp(n)
    %initialize flag for recalculting tracking points
    Data.frame(n).redefinePtsFlag = [0;0;0];
    
    % get the next frame
    videoFrame = step(videoFileReader);
    videoFrame = imcrop(videoFrame,Params.imCropRect);
    videoFrame_bw = rgb2gray(videoFrame);
    
    % Track the points. Note that some points may be lost.
    [points, isFound] = step(pointTracker, videoFrame_bw);

    visiblePoints = points(isFound, :);
    oldInliers = oldPoints(isFound, :);

    
    if Params.rejectOutliers
        % Estimate the geometric transformation between the old points
        % and the new points and eliminate outliers
        [xform, oldInliers, visiblePoints] = estimateGeometricTransform(...
            oldInliers, visiblePoints, 'similarity', 'MaxDistance', 4);
    end

    % restructure group array to account for removed tracking points
    [~,ia,~] = setxor(oldPoints,oldInliers,'rows','stable');
    group(ia) = [];

    % check to redefine tracking points
    n_npts = [size(group(group==1),1);size(group(group==2),1);size(group(group==3),1)];
    n_opts = [Data.frame(redefineInd(1)).oPts(1);Data.frame(redefineInd(2)).oPts(2);...
        Data.frame(redefineInd(3)).oPts(3)];
    
    nVisiblePoints = [];
    nGroup = [];
    for i = 1:3
        Data.frame(n).oPts(i,1) = n_opts(i);
        iInd = (group == i);
        Data.frame(n).pts{i} = visiblePoints(iInd,:);
        
        iPtsThreshHit = (n_npts(i) / n_opts(i)) < Params.redefinePtsThresh(i);
        if i < 3 % fascicles
            iPtMin = min(Data.frame(n).pts{i}(:,1));
            iPtMax = max(Data.frame(n).pts{i}(:,1));
            iPtRange = (iPtMax-iPtMin) / Params.nx;
            iWidthThreshHit = iPtRange < Params.redefineWidthThresh(i);
        else % fascicle
            iWidthThreshHit = 0;
        end
        redrawPts = or(iPtsThreshHit,iWidthThreshHit);
        if redrawPts
%             disp(sprintf('update pts %i, update width %i',iPtsThreshHit,iWidthThreshHit))
            Data = trackablepoints(Data,videoFrame_bw,Params,i,Data.frame(n).pts{i});      
            redefineInd(i,1) = n; %update indexing
            
            n_npts(i) = size(Data.frame(n).pts{i},1);
        end
        nGroup = [nGroup;i*ones(n_npts(i),1)];
        nVisiblePoints = [nVisiblePoints;Data.frame(n).pts{i}];
    end
        
   visiblePoints = nVisiblePoints;
   group = nGroup;

    % store frame n points and group data
    Data.frame(n).points = visiblePoints;
    Data.frame(n).group = group;
    
    % calculate fascicle angle and length
    Data.frame(n).fascicle = calculatefascicle(Data.frame(n),Params);

    % call plotting subroutines
    [~,trialName,~] = fileparts(Data.trialName);
    videoFrame = plottrial(Data,videoFrame,Params,n);
    
    % Reset the points
    oldPoints = visiblePoints;

    % display nPts for user during debug...
    %disp(sprintf('Frame# %i, %2.1f',count,length(oldPoints)))


    setPoints(pointTracker, oldPoints);

    % Display the annotated video frame using the video player object    
    if Params.displayTracking
        step(videoPlayer, videoFrame);
    end

    % increment step count
    n = n + 1;

    if n > frameEnd
%         disp(sprintf('stopped tracking trial at frame %i',n-1))
        break; % break out of loop if frame count exceeds 
    end
    
end

% Clean up
release(videoFileReader);
release(pointTracker);  
if Params.displayTracking  
    release(videoPlayer);
end
% end