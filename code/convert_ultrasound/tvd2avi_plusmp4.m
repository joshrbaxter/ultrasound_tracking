% tvd2avi.m
% convert all TVD files in folder to AVI files and move to 'AVI' folder
% once this command goes - the computer is mostly unusable until all
% conversions are complete
% josh baxter
% joshrbaxter@gmail.com

%%
clear all
close all
clc

curdir = pwd;
%%

echowavePath = 'C:\Program Files (x86)\TELEMED\Echo Wave II';

searchPath = 'C:\TEMP_ULTRASOUND\';

tvdFolder = uigetdir(searchPath,'Select folder with ultrasound TVD videos to convert');

%% set up saving paths for tvd folder
tvdDir = dir(fullfile(tvdFolder, ['*.tvd']));
mp4Folder = strrep(tvdFolder, '\TVD', '\MP4');
if ~exist(mp4Folder, 'dir')
    mkdir(mp4Folder);
end

%% prep avi listener

adlistener = fullfile(tvdFolder, ['*.avi']);
aviDir = dir(adlistener);

%% convert TVD to AVI
cmdString = sprintf('cd "%s" & echowave.exe -convert_directory "%s" tvd avi_comp & exit &',echowavePath,tvdFolder);
cmdOutput = dos(cmdString);

padl = length(aviDir);
ladl = 0;
ltdl = length(tvdDir);

while ladl < ltdl
    pause(3)
    aviDir = dir(adlistener);
    ladl = length(aviDir);
end

for i = 1:ltdl
    newfn = aviDir(i).name;
    navi = strrep(adlistener, '*.avi', newfn);
    avi2mp4(navi, mp4Folder);
end

% uiwait(msgbox('Click button when complete'))

%% move AVI files to own folder
fprintf('victory!\n')
aviPath = fullfile(tvdFolder,'\..','AVI');
if ~exist(aviPath,'dir')
    mkdir(aviPath);
end

movefile(fullfile(tvdFolder,'*.avi'),aviPath)

%% close echowave

shutitDOWN = sprintf('cd "%s" & echowave.exe -exit & exit &', echowavePath);
closeOut = dos(shutitDOWN);

