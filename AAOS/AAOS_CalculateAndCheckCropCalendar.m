%% REVISE: split up in several functions to isolate CheckPhenologyConstraints.m
%% Calculates missing phenology-relevant parameters, while checking the AquaCrop
% constraints for crop calendar simulation:
function [Config, breakloop] = ...
    AAOS_CalculateAndCheckCropCalendar(Config,TestCrop,GDDcumsum,...
    ParameterNames,ParameterNamesGDD,ParameterNamesCD,breakloop)

global AOS_InitialiseStruct

% Get values for all crop parameters from AOS array:
AllCropValues = AOS_InitialiseStruct.Parameter.Crop.(string(AOS_InitialiseStruct.CropChoices));
% Get user-available parameter values in required AOS unit:
TestCropValues = TestCrop.Output;
TestInputNames = fieldnames(TestCrop.InputValues);
% Get AOS output unit:
PhenoUnitAOS = Config.PhenoUnitAOS;

% Set up struct's for both parameters and variables, so that elements within
% the equations below can be accessed via the respective parameter/ variable
% name and thus may be easier to comprehend;
% Parameters = adjusted by the user/ receive values either through 'Crop.txt'
% or AAOS parameter input file; Variables = always computed through AOS
% simulation run:

% Set up variables:
Vars = struct;
VariableNames = ["CanopyDevEnd","Canopy10Pct","HIend","CropType","MaxCanopy"];
Vars.CC0 = AllCropValues.CC0;
for idx_variables = 1:size(VariableNames,2)
    VarName = VariableNames(idx_variables);
    Vars.(VarName) = AllCropValues.(VarName);
end
Vars.MaxCanopyCD = AllCropValues.MaxCanopyCD;

% Set up parameter structure:
Pars = struct;

%% Determine which parameters are adjusted by the user (via AAOS/ parameter
% input file), and which remain fix (receive values from AOS/ 'Crop.txt'):
Loc_AllParameters = 1:size(ParameterNames,1);
SimCropNames = string(fieldnames(TestCropValues));
[~,Loc_ParametersInTest] = ismember(ParameterNames,SimCropNames);
Loc_TestedParameters = Loc_AllParameters(Loc_ParametersInTest>0);
Loc_ComputedParameters = Loc_AllParameters(Loc_ParametersInTest==0);
% % If 'Crop.txt' phenology unit is given in calendar days (CD), adjust
% % parameter values such that fix parameters get correct (= CD) values from
% % from the AOS array:
% if PhenoUnitAOS == "CD"
%     ParameterNames(1:5) = append(ParameterNames(1:5),PhenoUnitAOS);
%     ParameterNames(8:9) = append(ParameterNames(8:9),"_",PhenoUnitAOS);
% end



for idx_Tested = 1:size(Loc_TestedParameters,2)
    NameTested = string(ParameterNames(Loc_TestedParameters(idx_Tested)));
    Pars.(NameTested) = TestCropValues.(NameTested);
end
for idx_Computed = 1:size(Loc_ComputedParameters,2)
    NameComputed = string(ParameterNames(Loc_ComputedParameters(idx_Computed)));
    Pars.(NameComputed) = AllCropValues.(NameComputed);
end

if AllCropValues.Determinant == 1
    Vars.CanopyDevEnd = round(Pars.HIstart+(Pars.Flowering/2));
else
    Vars.CanopyDevEnd = Pars.Senescence;
end

Vars.CC0 = round(10000*...
    (Pars.PlantPop*Pars.SeedSize)*10^-8)/10000;

% Calculate CGC/CD-dependent values - only available in one unit until now
% -> calculate based on available unit:


%% ADJUST: PROVIDE BOTH CDC/ CDC UNIT INPUT OPTIONS (GDD/ CD)...
% to date only works if CDC/ CGC are given in GDD:


% Time from sowing to maximum canopy cover (non-stressed conditions)
Vars.MaxCanopy = round(Pars.Emergence+(log((0.25*Pars.CCx*Pars.CCx/Vars.CC0)/...
    (Pars.CCx-(0.98*Pars.CCx)))/Pars.CGC));
Vars.MaxCanopyCD...
    = find(GDDcumsum > Vars.MaxCanopy,1,'first');

