function [Data,Params] = trackablepoints_manual(Data,videoFrame,Params,i,pts0)

% videoFrame = Data.frame(end).videoFrame;

if nargin < 5 % get user input for points otherwise build points from current available pts
    if i1 == 1
        figure('Position',Params.figPos)
        imshow(videoFrame)
        hold on
    end
    if Params.blindUser
        tname = 'Blinded Review';
    else
        [~,tname,~] = fileparts(Data.trialName);
        tname = strrep(tname,'_','\_');
    end
    
    iTitle = sprintf('Select %s - Trial: %s',Params.landmarkString{i1},tname);
    title(iTitle)
    iLine = imline();
    pts0 = iLine.getPosition();
    initPts = true;
else
    initPts = false;
end

% fit line to screen (aponeourses, i<3) or fascicle to apenoursis (i > 2)
p = polyfit(pts0(:,1),pts0(:,2),1);
% pts1x will expand best fit line to cover width of image for aponerousis
% or length of fascicle for fascicle
if i1 < 3
    thesePts(:,1) = [1;Params.nx];
    thesePts(:,2) = polyval(p,thesePts(:,1));
else
    % calc intersection between fascicle and aponeurosis
    %deep aponeurosis = 1; superficial aponeurosis = 2
    
    ptsx = [1;Params.nx];

    p1 = polyfit(Data.frame(end).pts{1}(:,1),Data.frame(end).pts{1}(:,2),1);
    p2 = polyfit(Data.frame(end).pts{2}(:,1),Data.frame(end).pts{2}(:,2),1);
    
    pts1y = polyval(p1,ptsx);
    pts2y = polyval(p2,ptsx);
    
    pts0_1 = [ptsx,pts1y];
    pts0_2 = [ptsx,pts2y];
    
    [intx1,inty1] = linesintersect(pts0_1,pts0);
    [intx2,inty2] = linesintersect(pts0_2,pts0);

    % fascicle end points
    thesePts = [intx1,inty1;intx2,inty2];
    
    % check pts1 - if leave image - refit
    pts1x = thesePts(:,1);
    pts1x(pts1x < 1) = 1;
    pts1x(pts1x > Params.nx) = Params.nx;
    pts1y = polyval(p,pts1x);
    thesePts = sort([pts1x,pts1y]);
end
Data.frame(end).pts{i} = thesePts;
Data.frame(end).endPts{i} = thesePts;
Data.frame(end).redefinePtsFlag(i1,1) = 1;

end % end gettrackablepts