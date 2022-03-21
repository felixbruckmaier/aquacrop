function Config = AAOS_DetermineSimulationLots(Config)

% if Config.CalibrationLots == 0 % '0' = simulate all available lots
%     Config.SimulationLots = Config.TargetVarObsAllPlots(:,2);
% else
    Config.SimulationLots = Config.SimulationLots';
% end

%Config.CalibrationLots = Config.CalibrationLots';
%Config.ValidationLots = Config.ValidationLots';