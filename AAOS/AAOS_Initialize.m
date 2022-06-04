%% Determines directories and loads config & input data
function [Directory,Config,AnalysisOut] = AAOS_Initialize()

% AOS variable
global AOS_ClockStruct

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


% Adjust AOS in- and output directories defined in FileLocations.txt file:
directories = ["Input";"Output"];
for idx = 1:2
    directory = directories(idx);
    Filename = "FileLocations";
    % OmitTemplate = 0;
    VarName = idx;
    VarValue = Directory.("AOS_" + directory + "Season");
    AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
        Filename,VarName,VarValue);
end

% Initialize AOS arrays:
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)

% % Determine default GDD cumulated sum:
% Config.GDDcumsum = AAOS_ComputeGDD;

% Determine default simulation period extension (invert sign of Planting Date
% to simplify the later comparison with the AAOS user input value):
SimPeriodValsDef(1) = -(AOS_ClockStruct.PlantingDate);
SimPeriodValsDef(2) = AOS_ClockStruct.HarvestDate;
SimPeriodValsDef(3) = SimPeriodValsDef(2) + SimPeriodValsDef(1);
Config.SimPeriodValsDef = SimPeriodValsDef;

% If there is a custom config, loop over its properties & update the default
% config:
if nargin >= 1
    fn = fieldnames(config_custom);
    for k=1:numel(fn)
        Config.(fn{k}) = config_custom.(fn{k});
    end
end

% Read user-specified target variable name and observations:
Config.TargetVar = AAOS_ReadTargetVariableConfig(Config,Directory);

% % Read lots to be included in the simulation:
% Config = AAOS_DetermineSimulationLots(Config);

if ismember(Config.RUN_type,["DEF","CAL"])
    % Define arrays for output files and fill in lot-unspecific data:
    AnalysisOut = AAOS_ModelEval_StoreTestLotsAndObservations(Config);
else
    AnalysisOut.TargetVar = Config.TargetVar;
end

% Get harvest day for every simulation lot:
Config.TargetVar.HarvestDay(1:size(Config.SimulationLots,2),1) =...
    Config.TargetVar.Observations(Config.SimulationLots,2);

% Read user-defined parameter values:
Config = AAOS_ReadParameterInputFiles(Config,Directory);

% For every input file, substitute missing parameter values with the mean
% of all valid values:
cd(Directory.BASE_PATH)
for FileIdx = 1:numel(fieldnames(Config.ParameterValues))
    Config = AAOS_SubstituteMissingParameters(FileIdx,Config);
end