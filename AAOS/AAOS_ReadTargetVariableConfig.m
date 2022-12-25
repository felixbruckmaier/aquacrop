%% Reads user-specified target variable name and all available observations
% from .csv input files. Available: Biomass and Yield.
% Number of lots with available target variable observations = number of lots
% that will be included in the analysis.
function TargetVar = AAOS_ReadTargetVariableConfig(Config,Directory)

% Find the file in the correct directory:
cd(Directory.AAOS_Input);
TargetVarObs_file = dir(fullfile(Directory.AAOS_Input,...
    'Obs_TargetVar.csv'));

% Store file content:
TargetVarObs_filename = TargetVarObs_file(1).name;
TargetVarObs_data = readtable(TargetVarObs_filename,'ReadVariableNames',true);

TargetVar.NameFull = string(TargetVarObs_data.Properties.VariableNames(2));

TargetVarObs_data = renamevars(TargetVarObs_data,TargetVar.NameFull,'Observation');
TargetVar.Observations = table2array(TargetVarObs_data(1:end,1:2));
TargetVar.MaxValue = max(max(TargetVar.Observations(1:end,2)));

% Determine and store Shorteviated variable name:
if TargetVar.NameFull == "Biomass"
    TargetVar.NameShort = "BM";
elseif TargetVar.NameFull == "Yield"
    TargetVar.NameShort = "Y";
else
    TargetVar.NameShort = "";
end

cd(Directory.BASE_PATH);
