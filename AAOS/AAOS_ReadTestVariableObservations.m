%% CHANGE: read all observations once, store them in a struct, and access
% them when needed (-> adopt from GLUE)
function [ObsTestVar] = AAOS_ReadTestVariableObservations(Directory, Config, TestVarNameShort)

% Initial Soil Water Content
Config = AAOS_WriteInitialSoilWaterContent(Config,Directory);

idx_Observation = Config.SWC_depth;

% Read observed values for given test variable & depth:
[ObsTestVar,~] = AAOS_ReadTestVariableObservationsFile(Directory,Config,...
    TestVarNameShort,idx_Observation);