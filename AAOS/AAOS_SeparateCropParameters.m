% Stores values and units for all tested crop parameters defined in
% either GDD or CD to homogenize their unit before writing AOS input files:
function Config = AAOS_SeparateCropParameters(Config)

CropParameterNames = {'Maturity';'PlantingDate';'HarvestDate';'Emergence';...
    'Senescence';'HIstart';'Flowering';'YldForm';'SeedSize';'PlantPop';...
    'CCx';'CDC';'CGC';'MaxRooting'};
[~,Loc_TestInCrop] = ismember(CropParameterNames,Config.AllParameterNames);
Loc_AllCrop = 1:size(Loc_TestInCrop,1);
Loc_CropinTest = Loc_AllCrop(Loc_TestInCrop ~= 0);
Loc_TestInCrop(Loc_TestInCrop == 0) = [];
% Loc_TestInCrop(Loc_TestInCrop == 0) = [];
% [~,LocY_Pheno] = ismember(Config.AllParameterNames,CropParameterNames);
% [~,sortIdx] = sort(LocY_Pheno,'ascend');
% CropNames = Config.AllParameterNames(sortIdx);

% Create struct with parameter names as field names to enhance
% understanding of 'AAOS_CheckPhenology.m':
CropNames = CropParameterNames(Loc_CropinTest);
CropParameters.InputValues = struct;
Config.CropParameters.InputUnits = cell(size(CropNames,2));
for idx = 1:size(CropNames,1)
    CropParameters.InputValues.(string(CropNames(idx))) = Config.AllParameterValues(Loc_TestInCrop(idx));
end
Config.CropParameters.InputValues = CropParameters.InputValues;
% Store units as given by the user through AAOS parameter input file:
CropParameters.InputUnits =  Config.AllParameterUnits(Loc_TestInCrop);
Config.CropParameters.InputUnits = CropParameters.InputUnits;