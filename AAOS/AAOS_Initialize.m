%% Determines directories and loads config & input data
function [Directory, Config] = AAOS_Initialize()

% Determines directories automatically from the location of current .m file:
Directory.BASE_PATH = string(fileparts(mfilename('fullpath')));
cd(Directory.BASE_PATH);
Config = AAOS_LoadConfig();
Directory.AAOS = Directory.BASE_PATH + filesep + "..";
Directory.AAOS_Input = Directory.BASE_PATH + filesep + "AAOS_Input" + filesep + Config.season;
Directory.AAOS_Output = Directory.BASE_PATH + filesep + "AAOS_Output" + filesep + Config.season;
Directory.SAFE = Directory.BASE_PATH + filesep + "vendor" + filesep + "safe_R1.1";
Directory.AOS = Directory.BASE_PATH + filesep + "vendor" + filesep + "AOS";
Directory.AOS_Input = Directory.AOS + filesep + "Input";

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

% Read lots included in the simulation:
cd(Directory.BASE_PATH);
Config = AAOS_DetermineSimulationLots(Config);

% 
[Config.ModelEval,Config.SimOut] = AAOS_StoreTestLotsAndObservations(Config);

% Get harvest day for every simulation lot:
Config.TargetVar.HarvestDay(1:size(Config.SimulationLots,1),1) =...
    Config.TargetVar.Observations(Config.SimulationLots,1);

Config = AAOS_ReadParameterInputFiles(Config,Directory);

cd(Directory.BASE_PATH)
for FileIdx = 1:numel(fieldnames(Config.ParameterValues))
        Config = AAOS_SubstituteMissingParameters(FileIdx,Config);
end

Config = AAOS_ReadParameterConfig(Config);

% Initialize AOS
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)