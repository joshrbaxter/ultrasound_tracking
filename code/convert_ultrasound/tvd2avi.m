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

searchPath = '.\..\..\..\Projects';

tvdFolder = uigetdir(searchPath,'Select folder with ultrasound TVD videos to convert');

%% convert TVD to AVI
% cd(echowavePath);
echowaveexe = fullfile(echowavePath,'EchoWave.exe');
% cmdString = sprintf('"%s" -convert_directory "%s" tvd avi_comp',echowaveexe,tvdFolder);
cmdString = sprintf('cd "%s" & echowave.exe -convert_directory "%s" tvd avi_comp &',echowavePath,tvdFolder);
cmdOutput = dos(cmdString);
uiwait(msgbox('Click button when complete'))


%% rename AVI files

savefilename = 'save_history.txt';

filepath = fullfile(tvdFolder,savefilename);

fid = fopen(filepath);

thisLine = fgetl(fid);
lineNum = 0;
while ischar(thisLine)
    fprintf('%s\n',thisLine)
    thisSplit = strsplit(thisLine,',');
    lineNum = lineNum+1;
    tvd{lineNum} = thisSplit{1};
    cap{lineNum} = thisSplit{2};
    thisLine = fgetl(fid);
end

fclose(fid);

for i = 1:length(tvd)
    
    [~,iTVDname,~] = fileparts(tvd{i});
    tvdPath = fullfile(tvdFolder,[iTVDname,'.avi']);
    [~,iTrial,~] = fileparts(cap{i});
    aviPath = fullfile(tvdFolder,[iTrial,'.avi']);
    copyfile(tvdPath,aviPath,'f');
    delete(tvdPath);
    
end

%% move AVI files to own folder
fprintf('victory!\n')
aviPath = fullfile(tvdFolder,'\..','AVI');
if ~exist(aviPath,'dir')
    mkdir(aviPath);
end

movefile(fullfile(tvdFolder,'*.avi'),aviPath)

% trial name file
