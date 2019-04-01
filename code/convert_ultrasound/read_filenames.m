% read_filenames.m

clear all; close all; clc;

savefilename = 'save_history.txt';

filepath = fullfile('.\',savefilename);


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