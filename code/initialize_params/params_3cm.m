function Params = params_3cm()

%% set params
Params.verbose = false;
Params.nr = 641;
Params.nc = 798;
Params.screenSize = get(0,'Screensize');
xpos = ceil((Params.screenSize(3)-Params.nc)/2); % center the figure on the screen horizontally
ypos = ceil((Params.screenSize(4)-Params.nr)/2); % center the figure on the screen vertically
Params.figPos = [xpos,ypos,[Params.nc,Params.nr]+30];
Params.imCropRect = [219 42 Params.nc Params.nr]; % for 4cm Telemed probe with 4cm depth
Params.px2mmX = 1/30.65; % for 3cm Telemed probe with 2cm depth
Params.px2mmY = 1/30.65; % for 3cm Telemed probe with 2cm depth
% Params.px2mmX = 1/20.73; % for 3cm Telemed probe with 3cm depth
% Params.px2mmY = 1/20.73; % for 3cm Telemed probe with 3cm depth



end