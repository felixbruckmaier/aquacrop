%% Calculate Goodness of Fit criteria for test variables using all used values
% during the analysis, i.e. a timeseries with values from all tested lots.
%% Required adjustments:
% - SimOut not used in "STQ" analysis
% - SimRounds for other analysis
function [ModelOut] = AAOS_ModelEval_CalculateGoFsOverall(Config,ModelOut)

% Get 2 output arrays from model output structure:
ModelEval = ModelOut.ModelEvaluation;
SimOut = ModelOut.SimulationOutput;

% Set up row for overall GoFs:
row_GoFtotal = size(ModelEval,1)+1;
ModelEval(row_GoFtotal,:) = nan;

% Number of calculated GoF's per lot, max. 3 (DEF / CAL / REC) - substract
% HI round (= #4), since HI calibration does not produce a GoF value:
N_SimRounds = min(Config.SimRounds,3);

% Determine number of GoF rounds from number of test variables;
% 1 variable -> 1 rounds; 2/ 3 var -> 2 rounds
% (HI round not considered for GoF calculation -> max = 2)
TestVarIds = Config.TestVarIds;
N_Var = min(length(TestVarIds),2);

% Calculate GoFs for every test variable
for idx_Var = 1:N_Var
    ObsValuesAll = [];

    %     if not(isnan(SimOut(1,1,1,idx1)))
    ObsValues = [];
    ObsValuesInclNaN = SimOut(:,:,2,idx_Var);
    O = ObsValuesInclNaN;
    for i = 1:size(ObsValuesInclNaN,1)
        if not(isnan(ObsValuesInclNaN(i,1)))
            ObsValuesAll(end+1:end+size(ObsValuesInclNaN,2)-1,1) = ObsValuesInclNaN(i,2:end);
        end
    end


    ObsValuesAll(isnan(ObsValuesAll)) = [];

    if not(isempty(ObsValuesAll))
        ObsValues(:,2) = ObsValuesAll;
        for idx_SimRound = 1:N_SimRounds

            A = [];
            SimValues = [];

            A = SimOut(:,:,2+idx_SimRound,idx_Var);
            for i = 1:size(A,1)
                if not(isnan(A(i,1)))
                    SimValues(end+1:end+size(A,2)-1,1) = A(i,2:end);
                end
            end
            SimValues(isnan(SimValues)) = [];
            Config = AAOS_ModelEval_CalculateGoF(Config,SimValues,ObsValues);
            ModelEval(row_GoFtotal,...
                [17-idx_SimRound+idx_Var^2,23-idx_SimRound+idx_Var^2,29-idx_SimRound+idx_Var^2]) =...
                Config.SimOutTemp;
        end
    end
    % end
end
ModelEval(row_GoFtotal,2:12) = nan;

% Assign 2 output arrays to model output structure:
ModelOut.ModelEvaluation = ModelEval;
ModelOut.SimulationOutput = SimOut;