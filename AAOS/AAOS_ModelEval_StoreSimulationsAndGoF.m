%% Collect all relevant simulation output data in an array to later plot
% the outputs altogether;
% Test variable observations availability is checked before -> only available
% variables enter this function.

% Setup (columns):

%% (1) Lot Name (= index from list with all lots)
%% (2-7) Target Variable (deviation from observation [%]):
% Calibr HI / Recalculation CC / Calibration SWC / Recalc SWC /
% Calibration CC / Default Simulation
%% (8-14) Target Variable (absolute values):
% Observation / Calibr HI / % Recalc. CC / Calibr. SWC / Recalc SWC /
% Calibr. CC / Def.
%% (15-20,21-26,27-32)) GoF#1-#3:
% Recalc. CC / Calibr. CC / Def. CC / Calibr. SWC / Recalc SWC / Def. SWC

function [ModelOut] = AAOS_ModelEval_StoreSimulationsAndGoF...
    (Config,ModelOut,SimRound,TestVarNameShort,SimTestVar,ObsTestVar)

ModelEval = ModelOut.ModelEvaluation;
SimOut = ModelOut.SimulationOutput;

switch SimRound
    case 1 % Default Simulation


        switch TestVarNameShort
            case "CC"
                col_ModelEval = [7,14,17];
                var_SimOut = 1;
            case "SWC"
                col_ModelEval = [0,0,20];
                var_SimOut = 2;
                if isnan(SimOut(Config.LotIdx,2,3,1)) % If missing 1. SimDay of CC Def Simulation -> No CC obs available at this lot -> Obs & Lot Labels must be assigned during SWC run
                    col_ModelEval = [7,14,20];

                end
        end
    case 2

        switch TestVarNameShort
            case "CC"
                var_SimOut = 1;
                col_ModelEval = [6,13,16]; % calibration
            case "SWC"
                var_SimOut = 2;
                col_ModelEval = [5,12,19]; % recalculation
        end
    case 3 % Recalculation of CC with calibrated CC & SWC parameter values
        switch TestVarNameShort
            case "CC"
                var_SimOut = 1;
                col_ModelEval = [3,10,15]; % recalculation
            case "SWC"
                var_SimOut = 2;
                col_ModelEval = [4,11,18]; % calibration
        end
    case 4 % Calibration of HI with calibrated CC & SWC parameter values
        col_ModelEval = [2,9]; %
end

if TestVarNameShort ~= "HI" % For CC & SWC: Store simulated variable values
    if SimRound == 1
        SimOut(Config.LotIdx,1,[1 2 3 4 5],var_SimOut)...
            = Config.LotName; % Lot labels
        SimOut(Config.LotIdx,(2:1+size(ObsTestVar,1)),1,var_SimOut)...
            = ObsTestVar(:,1); % Observation Days

        SimOut(Config.LotIdx,(2:1+size(ObsTestVar,1)),2,var_SimOut)...
            = ObsTestVar(:,2); % Observation Values
    end
    SimOut(Config.LotIdx,(2:1+size(SimTestVar,1)),...
        (2+SimRound),var_SimOut)...
        = round(SimTestVar,2); % Simulation Values (Def. / Calibr. / Recalc.)


    % GoFs:
    for idx = 1:length(Config.GoF)
        ModelEval(Config.LotIdx,col_ModelEval(3)+(idx-1)*6)...
            = Config.SimOutTemp(idx);
    end

end

% Default Run needs to be performed only once ->  SimRound 1 / Variable 1
if not(SimRound==1 & TestVarNameShort == "SWC") |...
        (SimRound==1 && ismissing(SimOut(Config.LotIdx,2,3,1))) % If missing 1. SimDay of CC Def Simulation (see above)
    ModelEval(Config.LotIdx,col_ModelEval(2)) = round(Config.SimTargetVariable,2); % Final Target Var. Absolute
    if not(isempty(ModelEval(Config.LotIdx,8)))
        ModelEval(Config.LotIdx,col_ModelEval(1)) = round(...
            100 * (ModelEval(Config.LotIdx,8) - Config.SimTargetVariable)/...
            ModelEval(Config.LotIdx,8),2); % Final Var. Deviation [%]
    end
end

ModelOut.ModelEvaluation = ModelEval;
ModelOut.SimulationOutput = SimOut;
