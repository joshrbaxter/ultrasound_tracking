function [Fascicle,Data,Params] = trackfascicle(Data,Params)

% Josh R Baxter, PhD - University of Pennsylvania
% joshrbaxter@gmail.com
% version history
% v1 - 2017-06-06 - main layout


%% initialize tracking algorithm
% Data.trackFrames = frms; % passed thru function
% Data.trialName = ''; % full AVI path

% track points for trial
HoldData = Data; %hold Data struct incase reprocess is clicked
errorCount = 0;
while 1
    Data = HoldData;
    Data.manual = 0;
    Data.validate = 0;
    [Data,Params] = initializepoints(Data,Params);
    try
        tic;
        
        Data = trackpoints(Data,Params);
        Data.trackTime = toc;
        Data.flag = questdlg('Approve tracking trial','','Yes','Redo Autotrack','Validate','Yes');
    catch
        fprintf('tracking algorithm errored - please reselect aponeuroses and fascicle to track...\n')
        Data.flag = 'fail';
        errorCount = errorCount + 1;
        

    end
    
   
    switch lower(Data.flag)
        case {'yes','skip'}
            AutoData = Data;
            break;
        case {'redo autotrack'}         
            continue;
        case {'validate'}
            AutoData = Data;
            Data.validate = 1; % set validate flag to 1
            ValidateData = trackpoints_validate(Data,Params);
            break;
    end
end

if strcmp(lower(Data.flag),'validate')
    nr = 2;
else
    nr = 1;
end

for i1 = 1:nr
    if i1 == 1
        thisData = AutoData;
        iField = 'automatic';
    else
        thisData = ValidateData;
        iField = 'validate';
    end
    
    
    Fascicle.(iField).time = [thisData.imageTime];
    Fascicle.(iField).sampleRate = 1 / mean(diff(thisData.imageTime));
    Fascicle.(iField).trackFrames = thisData.trackFrames;
    for jF = 1:length(thisData.frame)
        Fascicle.(iField).length(jF,1) = thisData.frame(jF).fascicle.length;
        Fascicle.(iField).pennation(jF,1) = thisData.frame(jF).fascicle.pennation;
        Fascicle.(iField).insertDeep(jF,1:2) = thisData.frame(jF).fascicle.insertionDeep_mm;
        Fascicle.(iField).insertSup(jF,1:2) = thisData.frame(jF).fascicle.insertionSuperficial_mm; 
        Fascicle.(iField).plotInsertions{jF} = thisData.frame(jF).fascicle.plotInsertions;
    end
    
    if Params.saveVideo && i1 == 1 % save auto tracking video

        [~,trialName,~] = fileparts(thisData.trialName);
        try
            fprintf('\tSaving tracked video %s...\n',trialName)
            % suppress warnings
            warning('off','all')
            if ~exist(Params.trackedSaveDir,'dir')
                mkdir(Params.trackedSaveDir)
            end
            % open video to record
            videoFileReader = vision.VideoFileReader(thisData.trialName);
            videoSavePath = fullfile(Params.trackedSaveDir,[trialName,'_',iField,'.mp4']);
            TrackingVideo = VideoWriter(videoSavePath,'MPEG-4');
            TrackingVideo.FrameRate = Fascicle.(iField).sampleRate;  % Default 30
            TrackingVideo.Quality = 75;    % Default 75
            open(TrackingVideo);

            for jF = 1:length(thisData.trackFrames)

                videoFrame = step(videoFileReader);
                videoFrame = imcrop(videoFrame,Params.imCropRect);
                videoFrame = plottrial(thisData,videoFrame,Params,jF);
                writeVideo(TrackingVideo,videoFrame);

            end
            close(TrackingVideo);
            warning('on','all')
        catch
            warning(sprintf('Did not save tracked video of trial %s...',trialName))
        end
    end

    
end

end % end function
