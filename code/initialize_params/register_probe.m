% function subdir = register_probe()
%REGISTER_PROBE - calculates probe transforms in motion capture cast and
%saves in ultrasound data folder for additional processing
% version history
% josh baxter - joshrbaxter@gmail.com - 2017-12-11


%% 
fclose('all');clear variables; close all; warning('off','all');

%%
rootdir = goupdir(pwd,'Motionlab');
% get 
if exist('.\..\lastdir.txt','file')
    fid = fopen('.\..\lastdir.txt','r');
    refdir = fgetl(fid);
    fclose(fid);
    subdir = fullfile(rootdir,refdir);
    subdir = uigetdir(subdir,'Select Subject and Session Folder');
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

% check for ultrasound structure and move if neccessary
checkusdir = fullfile(subdir,'Ultrasound');
if ~exist(checkusdir,'dir')
    mkdir(checkusdir);
    fprintf('Ultrasound folder created...\n');
    
    checkclip = fullfile(subdir,'Clips');
    checkmp4 = fullfile(subdir,'MP4');
    if exist(checkclip,'dir')
        movefile(checkclip,fullfile(checkusdir,'Clips'));
        fprintf('Clips moved to Ultrasound folder...\n');
    else
        warning('Clips does not exist... yell at todd...')
    end
    if exist(checkmp4,'dir')
        movefile(checkmp4,fullfile(checkusdir,'MP4'));
        fprintf('MP4 moved to Ultrasound folder...\n');
    else
        warning('MP4 does not exist... yell at todd...')
    end
end

viddir = fullfile(subdir,'Ultrasound','MP4');
mocapdir = fullfile(subdir,'trc_forces');
% user inputs - which probes to register
% probe = {'3cm','4cm','6cm'};
% probetxt = {'p3','p4','p6'};

% Select probes used in study session
probe = {'4cm','6cm'};
% probe = {'4cm'};
probetxt = {'p4','p6'};
probedepth = [3,5];
usedefault = [0 0];
update_px = [1 1];
scrsz = get(0,'Screensize');
fight = 700;
figwd = 1600;
scrx = 0.5 * (scrsz(3) - figwd);
scry = 0.5 * (scrsz(4) - fight);
pts = definephantom;
nPts = length(pts);


% user
%% computer specific parameters
listOfInitials = {'jrb', 'tjh', 'as','ns','mocap', 'your initials here'};
listOfUsers = {'baxterj', 'hullfist','annelisS','stefanin','PennMedicine','your UPHS user name here'};

[rootDir] = goupdir(pwd,'Box Sync');
[userDir] = goupdir(rootDir,1);
if strcmp(userDir, 'E:')
    userName = 'hullfist';
else
    [~,userName,~] = fileparts(userDir);
end
userInd = strcmpi(userName,listOfUsers);
userInd = find(userInd);
if ispc
    userInitials = listOfInitials{userInd};
else
    userInitiatls = 'xxx';
end

