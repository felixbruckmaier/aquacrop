% Collect all relevant simulation output data in an array to later plot
% everything together;
% Variable availability is checked before in main loop -> in here only
% available variables enter;

% Setup (columns):

% (1) Plot Label
% (2-6) Final Variable (deviation [%]): Recalculation CC / Calibration SWC /
% Recalc SWC / Calibration CC / Default Simulation
% (7-12) Final Variable (absolute values): Observation / Recalc. CC / Calibr. SWC /
% Recalc SWC / Calibrvar_obs. CC / Def.
% (13-18,19-24,25-30)) GoF#1-#3: Recalc. CC / Calibr. CC / Def. CC / Calibr. SWC / Recalc SWC / Def. SWC

% ORIGINAL:
% (2-5) Final Variable (deviation [%]): Recalculation CC / Calibration SWC /
% Calibration CC / Default Simulation
% (6-10) Final Variable (absolute values): Observation / Recalc. CC / Calibr. SWC /
% Calibr. CC / Def.
% (11-15,16-20,21-25))
% Recalc. CC / Calibr. CC / Def. CC / Calibr. SWC / Def. SWC

function [ModelEval,SimOut] = AAOS_StoreSimulationsAndGoF...
    (Config,ModelEval,SimOut,SimRound,SimTestVar,ObsTestVar)


switch SimRound
    case 1 % Default Simulation


        switch Config.TestVarNameFull
            case "CanopyCover"
                col_ModelEval = [7,14,17];
                var_SimOut = 1;
            case "SoilWaterContent"
                col_ModelEval = [0,0,20];
                var_SimOut = 2;
                if isnan(SimOut(Config.PlotIdx,2,3,1)) % If missing 1. SimDay of CC Def Simulation -> No CC obs available at this plot -> Obs & Plot Labels must be assigned during SWC run
                    col_ModelEval = [7,14,20];

                end
        end
    case 2

        switch Config.TestVarNameFull
            case "CanopyCover"
                var_SimOut = 1;
                col_ModelEval = [6,13,16]; % calibration
            case "SoilWaterContent"
                var_SimOut = 2;
                col_ModelEval = [5,12,19]; % recalculation
        end
    case 3 % Recalculation of CC with calibrated CC & SWC parameter values
        switch Config.TestVarNameFull
            case "CanopyCover"
                var_SimOut = 1;
                col_ModelEval = [3,10,15]; % recalculation
            case "SoilWaterContent"
                var_SimOut = 2;
                col_ModelEval = [4,11,18]; % calibration
            case "HarvestIndex"
                col_ModelEval = [2,9]; % calibration
        end
end

if Config.TestVarNameFull ~= "HarvestIndex" % For CC & SWC: Store simulated variable values
    if SimRound == 1
        SimOut(Config.LotIdx,1,[1 2 3 4 5],var_SimOut)...
            = Config.LotName; % Plot labels
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


if not(SimRound==1 & Config.TestVarNameFull == "SoilWaterContent") |... % Default Run: FinalVar equal for both TestVars
        (SimRound==1 && ismissing(SimOut(Config.LotIdx,2,3,1))) % If missing 1. SimDay of CC Def Simulation (see above)
    ModelEval(Config.LotIdx,col_ModelEval(2)) = round(Config.SimTargetVariable,2); % Final Target Var. Absolute
    if not(isempty(ModelEval(Config.LotIdx,8)))
        ModelEval(Config.LotIdx,col_ModelEval(1)) = round(...
            100 * (ModelEval(Config.LotIdx,8) - Config.SimTargetVariable)/...
            ModelEval(Config.LotIdx,8),2); % Final Var. Deviation [%]
    end
end

