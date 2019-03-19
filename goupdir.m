function [ path2,message,messageID ] = goupdir( path,targetDir )
%GOUPDIR returns directory path that has gone up numDir levels
%   Detailed explanation goes here

if nargin < 2
    targetDir = 1;
end

fileSepInd = strfind(path,filesep);

if ischar(targetDir)
    % go up directories until in the path that was specific
    checkDir = [filesep,lower(targetDir),filesep];
    dirInd = strfind(lower(path),checkDir);
    if any(dirInd)
        % return the path at desired directory level
        targInd = find(fileSepInd > dirInd(end));
        path2 = path(1:fileSepInd(targInd)-1);
        message = sprintf('Target directory: %s found!',targetDir);
        messageID = 2;
    else % return input path
        path2 = path; 
        message = sprintf('Warning!!! Target directory: %s not found!',targetDir);
        messageID = -1;
    end
    
else % targetdir is a number
    
    path2 = path(1:fileSepInd(end-targetDir+1)-1);
    message = ['Target directory found!'];
    messageID = 1;
end





end

