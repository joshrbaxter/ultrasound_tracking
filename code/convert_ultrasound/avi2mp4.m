function avi2mp4( aviPath, mp4Path )
%AVI2MP4 Converts a given AVI into an MP4
%   Takes a file path, loads in the AVI through the vision toolbox, and
%   then steps through each frame and stores as an MP4
if nargin == 1
    [aviFolder, ~, ~] = fileparts(aviPath);
    mp4Path = uigetdir(aviFolder);
elseif nargin == 2
    aviPath = aviPath;
    mp4Path = mp4Path;
end

%aviPath = 'C:\TEMP_ULTRASOUND\AGR001\S1\AVI\p6_isokinetic030_01.avi';
%mp4Path = 'C:\TEMP_ULTRASOUND\AGR001\S1\MP4';

avi = aviPath;
[~, aname, ~] = fileparts(aviPath);
mp4 = fullfile(mp4Path, [aname, '.mp4']);
vfr = vision.VideoFileReader(avi);
v_info = info(vfr);
fr = round(v_info.VideoFrameRate);
clip = VideoWriter(mp4, 'MPEG-4');
clip.FrameRate = fr;
open(clip)
while ~isDone(vfr)
    frame = step(vfr);
    writeVideo(clip, frame)
end
close(clip)
release(vfr)
 
end

