function pts = definephantom()

pts(:,1) = [40.0 50.0 45.0];
pts(:,2) = [37.5 47.5 45.0];
pts(:,3) = [35.0 50.0 45.0];
pts(:,4) = [35.0 35.0 45.0];
pts(:,5) = [32.5 32.5 45.0];
pts(:,6) = [30.0 35.0 45.0];
pts(:,7) = [30.0 45.0 45.0];
pts(:,8) = [25.0 35.0 45.0];
pts(:,9) = [25.0 25.0 45.0];
pts(:,10) = [20.0 25.0 45.0];

mrkrRadius = 5;

pts(2,:) = pts(2,:) - mrkrRadius; % reduce the height of all pts by marker radius

% convert to m
pts = pts * 0.001;