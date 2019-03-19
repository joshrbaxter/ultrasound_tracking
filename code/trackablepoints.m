function [Data,Params] = trackablepoints(Data,videoFrame,Params,i1,pts0)
%joshrbaxter@gmail.com
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

% rotate image and line
theta = atan2(p(1),1); % angle from horizontal
iTform = affine2d([cos(theta) -sin(theta) 0;...
                    sin(theta) cos(theta) 0; 0 0 1]);
[im2,~] = imwarp(videoFrame,iTform,'nearest');

% line transform requires a rotation + translation
[X2,Y2] = transformPointsForward(iTform,thesePts(:,1),thesePts(:,2)); % rotate line
shiftX = abs(sin(theta)) * Params.ny;
shiftY = abs(sin(theta)) * Params.nx;

if theta < 0 % shift line x Data.frame(end) by amount of rotation*#ofrows 
   X2 = X2+shiftX; 
else % shift line y Data.frame(end) by amount of rotation*#ofcolumns
   Y2 = Y2+shiftY;
end

% detect best points for tracking
% moveInPx = Params.rectHt * abs(sin(theta)) + round(Params.padBorder(i1)); % user defined padding
rectLength1 = abs(X2(2)-X2(1));
moveInPx = Params.padBorder(i1) * rectLength1; % user defined padding
rectLength2 = rectLength1 - 2*moveInPx;
rectROI = [X2(1)+moveInPx, Y2(1)-Params.rectHt, rectLength2,2*Params.rectHt];
roi2Points = bbox2points(rectROI(1,:));

if i1 < 2 % set image contrast - only perform contrasting for deep aponeurosis
    if initPts
        tmpInd = uint16(roi2Points);
        tmpIm2 = im2(tmpInd(1,2):tmpInd(4,2),tmpInd(1,1):tmpInd(2,1));
        maxTmpIm2 = max(tmpIm2);
        stdTmpIm2 = std(tmpIm2);
        threshTmpIm2 = mean(maxTmpIm2) - 1.0 * mean(stdTmpIm2);
        Params.thresholdAponeurosis(i1) = threshTmpIm2;
    end
    im2 = (im2 < Params.thresholdAponeurosis(i1)) == 0;
%     rectROI
%     figure
%     imshow(im2)
end

detect_im2 = detectMinEigenFeatures(im2,'ROI',rectROI);
points_im2 = detect_im2.Location;
npoints_im2 = detect_im2.Count;

% reduce number of tracking points to user defined
if npoints_im2 > Params.maxTrackingPts(i1) 
    %get an even distribution of points from left->right of image
    ind = round(linspace(1,npoints_im2,Params.maxTrackingPts(i1)));
    points_im2 = points_im2(ind,:);    
end

% transform points back to image coordinate system
if theta < 0 %shift X back
    points_im2(:,1) = points_im2(:,1)...
        - repmat(shiftX,length(points_im2),1);
else % shift Y batk
    points_im2(:,2) = points_im2(:,2)...
        - repmat(shiftY,length(points_im2),1);
end
[points1X,points1Y] = transformPointsInverse(iTform,...
    points_im2(:,1),points_im2(:,2));
pts_trackable = [points1X,points1Y];
pts_trackable_endptsx = [min(points1X);max(points1X)];
pts_trackable_endptsy = polyval(p,pts_trackable_endptsx);
pts_trackable_endpts = [pts_trackable_endptsx,pts_trackable_endptsy];

Data.frame(end).pts{i1} = pts_trackable;
Data.frame(end).endPts{i1} = pts_trackable_endpts;
Data.frame(end).redefinePtsFlag(i1,1) = 1;

end % end gettrackablepts
