%% Writes AAOS model input parameters to AOS files (extra function), ...
% in case also adjust simulation period:
function AAOS_WriteModelParameters(Directory,Config)

% Get current parameter specifications:


FileNames = string(Config.AllParameterAOSfile);
ParNames = string(Config.AllParameterNames);
ParValues = Config.AllParameterValues;
[FileNames,sortIdx] = sort(FileNames,'ascend');
ParNames = ParNames(sortIdx);
ParValues = ParValues(sortIdx);

% In case, adjust simulation period to demands of user-input values:
[SimPeriodVals,~,LocY_SimPeriod] = AAOS_ConvertSimPeriodParameters(Config,ParNames,ParValues);
ParValues(LocY_SimPeriod>0) = abs(SimPeriodVals(LocY_SimPeriod(LocY_SimPeriod>0)));

% Write parameter values to AOS files:
AAOS_WriteAOSinputFiles(Directory,Config,ParNames,ParValues,FileNames);