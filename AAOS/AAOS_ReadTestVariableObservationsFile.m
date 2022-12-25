%% Reads & stores the test variable observations for the lot, if available
% Available variables: Canopy Cover ('CC'), Soil Water Content ('SWC').
% For test variables: Only create input files for lots with observations.
function [ObsTestVar,ObsSWCdepths] = AAOS_ReadTestVariableObservationsFile...
    (Directory,Config,TestVarNameShort,idx_Observation)

cd(Directory.AAOS_Input);
ObsSWCdepths = nan;

% Determine name of file(s):

if Config.N_FilesObsInput.(TestVarNameShort) == 0 % data for all lots stored in 1 file
    idxLot = "";
elseif Config.N_FilesObsInput.(TestVarNameShort) == 1 % data stored in 1 file per lot
    idxLot = "_"+string(Config.LotName); 
end
% Retrieve filename:
File = dir(fullfile(Directory.AAOS_Input,...
    '*Obs*'+TestVarNameShort+'*'+idxLot+'.csv'));
try
    filename = File.name ;
catch
    filename = [];
end

% Read file, if available:
if not(isempty(filename))
    FileContentTab = readtable(filename,'ReadVariableNames',true);
    FileContentArr = table2array(FileContentTab(1:end,1:end));
    % Read observed days and values:
    %% Exclude 1. day of growing season = needed for initial SWC
    %% -> always must be indicated in SWC obs file, even when not observed
    ObsTestVar(:,1) = FileContentArr(1:size(FileContentArr,1),1);
    ObsTestVar(:,2) = round(FileContentArr(1:size(FileContentArr,1),1+idx_Observation),2);
    [nanrows,~] = find(isnan(ObsTestVar));
    ObsTestVar(nanrows,:) = [];
    
    if TestVarNameShort == "SWC"
        % When fun applied in 
        % 1. time in AAOS_InitialSoilWaterContent.m.:
        % only determine number of observed SWC depths:
        if idx_Observation == 0
            ObsSWCdepths = size(FileContentArr,2)-1;
        else
            % 2 time: Get SWC depth
            % corresponding to current SWC depth idx:
            ObsSWCdepths = FileContentArr(1,1+idx_Observation);
        end
    end
else
    % If no observations available for this variable, set up an empty array
    % and force the analysis to skip to next variable or lot, respectively:
    ObsTestVar = {};
end

cd(Directory.BASE_PATH);