function [SimTestVar] = ...
    AAOS_SAFE_EvaluateAOSsimulation(InputTestPar,Config,Directory)

%% Temporary solution - adjust AAOS_WriteModelParameters
% ParNames = Config.AllParameterNames;
% N_Par = size(ParNames,1);
% AllParIdcs = 1:N_Par;
% Config.TestParameterIdx = AllParIdcs;

% Transfer current sample row from ValueMatrix to array that will be
% accessed to get simulation values
Config.AllParameterValues = InputTestPar;

% Initial Soil Water Content (might change in response to SHP):
Config = AAOS_WriteInitialSoilWaterContent(Config,Directory);

% Write parameter values to AOS input files:
AAOS_WriteModelParameters(Directory,Config);

% Run AOS simulation with now updated input files:
cd(Directory.AOS);
AquaCropOS_RUN;
cd(Directory.BASE_PATH)

% Read & store simulated values of target and test variables:
TestVarNameShort = "";
ObsTestVar = [];
[Config,SimTestVar] = ...
    AAOS_ReadAOSsimulationOutput(Config,TestVarNameShort,ObsTestVar);