%% SHIFT TO AFTER PHENOLOGY CHECK - REPLACE YLDFORM WITH EQUATION IN CHECK:
% Time from sowing to end of yield formation
Pars.YldFormCD = Pars.MaturityCD - Pars.HIstartCD-3; % Source: AFAO (YldForm = conservative)
Pars.YldForm = GDDcumsum(Pars.YldFormCD);
Vars.HIend = Pars.HIstart+Pars.YldForm;
Vars.HIendCD...
    = find(GDDcumsum > Vars.HIend,1,'first');



% Time from sowing to end of flowering (if fruit/grain crop)
if Vars.CropType == 3
    Vars.FloweringEnd = Pars.HIstart+Pars.Flowering;
    Vars.FloweringEndCD...
        = find(GDDcumsum > Vars.FloweringEnd,1,'first');
end


%% Check if CGC and CDC values are given in the correct unit (= the unit to
% be printed in 'Crop.txt'):
% Check if CGC and CDC values are given at all (in AAOS input file):
[~,Loc_CGC_CDC_InTest] = ismember(["CGC","CDC"],TestInputNames);
for idx = 1:size(Loc_CGC_CDC_InTest,2)
    if Loc_CGC_CDC_InTest(idx) == 0
        Unit_CGC_CDC(idx) = "NA";
    else
        Unit_CGC_CDC(idx) = string(TestCrop.InputUnits(Loc_CGC_CDC_InTest(idx)));
    end
end

% If given unit is different than the demanded one, calculate both units:
% parameters in the demanded one:
if Unit_CGC_CDC(1) ~= PhenoUnitAOS

    % Convert CGC
    switch Unit_CGC_CDC(1)
        case {"GDD","NA"} % if CGC given in GDD or not available...
            CAL_CGC = "_CD";
            CAL = "CD"; % -> CGC_CD will be calculated based on pheno pars in CD.
        case "CD" % if CGC given in CD
            CAL_CGC = "";
            CAL = "";
            Pars.CGC_CD = Pars.CGC; % -> ... based on pheno pars in GDD.
    end

    Pars.("CGC"+(CAL_CGC)) = (log((((0.98*Pars.CCx)-Pars.CCx)*Vars.CC0)/(-0.25*(Pars.CCx^2))))/...
        (-(Vars.("MaxCanopy"+(CAL))-Pars.("Emergence"+(CAL))));

end

if Unit_CGC_CDC(2) ~= PhenoUnitAOS
    CAL1 = "";
    CAL2 = "";
    CAL1_CDC = "";
    CAL2_CDC = "";
    switch Unit_CGC_CDC(1)
        case "CD" % if CDC given in CD
            Pars.CDC_CD = Pars.CDC;
            CAL1 = "CD"; % -> CGC will be calculated based on pheno pars in GDD.
            CAL1_CDC = "_CD";
            Unit_CDC_Num = 1; % -> for calculation of t2 (below)
        case {"GDD","NA"} % if CDC given in GDD or not available..
            CAL2 = "CD";     % -> ... based on pheno pars in CD.
            CAL2_CDC = "_CD";
            Unit_CDC_Num = 2; % -> for calculation of t2 (below)
    end

    t1 = Pars.("Maturity"+(CAL1))-Pars.("Senescence"+(CAL1));
    if t1 <= 0
        t1 = (Unit_CDC_Num-1) * 4 - 1; % -> fulfill conditions: tCD >= 1; tGDD >= 5
    end

    CCi = Pars.CCx*(1-0.05*(exp((Pars.("CDC"+(CAL1_CDC))/Pars.CCx)*t1)-1));
    if CCi < 0
        CCi = 0;
    end
    t2 = Pars.("Maturity"+(CAL2))-Pars.("Senescence"+(CAL2));
    if t2 <= 0
        t2 = (Unit_CDC_Num-1) * 4 - 1; % -> fulfill conditions: tCD >= 1; tGDD >= 5
    end

    Pars.("CDC"+(CAL2_CDC)) = (Pars.CCx/t2)*log(1+((1-CCi/Pars.CCx)/0.05));

    %% USELESS(?):
    %         if isempty(Pars.("CDC"+(CAL2_CDC)))
    %             Pars.("CDC"+(CAL2_CDC)) = -999;
    %         end
