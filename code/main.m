%% batchprocess.m
% process series of plantarflexion contractions that are trimmed
% Josh R Baxter, PhD - University of Pennsylvania
% joshrbaxter@gmail.com
% version history
% v1 - 2017-12-12 - main layout
% v2 - 2018-09-26 - save trackdata after each clip - allows for breaking
%                   the entire run or if run-time errors occur

%% prepare workspace
clear all; close all; clc;

%% parameters
scrsz = get(0,'Screensize');
fight = 700;
figwd = 700;
scrx = 0.1 * (scrsz(3) - figwd);
scry = 0.1 * (scrsz(4) - fight);
probe = 'p6';

%% get trials and paths to process

% data directory

subdir = '.\sample_data';
datadir = fullfile(subdir,'Ultrasound','Clips');
datafiles = dir(fullfile(datadir,('*.mat')));
nfiles = size(datafiles);
if nfiles(1) > 1
    for i1 = 1:nfiles(1)
        datafileStr{i1} = datafiles(i1).name;
    end
    
    [s,v] = listdlg('PromptString','Select Data file to Analyze:',...
                'SelectionMode','single','ListString',datafileStr);
     dataname = datafiles(s).name;
else
     dataname = datafiles.name;
end
Data1 = load(fullfile(datadir,dataname));

% load in param structure
paramsfiles = dir(fullfile(subdir,'Ultrasound',[probe,'*.mat']));
nparams = size(paramsfiles);
if nparams(1) > 1
    for i1 = 1:nparams(1)
        paramsStr{i1} = paramsfiles(i1).name;
    end
    [s,v] = listdlg('PromptString','Select Data file to Analyze:',...
                'SelectionMode','single','ListString',datafileStr);
    paramname = paramsfiles(s).name;
else
    paramname = paramsfiles.name;
end
load(fullfile(paramsfiles(1).folder,paramname));
Params.isbiodex = 1;
Params.viddir = datadir;

Params = tracking_params(Params);
% save Params structure in saved directory
if ~exist(Params.trackedSaveDir,'dir')
    mkdir(Params.trackedSaveDir)
end
save(fullfile(Params.trackedSaveDir,[probe,'_params.mat']),'Params');

% select trials to analyze

trialStr = fieldnames(Data1.clips);
[s,v] = listdlg('PromptString','Select Data file to Analyze:',...
                'SelectionMode','multiple','ListString',trialStr);
%%


for i1 = 1:length(s) % batch thru trials
    i1Trial = trialStr{s(i1)};
    fprintf('Processing %s...\n',i1Trial)
    i1Data = Data1.clips.(i1Trial);
    i1CycleNames = fieldnames(i1Data);
    for i2 = 1:length(i1CycleNames)
         try
            i2Name = i1CycleNames{i2};
            i2Data = i1Data.(i2Name);
            fprintf('\ttracking %s...\n',i2Name)

            % track fascicles
            i2TrackingData.trialName = fullfile(datadir,[i1Trial,'_',i2Name,'.mp4']);
            i2TrackingData.mocapTime = i2Data.time;
            i2TrackingData.imageTime = i2Data.time(i2Data.frameInds);
            i2TrackingData.trackFrames = [1:1:length(i2Data.frameInds)];
            % this is where the biodex data would go.
            % resample biodex data
            i2TrackingData.torque = spline(i2TrackingData.mocapTime,i2Data.TOR,i2TrackingData.imageTime);
            i2TrackingData.position = spline(i2TrackingData.mocapTime,i2Data.POS,i2TrackingData.imageTime);
            
            [i2Fascicle,i2TrackingData,i2Params] = trackfascicle(i2TrackingData,Params);

            %store tracked data into data structure
            Data2.clips.(i1Trial).(i2Name).fascicle = i2Fascicle;
            Data2.clips.(i1Trial).(i2Name).mocap = i2Data;
            
            % save Data structure to tracked folder after each run...
            Data = Data2;
            Data.Params = Params;
            write2mat = fullfile(Params.trackedSaveDir,'TrackedData.mat');
            save(write2mat,'Data')       
            fprintf('Tracking complete - data saved!\n')
            clear Data
         catch
            % tell user something is wrong...
            warning(sprintf('trial %s - push%s does not have complete data...',i1Trial,i2Name))
         end
        clear i2Fascicle i2Data i2TrackingData i2Params % clear local structures
    end

end
