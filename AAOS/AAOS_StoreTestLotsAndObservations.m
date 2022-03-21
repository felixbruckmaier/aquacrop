%% Defines arrays for output files and fills in lot-unspecific data:
% a) Model evaluation summary ("ModelEval") -> fill with test lot IDs and
% observed target variable values  
% b) Overview of all simulated and observed values ("SimOut")
function [ModelEval,SimOut] = AAOS_StoreTestLotsAndObservations(Config)


% if Config.RUN_type == "STQ"
%     ModelEval = nan(size(Config.SimulationLots,1),4);
%     ModelEval(:,1) = Config.SimulationLots;
%     ModelEval(:,2) = Config.TargetVar.Observations.All_Lots(Config.SimulationLots,3); % target variable observations (yield or biomass)
% else

    % Set up 'ModelEval' and fill in test lot IDs & target variable
    % observations:
    ModelEval = nan(size(Config.SimulationLots,1),12+6*length(Config.GoF));
    ModelEval(:,1) = Config.SimulationLots;
    ModelEval(:,8) = Config.TargetVar.Observations(Config.SimulationLots,3);

    % Set up 'SimOut':
    SimOut = nan(size(Config.SimulationLots,2),2,5,2);

% end