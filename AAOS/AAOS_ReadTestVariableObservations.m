%% Reads & stores the test variable observations for the lot, if available
% Available variables: Canopy Cover ('CC'), Soil Water Content ('SWC').
% For test variables: Only create input files for lots with observations.
function [ObsTestVar,ObsSWCdepths] = AAOS_ReadTestVariableObservations...
    (Directory,Config,TestVarNameShort,idx_Observation)

cd(Directory.AAOS_Input);
ObsSWCdepths = nan;

% Retrieve filename:
file = dir(fullfile(Directory.AAOS_Input,...
    '*Obs*'+Config.season+'*'+TestVarNameShort+'*'+'_'+string(Config.LotName)+'.csv'));
try
    filename = file.name ;
catch
    filename = [];
end

% Read file, if available:
if not(isempty(filename))
    FileContentTab = readtable(filename,'ReadVariableNames',true);
    FileContentArr = table2array(FileContentTab(1:end,1:end));
    ObsTestVar(:,1) = FileContentArr(2:size(FileContentArr,1),1);
    ObsTestVar(:,2) = round(FileContentArr(2:size(FileContentArr,1),1+idx_Observation),2);
    [nanrows,~] = find(isnan(ObsTestVar));
    ObsTestVar(nanrows,:) = [];
    
    if TestVarNameShort == "SWC"
        % When fun applied in AAOS_InitialSoilWaterContent.m:
        % 1. time: only determine number of observed SWC depths:
        if idx_Observation == 0
            ObsSWCdepths = size(FileContentArr,2)-1;
            % 2. time: Get SWC depth corresponding to current SWC depth idx:
        else
            ObsSWCdepths = FileContentArr(1,1+idx_Observation);
        end
    end
else
    % If no observations available for this variable, set up an empty array
    % and force the analysis to skip to next variable or lot, respectively:
    ObsTestVar = {};
end

cd(Directory.BASE_PATH);