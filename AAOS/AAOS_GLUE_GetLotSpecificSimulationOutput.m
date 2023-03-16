function [TargetVarObs, TargetVarSim, HarvestDays, AvailTestVars, ...
    N_TestVars, N_Sim, N_Sim_txt] =...
    AAOS_GLUE_GetLotSpecificSimulationOutput(LotAnalysisOut, TargetVarNameFull)


%% Target Variable:
% Observed target variable value:
TargetVarObs = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).TargetVarObs;
% Simulated target variable values:
TargetVarSim = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).TargetVarSim;
% Day of Harvest for every simulation:
HarvestDays =  LotAnalysisOut.GLUE_Out.(TargetVarNameFull).HarvestDays;

%% Test Variable:
AvailTestVars = LotAnalysisOut.GLUE_Out.AvailableTestVariables;
% Number of analyzed test variables:
N_TestVars = numel(AvailTestVars);



%% Number of performed simulations:
N_Sim = size(TargetVarSim,1);
N_Sim_txt = string(N_Sim); % text format for plot legend