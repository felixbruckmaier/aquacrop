function [Config, breakloop] = AAOS_ConvertandCheckParameters(Config,AAOS_PhenoConflictsCropSpecif)


breakloop = 0;

% Convert SimPeriod parameters to serial format:
ParNames = Config.AllParameterNames;
ParValues = Config.AllParameterValues;

SHP_Values = AAOS_UpdateSoilHydrologyParameters(ParNames, ParValues);
breakloop = AAOS_CheckSoilHydrologyConstraints(SHP_Values);



%% NOT WORKING:
% % Adjust simulation period, if test values require it:
% [SimPeriodVals,SimPeriodValsDef,~] = AAOS_ConvertSimPeriodParameters(Config,ParNames,ParValues);
%
% if any(SimPeriodVals > SimPeriodValsDef)
%     % Write adjusted sim period days to all related AOS input files:
%     VarValues = AAOS_ConvertSimPeriodParameters(Config,ParNames,SimPeriodVals);
%     VarNames = ["PlantingDate","HarvestDate"];
%     FileType = "SimPeriod";
%     AAOS_WriteAOSinputFiles(Directory,Config,VarNames,VarValues,FileType)
%     % Assign the SimPeriod currently stored in the AOS input .txt
%     % files to the default SimPeriod array:
%     Config.SimPeriodValsDef = VarValues;
%     % Store adjusted simulation period, and weather inputs, to be
%     % able to retrieve the updated GDD's in the subsequent step:
%     cd(Directory.AOS);
%     AOS_Initialize();
%     cd(Directory.BASE_PATH)
% end


% Set up parameters relevant for phenology check:
ParameterNames1 = ["Maturity", "Emergence", "Senescence", "HIstart","Flowering","YldForm"];
ParameterNames2 = ["CDC", "CGC"];
ParameterNames3 = ["PlantPop","SeedSize", "CCx"];
ParameterNames4 = append(ParameterNames1,"CD");
ParameterNames5 = append(ParameterNames2,"_CD");
ParameterNames = horzcat(ParameterNames1,ParameterNames2,ParameterNames3,...
    ParameterNames4,ParameterNames5)';

% Check if any tested parameters is a phenology-relevant parameters
str_ParNames = string(ParNames);
if any(ismember(str_ParNames(:),ParameterNames(:)))



    % Store cumulated sum of GDD's within simulation period
    GDDcumsum = AAOS_ComputeGDD;



    % Calculate for all tested phenology parameters (except CGC + CDC)
    % the values for both calendar type units, CD and GDD:
    CropParameters = Config.CropParameters;
    [CD_Values,GDD_Values] =...
        AAOS_ComputePhenologyUnits(GDDcumsum,CropParameters);

    % Update all phenology parameters in the test parameter array with
    % the correct unit (according to 'Crop.txt'):
    % AllNames = Config.AllParameterNames;
    % AllValues = Config.AllParameterValues;
    CropParameters.InputValues = Config.CropParameters.InputValues;

    [CropParameters,AllValues,Config.PhenoUnitAOS] =...
        AAOS_HomogenizePhenologyUnits(...
        CD_Values,GDD_Values,ParNames,ParValues,CropParameters);

    Config.AllParameterValues = AllValues;

    % Check if there is any conflict regarding the user-defined phenology values:
    ParameterNamesGDD = horzcat(ParameterNames1,ParameterNames2);
    ParameterNamesCD = horzcat(ParameterNames4,ParameterNames5);

    [Config, breakloop] = ...
        AAOS_CalculateAndCheckCropCalendar(Config,CropParameters,GDDcumsum,...
        ParameterNames,ParameterNamesGDD,ParameterNamesCD,breakloop);
end
