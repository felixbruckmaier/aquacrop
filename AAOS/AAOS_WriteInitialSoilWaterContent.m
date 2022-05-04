%% ADJUSTMENT REQUIRED (SEE BELOW)
%% Determine initial Soil Water Content (SWC) & write AOS input file for
% the current lot.
function [Config] = AAOS_WriteInitialSoilWaterContent(Config,Directory)

%% Determine simulated & observed depths and observed SWC values:

% Get number of available (observed) SWC observation depths
[~,N_ObsSWCdepth] =  AAOS_ReadTestVariableObservationsFile...
    (Directory,Config,"SWC",0);
% Get available SWC observation depths [m] & values
if isnan(N_ObsSWCdepth) % no SWC observations on the current lot
    ObsSWCdepths = nan;
    ObsSWCvalues = nan;
else
    for idx_SWCdepth = 1:N_ObsSWCdepth
        % Read user SWC observations:
        [ObsSWCvalue,ObsSWCdepth] =  AAOS_ReadTestVariableObservationsFile...
            (Directory,Config,"SWC",idx_SWCdepth);
        % Get depth [m] of current soil depth:
        ObsSWCdepths(idx_SWCdepth) = ObsSWCdepth;
        % Get initial SWC value (1. SimDay) of current soil depth, if available:
        [row_FirstSimDay,~] = find(ObsSWCvalue(1,1)==1);
        if isempty(row_FirstSimDay)
            ObsSWCvalues(idx_SWCdepth) = nan;
        else
            ObsSWCvalues(idx_SWCdepth) = ObsSWCvalue(row_FirstSimDay,2);
        end
    end

    %% Determine user-defined substitutes for missing SWC values:
    SWC_substitute = Config.SWC_substitute;
    if ~isnumeric(SWC_substitute) % substitute with a hydrological parameter
        % Determine the value of the parameter for the current lot:
        idx_SubstHydrPar = ismember(Config.AllParameterNames,char(SWC_substitute));
        AllValues = Config.ParameterValues.(Config.ParFileType);
        %% CHANGE: ONLY WORKS IF a) SHP ARE PROVIDED IN AAOS FILE, AND B)
        % IF LOTS PROVIDE INPUT VALUES (~= SA/ UQ)!
        SWC_substitute = table2array(AllValues(idx_SubstHydrPar==1,7+Config.LotName));
    end
    % Determine which of the simulated depths show SWC observations:
    [ObservedSimDepths,Config.idx_SimDepthsObservations] = ismember(Config.SimulatedSWCdepths,ObsSWCdepths);
    %% Substitute 1/2: depths written in the input file missing observations:
    ObsSWCvalues(isnan(ObsSWCvalues)) = SWC_substitute;
end




%% Provide every simulated depth with a SWC value, either observed or substituted:
% Set up initial SWC array to be used in the simulation:
IniSWC(1,:) = Config.SimulatedSWCdepths; % depths [m]
% Assign observed values to all observed depths...:
IniSWC(2,ObservedSimDepths==1) = ObsSWCvalues;
% ... and substitute the others (2/2):
IniSWC(2,ObservedSimDepths==0) = SWC_substitute;

%% Write AOS input file including every simulated depth & SWC value:
TestParAOSFile(1:5) = "InitialWaterContent";
TestParNames = string(IniSWC(1,:)');
TestParValues = string(IniSWC(2,:)');

AAOS_WriteAOSinputFiles(Directory,Config,TestParNames,TestParValues,TestParAOSFile);