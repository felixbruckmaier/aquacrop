%% Determines directories and loads config & input data
function [Directory,Config,AnalysisOut] = AAOS_Initialize()

% Define AOS variable
global AOS_ClockStruct % global variable required to comply with AOS config

fclose ('all'); % Close open files

% Determine directories automatically from the current .m file's location:
Directory.BASE_PATH = string(fileparts(mfilename('fullpath')));
cd(Directory.BASE_PATH);
Config = AAOS_LoadConfig();
Directory.AAOS_Input = Directory.BASE_PATH + filesep + "AAOS_Input" + filesep + Config.season;
Directory.AAOS_Output = Directory.BASE_PATH + filesep + "AAOS_Output" + filesep + Config.season;
DirOutput = Directory.AAOS_Output;
if ~exist(DirOutput, 'dir')
    mkdir(DirOutput)
end
Directory.vendor = Directory.BASE_PATH + filesep + "vendor";
Directory.AOS = Directory.vendor + filesep + "AOS";
Directory.AOS_Input = Directory.AOS + filesep + "Input";
Directory.AOS_InputSeason = Directory.AOS + filesep + "Input" + filesep + Config.season;
Directory.AOS_Output = Directory.AOS + filesep + "Output";
Directory.AOS_OutputSeason = Directory.AOS + filesep + "Output" + filesep + Config.season;
Directory.SAFE = Directory.BASE_PATH + filesep + "vendor" + filesep + "safe_R1.1";
Directory.SAFE_Sampling = Directory.SAFE + filesep + "sampling";
Directory.SAFE_util = Directory.SAFE + filesep + "util";
Directory.SAFE_Morris = Directory.SAFE + filesep + "EET";
Directory.SAFE_GLUE = Directory.SAFE + filesep + "GLUE";
Directory.SAFE_Plotting = Directory.SAFE + filesep + "visualization";

% Rearrange/ label defined number of files for user observation input (to
% easify later utilization):
N_FilesObsInput = Config.N_FilesObsInput;
Config = rmfield(Config, "N_FilesObsInput");
Config.N_FilesObsInput.Irrigation = N_FilesObsInput(1);
if ~isempty(Config.TestVarIds)
    for idx1 = 2:size(N_FilesObsInput,2)
        idx_var = Config.TestVarIds(idx1-1);
        [~,TestVarNameShort] = AAOS_SwitchTestVariable(idx_var);
        Config.N_FilesObsInput.(TestVarNameShort) = N_FilesObsInput(idx1);
    end
end

% Adjust AOS in- and output directories defined in FileLocations.txt file:
directories = ["Input";"Output"];
for idx2 = 1:2
    directory = directories(idx2);
    Filename = "FileLocations";
    VarName = idx2;
    VarValue = Directory.("AOS_" + directory + "Season");
    AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
        Filename,VarName,VarValue);
end

% Initialize AOS arrays:
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)

% Determine cumulated sum of Growing Degree Days for the default growing season
% weather data:
Config.GDDcumsum = AAOS_ComputeGDD;

% Determine default simulation period extension (invert sign of Planting Date
% to simplify the later comparison with the AAOS user input value):
SimPeriodDef(1) = -(AOS_ClockStruct.PlantingDate);
SimPeriodDef(2) = AOS_ClockStruct.HarvestDate;
SimPeriodDef(3) = SimPeriodDef(2) + SimPeriodDef(1);
Config.SimPeriodValsDef = SimPeriodDef;

% If there is a custom config, loop over its properties & update the default
% config:
if nargin >= 1
    fn = fieldnames(config_custom);
    for k=1:numel(fn)
        Config.(fn{k}) = config_custom.(fn{k});
    end
end

fprintf(1,"... initializing analysis '%s'...\n",...
    string(Config.RUN_type));

% Read user-specified target variable name and observations:
Config.TargetVar = AAOS_ReadTargetVariableConfig(Config,Directory);

if ismember(Config.RUN_type,["DEF","CAL"])
    % Define arrays for output files and fill in lot-unspecific data:
    AnalysisOut = AAOS_ModelEval_StoreTestLotsAndObservations(Config);
else
    AnalysisOut.TargetVar = Config.TargetVar;

    % Merge time-series charts (i.e., scatter, stock, heat map):
    Config.GLUE_ChartNames = struct;
    Config.GLUE_ChartNames.Boxcharts = ["BC_Combi","BC_Lots"];
    Config.GLUE_ChartNames.Heatmaps = ["HM_All","HM_Lots"];
    Config.GLUE_ChartNames.NonTimeSeriesCharts =...
        ["CDF","Q",Config.GLUE_ChartNames.Boxcharts,Config.GLUE_ChartNames.Heatmaps];

end

% Get default harvest day for every simulation lot ('Maturity' from AOS
% 'Crop.txt' file) -> will be used for graphical plotting unless 'Maturity'
% is being changed throughout GLUE (see AAOS 'InputPars_GLUE.csv' file)
Config.TargetVar.HarvestDay =...
AOS_ClockStruct.HarvestDate - AOS_ClockStruct.PlantingDate;

% Read user-defined parameter values:
Config = AAOS_ReadParameterInputFiles(Config,Directory);

% For every input file, substitute missing parameter values with the mean
% of all valid values:
cd(Directory.BASE_PATH)
for FileIdx = 1:numel(fieldnames(Config.ParameterValues))
    Config = AAOS_SubstituteMissingParameters(FileIdx,Config);
end