%% Homogenize all tested phenology parameter values according to the unit
% that is defined in AOS input data (Crop.txt), and which determines all
% parameters not adjusted through AAOS.
function [CropParameters,TestValues,PhenoUnitAOS] =...
    AAOS_HomogenizePhenologyUnits(CD_Values,GDD_Values,TestNames,TestValues,CropParameters)

global AOS_InitialiseStruct

% Get available 
cond_GDD = ~isnan(GDD_Values);
cond_CD = ~isnan(CD_Values);
cond_Pheno = or(cond_GDD,cond_CD);

% Since the unit-defining parameter from this file ('CalendarType') changes
% through the AOS initialization in case 'SwitchGDD' is activated, this
% function checks the parameter 'Canopy10PctCD', which AOS only creates if
% the original 'CalendarType' was set to '1' (= CD) in 'Crop.txt':
CropName = string(AOS_InitialiseStruct.CropChoices);
try AOS_InitialiseStruct.Parameter.Crop.(CropName).Canopy10PctCD
    % Calendar Days (CD)
    PhenoUnitAOS = "CD";
catch % Growing Degree Days (GDD)
    PhenoUnitAOS = "";
end

% Get location of adjusted phenology parameters within array that contains
% all tested parameters:
CropNames = string(fieldnames(CropParameters.InputValues));
[~,Loc_TestInCrop] = ismember(TestNames,CropNames);
[~,Loc_CropInTest] = ismember(CropNames,TestNames);
Loc_All = 1:size(Loc_TestInCrop,1);

% Loc_CD_InCrop = Loc_All(cond_CD); % parameters given in CD format
% Loc_GDD_InCrop = Loc_All(cond_GDD); % parameters given in GDD format
Loc_PhenoInCrop = Loc_All(cond_Pheno); % parameters given in either format

% Update all phenology parameter values within the test parameter array:
TestCropInputValues = cell2mat(struct2cell(CropParameters.InputValues));
Loc_PhenoInTest = Loc_CropInTest(Loc_PhenoInCrop);
TestValues(Loc_PhenoInTest) = TestCropInputValues(Loc_PhenoInCrop);
PhenoNames = CropNames(Loc_PhenoInCrop);

% Fill CD and GDD structures with respectively available values:
for idx = 1:size(PhenoNames,1)
    if ismember(PhenoNames(idx),["CGC","CDC"])
        CD_Name = append(PhenoNames(idx),"_CD");
    else
        CD_Name = append(PhenoNames(idx),"CD");
    end
    CD_Value = CD_Values(Loc_PhenoInCrop(idx));
    if ~isnan(CD_Value)
        CropParameters.Output.(CD_Name) = CD_Value;
    end

    GDD_Value = GDD_Values(Loc_PhenoInCrop(idx));
    if ~isnan(GDD_Value)
        CropParameters.Output.(PhenoNames(idx)) = GDD_Value;
    end
end