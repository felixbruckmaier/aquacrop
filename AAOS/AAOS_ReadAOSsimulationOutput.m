%% ADJUST: too complicated for current purpose
%% Read & store AOS-simulated target & test variable (at harvest day/ timeseries):
function [Config] = ...
    AAOS_ReadAOSsimulationOutput(Config,VarNamesShort,ObsTestVar)

global AOS_InitialiseStruct


for idx = 1:numel(VarNamesShort)
    VarName = VarNamesShort(idx);

    switch VarName
        case "BM"
            % Set target variable value to nan
            Config.SimTargetVariable = nan;
            % Get AOS crop growth file that has been simulated for the current run:
            CropGrowth = AOS_InitialiseStruct.Outputs.CropGrowth;
            % Read simulated biomass at day of harvest and round to [t/ha]:
            SimBM_Harvest = CropGrowth(find(CropGrowth(:,15)>-999, 1 , 'last'),11);
            if not(isnan(SimBM_Harvest))
                SimBM_Harvest = round(SimBM_Harvest/100,2);
                SimBMPot_Harvest = CropGrowth(find(CropGrowth(:,15)>-999, 1 , 'last'),12);
                SimBMPot_Harvest = round(SimBMPot_Harvest/100,2);
                Config.SimTargetVariable = SimBM_Harvest;
                Config.SimBiomassLoss =...
                    SimBM_Harvest - SimBMPot_Harvest;
            end
        case "Y"
            % Set target variable value to nan
            Config.SimTargetVariable = nan;
            % Get AOS crop growth file that has been simulated for the current run:
            CropGrowth = AOS_InitialiseStruct.Outputs.CropGrowth;
            % Read simulated yield at day of harvest and round to [t/ha]:
            SimY_Harvest = CropGrowth(find(CropGrowth(:,15)>-999, 1 , 'last'),15);
            if not(isnan(SimY_Harvest))
                Config.SimTargetVariable = round(SimY_Harvest,2);
            end

            % Assign & store simulated timeseries of test variable, unless that is "HI":
        case "CC"
            % Get AOS crop growth file that has been simulated for the current run:
            CropGrowth = AOS_InitialiseStruct.Outputs.CropGrowth;
            SimTestVar = CropGrowth([ObsTestVar(:,1)],9);
            Config.SimTestVariable = SimTestVar;
        case "SWC"
            SimSWC = AOS_InitialiseStruct.Outputs.WaterContents;
            SimTestVar = SimSWC([ObsTestVar(:,1)],5+Config.idx_TestSWC);
            Config.SimTestVariable = SimTestVar;
    end
end