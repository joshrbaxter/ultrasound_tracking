function Params = tracking_params(Params)

% Josh R Baxter, PhD - University of Pennsylvania
% joshrbaxter@gmail.com
% version history
% v1 - 2017-12-12 - parameters used for tracking
%% input: Params - ultrasound parameters

%% output: Params - updated params structure with tracking parameters

%% parameters
Params.padBorder = [.01,0.01,0.1];
Params.userInputHt = 1; % in mm
Params.rectHt = round(Params.userInputHt / Params.px2mmX); %region of interest height
Params.getUserInputSaveDir = false; % if true, let user select directory to save

Params.landmarkString = {'Deep Aponeurosis','Superficial Aponeurosis','Fascicle'};
Params.markerColor = {'white','white','red'};
Params.blindUser = true;


% tracking settings
Params.displayTracking = true;
Params.saveVideo = true;
Params.saveData = true;
Params.plotPoints = true; % plot tracking points as '+'
Params.showLines = true; % lines from tracked points
Params.rejectOutliers = false; % reject poorly tracked markers - select false for longer trials
Params.displayPtRetention = true; % display number of points retained throughout tracking
Params.redefinePts = true; % 
Params.maxTrackingPts = [100;100;100]; % number of points seeded along line 
Params.padAVIframes = 5;
Params.manual = 'excursion'; % just calculate first and last frame fascicle length and pennation.


% user inputs for optical flow tracking
Params.userInputBiDirect_mm = 2; % in mm % default 2mm
Params.userInputMaxBiDirectionalError = round(Params.userInputBiDirect_mm / Params.px2mmX); 
Params.userInputPyramidLevels = 4; % default 4
Params.userInputBlockSizemm = 3;
blocksizex = 2*round(((Params.userInputBlockSizemm/Params.px2mmX)+1)/2)-1;
blocksizey = 2*round(((Params.userInputBlockSizemm/Params.px2mmY)+1)/2)-1;
Params.userInputBlockSize = [blocksizex blocksizey];
Params.redefinePtsThresh = [0.9;0.9;0.9]; % ratio of tracked points to original points
Params.redefineWidthThresh = [0.9;0.9;0.9]; % ratio of width with points


% Manual tracking (Validation parameters)
Params.validateFrameType = 'position'; % biodex channels - 'position' or 'cyclepercent' of clip for gait and other movements
Params.validateFrameVal = [-20:10:30];
Params.validateFramePercent = [0:0.2:1];
Params.manualFrameStep = 1; %

% paths for saving 
Params.userInitials = 'user';

Params.date_time_track = datestr(now,'yyyymmdd_HHMMSS');
Params.trackedSaveDir = fullfile(Params.viddir,'tracked',[Params.userInitials,'_',Params.date_time_track]);

end
