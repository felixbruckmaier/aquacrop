%% Run default analysis: Simulation for 1 (default) set of parameter values
% for the specified paramerer set and the current lot & target variable
function [Config,ModelOut] =...
    AAOS_PerformModelEvaluation(Config,Directory,ModelOut)

% Get number of test variables
TestVarIds = Config.TestVarIds;

% Determine number of simulation rounds
% (1 SimRound = simulation/evaluation of variable CC and/or SWC)
if Config.RUN_type == "DEF"
    Config.SimRounds = 1;
    [Config,ModelOut] = AAOS_ModelEval_PerformSimulationRound(...
        Config,Directory,ModelOut,TestVarIds,Config.SimRounds);
elseif Config.RUN_type == "CAL"
    FileNames = ["DEF","CAL"];
    Config.SimRounds = 1 + size(TestVarIds,2);
     for SimRound = 1:Config.SimRounds
         Config.ParFileType = FileNames(min(2,SimRound));
         [Config,ModelOut] = AAOS_ModelEval_PerformSimulationRound(...
             Config,Directory,ModelOut,TestVarIds,SimRound);
     end
end



