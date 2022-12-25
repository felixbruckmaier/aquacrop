%% Adopts the config of the parameter set currently active in this round:
% Number, names and respective AOS input file which specifies their value.
function Config = AAOS_ReadParameterConfig(Config)

ParInputData = Config.ParameterValues.(Config.ParameterFileNames(1));
Config.AllParameterNames = table2array(ParInputData(:,1));
% for calibration: calibrated and default parameter file must be equal
% (i.e. contain same parameter names & specifications and lots)

%% USELESS (?) - specified in AAOS_ReadParameterValues:

% Config.AllParameterAOSfile = string(table2array(ParInputData(:,2)));
% Config.AllParameterNumber = size(Config.AllParameterNames,1);

% Coming soon: phenology parameter unit (GDD or calendar type)
%Config.AllParameterPhenoCalType = str2double(string(table2array(ParInputData(:,3))));