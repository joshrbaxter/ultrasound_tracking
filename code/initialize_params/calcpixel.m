


close all; clear all; clc;



rootdir = goupdir(pwd,'Motionlab');
% get 
if exist('.\..\lastdir.txt','file')
    fid = fopen('.\..\lastdir.txt','r');
    refdir = fgetl(fid);
    fclose(fid);
    if exist(refdir,'dir')
        subdir = fullfile(rootdir,refdir);
        subdir = uigetdir(subdir,'Select Subject and Session Folder');
    else
        subdir = pwd;
    end
else
    subdir = uigetdir(fullfile(rootdir,'Data'),'Select Subject and Session Folder');
    
end
tmp = strsplit(subdir,'MotionLab');
refdir = tmp{2};
fid = fopen('.\..\lastdir.txt','w+');
txt2write = strrep(refdir,'\','\\');
fprintf(fid,txt2write);
fprintf(fid,'\n');
fclose(fid);

probe = 'p6'
depth = 5;
overwrite_params = 1;
checkdir = fullfile(subdir,'Ultrasound','MP4');
searchfile = ['*',probe,'*'];
if exist(checkdir,'dir')
    searchpath = fullfile(checkdir,searchfile);
else
    searchpath = searchfile;
end
[file,path] = uigetfile(searchpath,'Select image to analyze');

%% ultrasound
% load params file

[~,~,ext] = fileparts(file);
filepath = fullfile(path,file);
if contains(ext,'mp4')
    % plot ultrasound image and drawing of calibration standard
    videoFileReader = vision.VideoFileReader(filepath);
    info = get(videoFileReader);
    vf = step(videoFileReader);
    release(videoFileReader);
    imwrite(vf,[probe,'.png'])
    figure
    imshow([probe,'.png'])
else
    imshow(filepath)
end
% get user input
if contains(probe,'p6')
    if depth == 5
        xaxis = [0,10,20,30,40];
        yaxis = [0,10,20,30,40];
    else
        
    end
end


if contains(probe,'p4')
    if depth == 3
        xaxis = [0,10,20,30,40,50];
        yaxis = [0,10,20,30];
    end
end

if contains(probe,'p3')
    if depth == 2
        xaxis = [0,10,20,30];
        yaxis = [0,10,20];
    elseif depth == 3
        xaxis = [0,10,20,30,40,50];
        yaxis = [0,10,20,30];
    else
        
    end
end


title('select UpperLeft corner')
[cx1,cy1] = ginput(1);

title('select BottomRight corner')
[cx2,cy2] = ginput(1);


title('select x axis points')
for i = 1:length(xaxis)
    [xx(i),yx(i)] = ginput(1);
end

title('select yaxis points')
for i = 1:length(yaxis)
    [xy(i),yy(i)] = ginput(1);
end

px2mmX = abs(mean(diff(xaxis)) / mean(diff(xx)));
px2mmY = abs(mean(diff(yaxis)) / mean(diff(yy)));
pxpermm = 1 / mean([px2mmX,px2mmY])
upperleft_corner = [cx1,cy1]
bottomright_corner = [cx2,cy2]

