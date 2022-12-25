%% Determines irrigation schedule & write AOS input file for the current lot
function AAOS_WriteIrrigationSchedule(Directory,Config)

cd(Directory.AAOS_Input);

%% Get irrigation data:
% Determine name of file(s):
if Config.N_FilesObsInput.Irrigation == 0 % data for all lots stored in 1 file
    idx_IrrFile = "";
elseif Config.N_FilesObsInput.Irrigation == 1 % data stored in 1 file per lot
    idx_IrrFile = string(Config.LotName)+'*'; 
end
File = dir(fullfile(Directory.AAOS_Input,'*Irrigation*'+idx_IrrFile+'.csv')); %% file w/ dates & values
FileName = File.name;
% Get initial irrigation values:
FileContent = readtable(FileName,'ReadVariableNames',false);
VarValues = table2array(FileContent(3:end,1:4));

%% Write AOS input file:
cd(Directory.BASE_PATH);
VarNames = {'Day';'Month';'Year';'Irrigation'};
FileName = "IrrigationSchedule";
% OmitTemplate = 0;
AAOS_OverwriteVariableInAOSfile(Config,Directory, ...
    FileName,VarNames,VarValues);