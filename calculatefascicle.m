function [ Fascicle ] = calculatefascicle( Data,Params )
%calculatefascicles 

%  fit lines to data points, find end points, and calculate fascicle
    % parameters
    
    % fit lines to data points   
    for i1 = 1:3
        iPts = Data.pts{i1};
        iX = iPts(:,1);
        iY = iPts(:,2);

        ip{i1} = polyfit(iX,iY,1);

        iXpts = [min(iX);max(iX)];
        iYpts = polyval(ip{i1},iXpts);
        linePts(i1).x = iXpts;
        linePts(i1).y = iYpts;
        
        % calculate line points for end of frame of animating purposes
        if i1 < 3
            linePtsPlot(i1).x = [1;Params.nx];
            linePtsPlot(i1).y = polyval(ip{i1},linePtsPlot(i1).x);
        end
    end

    % find intersections between lines 1-3 and 2-3 (fascicle insertions)
    lineCombination = [1,3;2,3]; % set 1 - deep apo+fascicle; set 2 - super apo+fascicle
    for i1 = 1:2
        iLineCom = lineCombination(i1,:);
       
        l1 = [linePts(iLineCom(1)).x,linePts(iLineCom(1)).y];
        l2 = [linePts(iLineCom(2)).x,linePts(iLineCom(2)).y];
        % calculate point of intersection between aponeurosis and fascicle
        [interceptPtX(i1),interceptPtY(i1)] = linesintersect(l1,l2);
    end
    linePtsPlot(3).x = [interceptPtX(1);interceptPtX(2)];
    linePtsPlot(3).y = [interceptPtY(1);interceptPtY(2)];
    
    % calculate fascile length and pennation angle
    % fascicle length
    fascicleXmm = interceptPtX * Params.px2mmX;
    fascicleYmm = interceptPtY * Params.px2mmY;
    fascicleL = sqrt(diff(fascicleXmm).^2+diff(fascicleYmm).^2);

    % pennation angle
    u = [ip{1}(1),1,0];
    v = [ip{3}(1),1,0];
    pennation = atan2d(norm(cross(u,v)),dot(u,v));
    
    %% data to return
    Fascicle.length = fascicleL;
    Fascicle.pennation = pennation;
    Fascicle.insertionDeep_px = [interceptPtX(1),interceptPtY(1)];
    Fascicle.insertionSuperficial_px = [interceptPtX(2),interceptPtY(2)];
    Fascicle.insertionDeep_mm = [fascicleXmm(1),fascicleYmm(1)];
    Fascicle.insertionSuperficial_mm = [fascicleXmm(2),fascicleYmm(2)]; 
    Fascicle.plotInsertions = linePtsPlot;
    Fascicle.polycoef = ip;
    
end

