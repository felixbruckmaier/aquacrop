%% CHANGE: read all observations once, store them in a struct, and access
% them when needed (-> adopt from GLUE)
function [ObsTestVar] = AAOS_ReadTestVariableObservations(Directory, Config, TestVarNameShort)

% Initial Soil Water Content
Config = AAOS_WriteInitialSoilWaterContent(Config,Directory);

% Assign SWC depth to be tested (set to "1" when analyzing Canopy Cover):
% -> column idx
if TestVarNameShort == "SWC"
    idx_Observation = Config.idx_SimDepthsObservations(Config.idx_TestSWC);
elseif TestVarNameShort == "CC"
    idx_Observation = 1;
end
% Read observed values for given test variable & depth:
[ObsTestVar,~] = AAOS_ReadTestVariableObservationsFile(Directory,Config,...
    TestVarNameShort,idx_Observation);