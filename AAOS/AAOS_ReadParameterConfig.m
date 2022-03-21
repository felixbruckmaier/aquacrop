%% Stores configuration of current parameters:
% Number, names and respective AOS input file which specifies their value.
function Config = AAOS_ReadParameterConfig(Config)

ParsInputData = Config.ParameterValues.(Config.ParameterFileNames);
Config.AllParameterNames = table2array(ParsInputData(:,1));
Config.AllParameterAOSFile = str2double(string(table2array(ParsInputData(:,2))));
Config.AllParameterNumber = size(Config.AllParameterNames,1);

% Coming soon: phenology parameter unit (GDD or calendar type)
%Config.AllParameterPhenoCalType = str2double(string(table2array(ParsInputData(:,3))));
