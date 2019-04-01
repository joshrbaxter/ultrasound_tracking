function Params = params_4cm(Params)

%% set params
if nargin < 1
    if ~isstruct(px) % load default parameters
        Params.ulcornerx = 216;
        Params.ulcornery = 46;
        Params.nx = 715;
        Params.ny = 578;
        Params.px2mmX = 1/18.7; % for 4cm Telemed probe with 3cm depth
        Params.px2mmY = 1/18.7; % for 4cm Telemed probe with 3cm depth
        % Params.px2mmX = 1/15.70; % for 4cm Telemed probe with 4cm depth
        % Params.px2mmY = 1/15.70; % for 4cm Telemed probe with 4cm depth
        % Params.px2mmX = 1/20.80; % for 4cm Telemed probe with 3cm depth - before ATP2
        % Params.px2mmY = 1/20.80; % for 4cm Telemed probe with 3cm depth

        
    end
end

Params.verbose = false;

Params.screenSize = get(0,'Screensize');
% xpos = ceil((Params.screenSize(3)-Params.nc)/2); % center the figure on the screen horizontally
xpos = 100; % center the figure on the screen horizontally
% ypos = ceil((Params.screenSize(4)-Params.nr)/2); % center the figure on the screen vertically
ypos = 100; % center the figure on the screen vertically
Params.figPos = [xpos,ypos,[Params.nx,Params.ny]+30];
Params.imCropRect = [Params.ulcornerx Params.ulcornery Params.nx Params.ny];



Params.xboundary_mm = 2;
Params.xboundary_px = round(Params.xboundary_mm / Params.px2mmX);
Params.xboundary = [Params.xboundary_px, Params.nx-2*Params.xboundary_px];


% 3cm scan depth - ATP2_S004
Params.T_PR_IM =  [ 1.0000         0         0         0;
                   -0.0841    0.8808   -0.4690   -0.0649;
                   -0.0207   -0.1073   -0.0643   -0.9921;
                    0.1726    0.4611    0.8809   -0.1070];
% % 3cm scan depth - pilot ankle power
% Params.T_PR_IM =  [ 1.0000         0         0         0;
%                     0.0747    0.9462   -0.2936   -0.1357;
%                     0.0194    0.1597    0.0593    0.9854;
%                    -0.1694   -0.2813   -0.9541    0.1030];

% CS002
% Params.T_PR_IM =  [ 1.0000         0         0         0;
%                     0.0726   -0.9580    0.2825   -0.0488;
%                    -0.0240    0.0116   -0.1319   -0.9912;
%                    -0.1745   -0.2865   -0.9501    0.1231];
% 4cm scan depth
% Params.T_PR_IM = [  1.0000         0         0         0;
%                     0.1999    0.5495    0.8355    0.0049;
%                    -0.0208    0.0061    0.0019   -1.0000;
%                     0.1686   -0.8355    0.5495   -0.0040];

end