end
%% USELESS(?):
% phenoparall = vertcat(ParameterNames,VariableNames);
% for idx = 1:size(phenoparall,2)
%     if not(ismember(phenoparall(idx),["CCx","SeedSize"]))
%         if ismember(phenoparall(idx),["CGC","CDC"])
%             if ismember(phenoparall(idx),"CGC") & isempty(Pars.("CGC"+(CAL_CGC)))
%                 Pars.("CGC"+(CAL_CGC)) = -999;
%             elseif ismember(phenoparall(idx),"CDC") & isempty(Pars.("CDC"+(CAL2_CDC)))
%                 Pars.("CDC"+(CAL2_CDC)) = -999;
%             end
%         else
%             phenoparall_val = Pars.(phenoparall(idx)+"CD");
%             if isempty(phenoparall_val)
%                 Pars.(phenoparall(idx)+"CD") = -999;
%             end
%         end
%     end
% end




OutputParNames = string(fieldnames(Pars));
AllSimNames = Config.AllParameterNames;
ParsNum = cell2mat(struct2cell(Pars));
if PhenoUnitAOS == "CD"
    [~,Loc_CDinOutput] = ismember(ParameterNamesCD,OutputParNames);
    [~,Loc_GDDinOutput] = ismember(ParameterNamesGDD,OutputParNames);
    ParsNum(Loc_GDDinOutput) = ParsNum(Loc_CDinOutput);
end

[~,Loc_TestinOutput] = ismember(AllSimNames,OutputParNames);
[~,Loc_OutputInTest] = ismember(OutputParNames,AllSimNames);
TestInOutput = Loc_TestinOutput(Loc_TestinOutput>0);
Loc_AllOut = 1:size(Loc_TestinOutput,1);
%     Loc_AllOut = 1:size(Loc_OutputInTest,1);
%% -> Error if "row gaps" (parameters tested in 2nd round) in test
% parameter list in InputPars spreadsheet; e.g. ksat tested in 1st round.
OutputInTest = Loc_AllOut(Loc_TestinOutput>0)';
% Loc_TestinOutput(Loc_TestinOutput == 0) = [];

Config.AllParameterValues(OutputInTest) = ParsNum(TestInOutput);
%% Insert calculated YldForm value into the array to be printed to Crop.txt:
% NewRow_TestSim = size(Config.TestParameterIdx,2);
NewRow_AllSim = size(AllSimNames,1);
% Create struct field for YldForm in 1. round:
if ~strcmp(Config.AllParameterNames,"YldForm")
    %     NewRow_TestSim = NewRow_TestSim + 1;
    NewRow_AllSim = NewRow_AllSim + 1;
end
Config.AllParameterNames(NewRow_AllSim) = cellstr("YldForm");
% Config.TestParameterIdx(NewRow_TestSim) = NewRow_AllSim;
Config.AllParameterLowLim(NewRow_AllSim) = Pars.("YldForm"+PhenoUnitAOS);
Config.AllParameterUppLim(NewRow_AllSim) = Pars.("YldForm"+PhenoUnitAOS);
Config.AllParameterAOSfile(NewRow_AllSim) = cellstr("Crop");
Config.AllParameterDecimals(NewRow_AllSim) = 0;
Config.AllParameterUnits(NewRow_AllSim) = cellstr(PhenoUnitAOS);
Config.AllParameterValues(NewRow_AllSim) = Pars.("YldForm"+PhenoUnitAOS);



% Time from sowing to 10% canopy cover (non-stressed conditions)
Vars.Canopy10PctCD = round(Pars.EmergenceCD+(log(0.1/Vars.CC0)/Pars.CGC_CD));
if Vars.Canopy10PctCD > 0
    Vars.Canopy10Pct = GDDcumsum(Vars.Canopy10PctCD);
else
    Vars.Canopy10Pct = 0;
end
% Get all possibly conflicting parameters/ variables in GDD
ConflictNames = ["Emergence","Senescence","Maturity","HIstart",...
    "Flowering","HIstartCD","YldFormCD","MaxCanopy","Canopy10Pct"];
for idx_Conflict1 = 1:7
    ConflictName = ConflictNames(idx_Conflict1);
    ConflictVars.(ConflictName) = Pars.(ConflictName);
end
for idx_Conflict2 = 8:size(ConflictNames,2)
    ConflictName = ConflictNames(idx_Conflict2);
    ConflictVars.(ConflictName) = Vars.(ConflictName);
end

breakloop = AAOS_CheckPhenologyConstraints...
    (Config,ConflictVars,GDDcumsum,breakloop);