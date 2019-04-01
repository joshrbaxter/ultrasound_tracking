function Params = params_6cm(Params)

%% parameters

%% set params
if nargin < 1
    if ~isstruct(Params) % load default parameters
        Params.ulcornerx = 210;
        Params.ulcornery = 44;
        Params.nx = 727;
        Params.ny = 585;
        Params.px2mmX = 1/11.30; % for 6cm Telemed probe with 5cm depth
        Params.px2mmY = 1/11.30; % for 6cm Telemed probe with 5cm depth
        % Params.px2mmX = 1/12.6; % for 6cm Telemed probe with 5cm depth
        % Params.px2mmY = 1/12.6; % for 6cm Telemed probe with 5cm depth
        
    end
end
Params.probe = '6cm';
Params.screenSize = get(0,'Screensize');
% xpos = ceil((Params.screenSize(3)-Params.nx)/2); % center the figure on the screen horizontally
% ypos = ceil((Params.screenSize(4)-Params.ny)/2); % center the figure on the screen vertically
xpos = 100; % center the figure on the screen horizontally
ypos = 100; % center the figure on the screen vertically

Params.figPos = [xpos,ypos,[Params.nx,Params.ny]+30];
Params.imCropRect = [Params.ulcornerx Params.ulcornery Params.nx Params.ny];



Params.padBorder = round(5 * Params.px2mmX);

Params.T_PR_IM =  [ 1.0000         0         0         0; % define 2017-12-12 - jrb
                    0.0180    0.9310   -0.3639   -0.0295;
                    0.0023    0.0244   -0.0184    0.9995;
                   -0.0242   -0.3643   -0.9312   -0.0083 ];
end