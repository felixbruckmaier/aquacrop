%% Read & store AOS-simulated target & test variable (at harvest day/ timeseries):
function [Config,ModelOut] = AAOS_ReadAOSsimulationOutput(Config,ObsTestVar)

global AOS_InitialiseStruct

% Set target variable value to nan
SimTargetVarHarvest = nan;

% Get AOS crop growth file that has been simulated for the current run: 
CropGrowth = AOS_InitialiseStruct.Outputs.CropGrowth;

% For graphical output/ plot size: Get date of full crop maturity/ harvest:
% Config.Maturity = max(CropGrowth(:,4));

% Read simulated yield and biomass at day of harvest and round to [t/ha]: 
SimY_Harvest = CropGrowth(find(CropGrowth(:,15)>-999, 1 , 'last'),15);
SimBM_Harvest = CropGrowth(find(CropGrowth(:,15)>-999, 1 , 'last'),11);
if not(isnan(SimBM_Harvest))
    SimBM_Harvest = round(SimBM_Harvest/100,2);
end
if not(isnan(SimY_Harvest))
    SimY_Harvest = round(SimY_Harvest,2);
end

% if Config.RUN_type == "STQ"
%     Config.TargetBMSim = SimHarvestBM;
%     Config.TargetYSim = SimHarvestY;
% else

    % Assign & store simulated value of respective target variable:
    if not(isnan(Config.TargetVar.Observations(Config.LotName,2)))
        if Config.TargetVar.NameFull == "Yield"
            SimTargetVarHarvest = SimY_Harvest;
        elseif Config.TargetVar.NameFull == "Biomass"
            SimTargetVarHarvest = SimBM_Harvest;
        end
    end
    Config.SimTargetVariable = SimTargetVarHarvest;

% Assign & store simulated timeseries of test variable, unless that is "HI":
    if Config.TestVarNameFull ~= "HarvestIndex"
        if Config.TestVarNameFull == "CanopyCover"
            SimTestVar = CropGrowth([ObsTestVar(:,1)],9);
        elseif Config.TestVarNameFull ==  "SoilWaterContent"
            SimSWC = readtable(Config.season+"_WaterContents.txt","ReadVariableNames",false);
            SimTestVar = table2array(SimSWC([ObsTestVar(:,1)],5+Config.AvailSWCObsDepths(Config.TestSWCidx)));

        end
        ModelOut = SimTestVar;
        Config.SimulatedTestVariable = SimTestVar;
    end

%     if Config.RUN_type == "GSA"
%         Config.GDDsum = cumsum(CropGrowth(1:CropGrowth(find(CropGrowth(:,6)>-999, 1 , 'last'),6)));
%         ModelOut(end+1) = SimTargetVarHarvest;
%     end
% end