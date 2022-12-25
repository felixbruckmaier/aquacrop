%% ADJUSTMENT REQUIRED (SEE BELOW)
%% Determine initial Soil Water Content (SWC) & write AOS input file for
% the current lot.
function [Config] = AAOS_WriteInitialSoilWaterContent(Config,Directory)

%% Determine simulated & observed depths and observed SWC values:

if ~ismember(2, Config.TestVarIds)
    ObsSWCdepths = nan;
    ObsSWCvalues = nan;
else
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
    end
end

%% Determine user-defined substitutes for missing SWC values:
SWC_substitutes = Config.SWC_substitute;
if ~isnumeric(Config.SWC_substitute) % substitute with a hydrological parameter
    % Determine the value of the parameter for the current lot:
    for idx_Subst = 1:size(SWC_substitutes,2)
        idx_ParNames = ismember(Config.AllParameterNames,char(Config.SWC_substitute(idx_Subst)));
        SWC_substitutes(idx_Subst) = Config.AllParameterValues(idx_ParNames);
    end
end


% Determine which of the simulated depths show SWC observations:
[ObservedSimDepths,Config.idx_SimDepthsObservations] = ismember(Config.SimulatedSWCdepths,ObsSWCdepths);

%% Set up initial SWC array to be used in the simulation:
% Determine simulation depths [m]:
IniSWC(1,:) = Config.SimulatedSWCdepths;
% Assign every available SWC observation to respective simulation depth:
IniSWC(2,ObservedSimDepths==1) = ObsSWCvalues;
IniSWC(2,ObservedSimDepths==0) = nan;
% Find all missing observations (either bc 1. simulation day or entire depth
% is missing):
Loc_MissingObs = isnan(IniSWC);
Ids_AllDepths = 1:size(IniSWC,2);
Ids_MissingObs = Ids_AllDepths(Loc_MissingObs(2,:)==1);

%% Substitute missing observations:
IniSWC(2,Ids_MissingObs) = SWC_substitutes(Ids_MissingObs);



%% Write AOS input file including every simulated depth & SWC value:
TestParAOSFile(1:5) = "InitialWaterContent";
TestParNames = string(IniSWC(1,:)');
TestParValues = string(IniSWC(2,:)');

AAOS_WriteAOSinputFiles(Directory,Config,TestParNames,TestParValues,TestParAOSFile);