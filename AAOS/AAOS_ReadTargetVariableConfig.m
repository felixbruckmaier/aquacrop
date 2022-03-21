%% Reads user-specified target variable name and all available observations
% from .csv input files. Available: Biomass and Yield.
% Number of lots with available target variable observations = number of lots
% that are included in the analysis.
function TargetVar = AAOS_ReadTargetVariableConfig(Config,Directory)

% Find the file in the correct directory:
cd(Directory.AAOS_Input);
TargetVarObs_file = dir(fullfile(Directory.AAOS_Input,...
    'Obs_'+Config.season+'_TargetVar_all.csv'));

% Store file content:
TargetVarObs_filename = TargetVarObs_file(1).name;
TargetVarObs_data = readtable(TargetVarObs_filename,'ReadVariableNames',true);
TargetVar.NameFull = string(TargetVarObs_data.Properties.VariableNames(1));
TargetVar.Observations = table2array(TargetVarObs_data(1:end,3:5));
TargetVar.MaxValue = max(max(TargetVar.Observations(1:end,3:end)));

% Determine and store abbreviated variable name:
if TargetVar.NameFull == "Biomass"
    TargetVar.NameAbbr = "BM";
elseif TargetVar.NameFull == "Yield"
    TargetVar.NameAbbr = "Y";
else
    TargetVar.NameAbbr = "";
end


