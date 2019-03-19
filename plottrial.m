function [ videoFrame ] = plottrial( Data,videoFrame,Params,frame,structure2plot )
%PLOTTRIAL   
 
% if ~exist('structure2plot','var')
if nargin < 5
    structure2plot = [1:3];
end
% update videoFrame with aponeurosis and fascicle lines   
for i1 = structure2plot
    
    iLandmarkString = Params.landmarkString{i1};
    
    if Params.showLines && Data.manual == 0
        iColor = 'white';
        % plot best fit lines
        iLineX = Data.frame(frame).fascicle.plotInsertions(i1).x;
        iLineY = Data.frame(frame).fascicle.plotInsertions(i1).y;
        iLineXY = [iLineX(1),iLineY(1),iLineX(2),iLineY(2)];
        
        if Data.manual
            linew = 1;
            alphaval = 0.5;
        else
            linew = 3;
            alphaval = 1;
        end
        
        videoFrame = insertShape(videoFrame,'line',iLineXY,...
            'Color',iColor,'LineWidth',linew,'opacity',alphaval);

        if i1 == 3% plot fascicle angle and length
            if iLineX < 0
                iLineX = 0;
            end
            fascicleStringPos = [25, Params.ny-25];
            fascicleString = sprintf('Fascicle Length: %2.1f mm\nPennation Angle: %2.0f degrees',...
                Data.frame(frame).fascicle.length,Data.frame(frame).fascicle.pennation);
            videoFrame = insertText(videoFrame,fascicleStringPos,fascicleString,...
                'FontSize',18,'TextColor','white','AnchorPoint','LeftBottom');
        end
    end

        
    if Params.plotPoints && Data.manual == 0 && Data.validate == 0% display points being tracked
        iPts = Data.frame(frame).pts{i1};
        iColor = Params.markerColor{i1};
        videoFrame = insertMarker(videoFrame,iPts,'+','Color',iColor);

    end
    
    if Params.displayPtRetention && Data.manual == 0 && Data.validate == 0 % display info on # of points being tracked
        iNpts = size(Data.frame(frame).pts{i1},1);
        ioPts = Data.frame(frame).oPts(i1);
        iPercent = round((iNpts / ioPts) * 100);
        ptRetentionStr{i1} = sprintf('%s: %i%% (%i/%i)',iLandmarkString,...
            iPercent,iNpts,ioPts);
    end

end
    
 % write trial name on screen
 if Params.blindUser
     txt2disp = 'Blinded Review';
 else
    [~,txt2disp,~] = fileparts(Data.trialName);
 end

txtPos = [Params.nx-25,Params.ny-25];
if Params.displayPtRetention && Data.manual == 0 && Data.validate == 0
    
    m = [length(txt2disp),length(ptRetentionStr{1}),...
        length(ptRetentionStr{2}),length(ptRetentionStr{3})];
    strL = max(m)+3;
    txt2disp = [txt2disp,blanks(strL-length(txt2disp))];
    txt2disp = strvcat(txt2disp,ptRetentionStr{1},ptRetentionStr{2},ptRetentionStr{3});
    txt2disp = sprintf('%s\n%s\n%s\n%s',txt2disp(1,:),txt2disp(2,:),txt2disp(3,:),txt2disp(4,:));
end
videoFrame = insertText(videoFrame,txtPos,txt2disp,...
    'FontSize',12,'TextColor','white','AnchorPoint','RightBottom');

end


