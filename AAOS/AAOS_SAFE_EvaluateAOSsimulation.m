function [SimVar,TestSimVarSize] = ...
    AAOS_SAFE_EvaluateAOSsimulation(InputTestPar,Config,Directory)

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

% Read & store simulated values of...
% TargetVarName = Config.TargetVar.NameShort;
% a) both target variables & biomass loss:
Config.TargetVar.NameFull_temp = Config.TargetVar.NameFull;
Config.TargetVar.NameFull = "BM";
Config = AAOS_ReadAOSsimulationOutput(Config,"BM",[]);
SimVar(1) = Config.SimTargetVariable;
SimVar(2) = Config.SimBiomassLoss;
Config.TargetVar.NameFull = "Y";
Config = AAOS_ReadAOSsimulationOutput(Config,"Y",[]);
SimVar(3) = Config.SimTargetVariable;
Config.TargetVar.NameFull = Config.TargetVar.NameFull_temp;

% b) test variables (in case defined *(1), and available *(2) ):
TestSimVarSize = [1, nan; 2, nan];
TestVarIds = Config.TestVarIds;
if ~isempty(TestVarIds) % *(1)
    for idx2 = 1:numel(TestVarIds)
        TestVarIdx = TestVarIds(idx2);
        [~,TestVarName] = AAOS_SwitchTestVariable(TestVarIdx);
        [TestVarObs] = AAOS_ReadTestVariableObservations...
            (Directory, Config, TestVarName);
        if ~isempty(TestVarObs) % *(2)
            Config = AAOS_ReadAOSsimulationOutput(Config,TestVarName,TestVarObs);
            SimTestVariable = Config.SimTestVariable;
            TestSimVarSize(idx2,2) = size(TestVarObs,1);
            SimVar(end+1 : end+TestSimVarSize(idx2,2)) = SimTestVariable;
        end
    end
end

