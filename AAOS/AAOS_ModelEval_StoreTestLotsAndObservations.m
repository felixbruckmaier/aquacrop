%% Defines arrays for output files and fills in lot-unspecific data:
% a) Model evaluation summary ("ModelEval") -> fill with test lot IDs and
% observed target variable values
% b) Overview of all simulated and observed values ("SimOut")
function [ModelOut] = AAOS_ModelEval_StoreTestLotsAndObservations(Config,ModelOut)

global AOS_InitialiseStruct

%% To be used in Option "Stress Quantification"
% if Config.RUN_type == "STQ"
%     ModelEval = nan(size(Config.SimulationLots,1),4);
%     ModelEval(:,1) = Config.SimulationLots;
%     ModelEval(:,2) = Config.TargetVar.Observations.All_Lots(Config.SimulationLots,3); % target variable observations (yield or biomass)
% else

% Set up 'ModelEval' and fill in test lot IDs & target variable
% observations:
ModelEval = nan(size(Config.SimulationLots,2),12+6*length(Config.GoF));
ModelEval(:,1) = Config.SimulationLots';
ModelEval(:,8) = Config.TargetVar.Observations(Config.SimulationLots,3);
ModelOut.ModelEvaluation = ModelEval;

% Set up 'SimOut' - only for DEF/ CAL analysis:
SimLengthMax = size(AOS_InitialiseStruct.Weather,1);
[~,idx_analysis] = ismember(Config.RUN_type,["DEF","CAL"]);
if idx_analysis > 0
    N_testvar = min(max(Config.TestVarIds),2);
    SimOut = NaN(numel(Config.SimulationLots),...
        SimLengthMax,2+idx_analysis+N_testvar-1,N_testvar);
    ModelOut.SimulationOutput = SimOut;
end


% end