for i = 1:length(probe)
    iprobe = probe{i};

    % if user wants to redefine calibration...
    if ~usedefault(i)
               
        %user select motion capture trial
        iCalibTrials = fullfile(mocapdir,[probetxt{i},'*cal*']);
        itrials = dir(iCalibTrials);
        inumcalib = size(itrials);
        if inumcalib(1) > 1
            % get user input
            for ii = 1:inumcalib(1)
                iitrialname{ii} = itrials(ii).name;
            end
            [s,v] = listdlg('PromptString','Select Calibration trial to Analyze:',...
                    'SelectionMode','single','ListString',iitrialname);
             itrialname = itrials(s).name;
        else
            itrialname = itrials(1).name;
        end
        
        %load mocapdata
        iCalibTRCprobepath = fullfile(mocapdir,itrialname,[itrialname,'_probe_',iprobe,'.trc']);
        if ~exist(iCalibTRCprobepath, 'file')
            iCalibTRCprobepath = fullfile(mocapdir,itrialname,[itrialname,'_p4_pt4.trc']);
            iprobe = 'p4_pt4';
        end
        iCalibTRCcalibrationjigpath = fullfile(mocapdir,itrialname,[itrialname,'_calibration_jig.trc']);
        iTRCprobe = readtrc(iCalibTRCprobepath);
        iTRCcalibrationjig = readtrc(iCalibTRCcalibrationjigpath);

        % plot ultrasound image and drawing of calibration standard
        videoFileReader = vision.VideoFileReader(fullfile(viddir,[itrialname,'.mp4']));
        info = get(videoFileReader);
        vf = step(videoFileReader);
        px = [];
        if update_px(i)
            % get user input
            figure
            set(gcf,'position',[scrx,scry,figwd,fight]);
            imshow(vf);
            switch probetxt{i}
                case 'p6'
                    if probedepth(i) == 5
                        xaxis = [0,10,20,30];
                        yaxis = [0,10,20,30];
                    else

                    end
                case 'p4'
                    if probedepth(i) == 3
                        xaxis = [0,10,20,30];
                        yaxis = [0,10,20,30];
                    end
   
                case 'p3'
                    if probedepth(i) == 2
                        xaxis = [0,10,20,30];
                        yaxis = [0,10,20];
                    elseif probedepth(i) == 3
                        xaxis = [0,10,20,30];
                        yaxis = [0,10,20,30];
                    else

                    end
            end % end switch


            title('select UpperLeft corner')
            [cx1,cy1] = ginput(1);

            title('select BottomRight corner')
            [cx2,cy2] = ginput(1);


            title('select x axis points')
            for ii = 1:length(xaxis)
                [xx(ii),~] = ginput(1);
            end

            title('select yaxis points')
            for ii = 1:length(yaxis)
                [~,yy(ii)] = ginput(1);
            end

            px.px2mmX = abs(mean(diff(xaxis)) / mean(diff(xx)));
            px.px2mmY = abs(mean(diff(yaxis)) / mean(diff(yy)));
            pxpermm = 1 / mean([px.px2mmX,px.px2mmY]);
            upperleft_corner = [cx1,cy1];
            bottomright_corner = [cx2,cy2];
            px.ulcornerx = cx1;
            px.ulcornery = cy1;
            px.nx = cx2-cx1;
            px.ny = cy2-cy1;
            close(gcf)
            clear xx yy xaxis yaxis
        end
        
        ifcnname = ['params_',iprobe]; 
        Params = feval(ifcnname,px);
        clear px
        vf = imcrop(vf,Params.imCropRect);
        release(videoFileReader);
        figure
        set(gcf,'position',[scrx,scry,figwd,fight]);
        subplot(1,2,1)
        imshow('new_image_calibration.png')
        subplot(1,2,2)
        imshow(vf);
        
        % select points from first frame - phantom registration
        x = []; y = [];
        for ii = 1:nPts
            title(sprintf('Select point %d',ii))
            [x(ii),y(ii)] = ginput(1);
        end
        
        
        user_pts_im = zeros(3,nPts);
        user_pts_im(1,:) = Params.px2mmX * x;
        user_pts_im(2,:) = Params.px2mmY * y;
        user_pts_im = 0.001 * user_pts_im;

        vf = insertMarker(vf,[x;y]','+');
        
        imshow(vf)
        title('user select points')
        frame = 1;
        pause(2)
        close gcf
        % construct CS for probe and phantom from frame i
        % probe
        pr1 = iTRCprobe.xyz.PR1(frame,:);
        pr2 = iTRCprobe.xyz.PR2(frame,:);
        pr3 = iTRCprobe.xyz.PR3(frame,:);
        T_G_Probe = mkT(pr1,pr2,pr3);
        T_Probe_G = invT(T_G_Probe);
        % phantom = 
        ph1 = iTRCcalibrationjig.xyz.CAL1(frame,:);
        ph2 = iTRCcalibrationjig.xyz.CAL2(frame,:);
        ph3 = iTRCcalibrationjig.xyz.CAL3(frame,:);
        T_G_Phantom = mkT(ph1,ph2,ph3);

        pts_in_G = transformpoints(T_G_Phantom,pts);
        pts_in_Probe = transformpoints(T_Probe_G,pts_in_G);

        Params.T_PR_IM = lsqRT(pts_in_Probe,user_pts_im); 
        T = Params.T_PR_IM
    end
    % save user details
    Params.date_time_probe_registration = datestr(now,'yyyymmdd_HHMMSS');
    Params.userInitials_probe = userInitials;
    Params.default_T_PR_IM = usedefault(i);
    
    %save Paramsstruct for subject specific data analysis
    iParamsName = fullfile(subdir,'ultrasound',[probetxt{i},'_params.mat']);
    save(iParamsName,'Params');
    clear Params; close all;
end

fprintf('registration complete!\n')
