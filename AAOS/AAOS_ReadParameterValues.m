%% Determines test parameters & their specifications current simulation round:
function Config = AAOS_ReadParameterValues(Config,VarIdx,SimRound)



ParData = Config.ParameterValues.(Config.ParFileType);
TestRound = table2array(ParData(:,7));
% For calibration - see official AquaCrop calibration guideline:
% SimRound #1: all variables default
% SimRound #2: if only 1 variable -> calibrated;
if numel(Config.TestVarIds) > 1 && ismember(SimRound,[2,3])
    AllRows = 1:size(TestRound,1);
    switch SimRound
        % SimRound #2/ >1 variable -> CC calibrated, SWC (& HI) default:
        case 2

            TestParRows = AllRows(TestRound==2 | TestRound==3);

            % SimRound #3 (only for >1 variable): CC & SWC calibrated (, HI default):
        case 3
            TestParRows = AllRows(TestRound==3);
    end
    ParData(TestParRows,8:end) = Config.ParameterValues.DEF(TestParRows,8:end);
end
% SimRound #4 (only for 3 variables): all variables calibrated = SimRound #1

% all parameters except the ones explicitely excluded
% (= negative index in par input file):
if VarIdx == 0 
    FixParAllLots = TestRound==0;

% only parameters defined for specific round (i.e. either CC- or
% SWC-related):
elseif VarIdx > 0
%     FixParAllLots = ParTestSet~=VarIdx;
AllParIdx = TestRound~=VarIdx;
end


Header = string(ParData.Properties.VariableNames);
AllColumns = 1:size(Header,2);
LotColumn = AllColumns(Header=="Lot"+Config.LotName);

Config.AllParameterNames = table2array(ParData(:,1)); % remove parameter Yld
% formation which was added during the analysis
Config.AllParameterValues = table2array(ParData(:,LotColumn));

% FixParsCurrentLot = table2array(ParData(:,column_lot))<=-999;
% FixParAll = FixParAllLots + FixParsCurrentLot;
AllParIdx(AllParIdx == 2) = 1;
Config.FixvsTestParameter = AllParIdx;

Allidx = 1:size(AllParIdx,1);
% only parameters to be tested on current lot:
Config.TestParameterIdx = Allidx(AllParIdx==0);
Config.TestParameterNames = Config.AllParameterNames(Config.FixvsTestParameter==0);
Config.TestParameterAOSFile = table2array(ParData(AllParIdx==0,2));
Config.TestParameterLowLim = table2array(ParData(AllParIdx==0,4));
Config.TestParameterUppLim = table2array(ParData(AllParIdx==0,5));
Config.AllParameterValues
% CHANGE:
% Config.TestParameterValues = Config.AllParameterValues(Config.TestParameterIdx);
Config.TestParameterUnits = Config.AllParameterUnits(Config.TestParameterIdx);

% Store values and units for all tested phenology parameters defined in
% either GDD or CD to homogenize their unit before writing AOS input files:
CropParameterNames = {'Maturity';'PlantingDate';'HarvestDate';'Emergence';...
    'Senescence';'HIstart';'Flowering';'YldForm';'SeedSize';'PlantPop';...
    'CCx';'CDC';'CGC';'MaxRooting'};
[~,LocY_Pheno] = ismember(Config.AllParameterNames,CropParameterNames);
[~,sortIdx] = sort(LocY_Pheno,'ascend');
% Create struct with parameter names as field names to enhance
% understanding of 'AAOS_CheckPhenology.m':
CropNames = Config.AllParameterNames(sortIdx);
CropParameters.InputValues = struct;
Config.CropParameters.InputUnits = cell(size(CropNames,2));
for idx = 1:size(CropNames,1)
    CropParameters.InputValues.(string(CropNames(idx))) = Config.AllParameterValues(sortIdx(idx));
end
Config.CropParameters.InputValues = CropParameters.InputValues;
% Store units as given by the user through AAOS parameter input file:
CropParameters.InputUnits =  Config.AllParameterUnits(sortIdx);
Config.CropParameters.InputUnits = CropParameters.InputUnits;

