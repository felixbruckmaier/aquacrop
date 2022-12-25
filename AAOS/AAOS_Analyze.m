%% Run the chosen AAOS analysis for every simulation lot:
% Until now: Only default analysis available
function [Config,AnalysisOut] = AAOS_Analyze(Directory,Config,AnalysisOut)

% Determine number of lots to simulate:
LotNum = numel(Config.SimulationLots);

% Run analysis on every included lot:
for idx_SimLot = 1:LotNum

    % Lot indices & status message for user:
    Config.LotIdx = idx_SimLot; % index (of all lots to be simulated):
    Config.LotName = Config.SimulationLots(Config.LotIdx); % "name" (= index of all lots specified by the user):
    fprintf(1,"... analyzing lot '%s' (#%s/%s)...\n",...
        string(Config.LotName),string(idx_SimLot),string(LotNum));
    % Derive full name for current lot:
    LotNameFull = strcat("Lot",string(Config.LotName));
    LotAnalysisOut = struct;

    %% Adopts the config of the parameter set currently active in this round:
    Config = AAOS_ReadParameterConfig(Config);


    %% Read lot-specific user-input & write to respective AOS input file:
    % Irrigation schedule
    AAOS_WriteIrrigationSchedule(Directory,Config);



    %% Perform chosen analysis:
    switch Config.RUN_type
        case {"DEF","CAL"} % Default or Calibration runs
            [Config,AnalysisOut] = AAOS_PerformModelEvaluation...
                (Config,Directory,AnalysisOut);
        case {"EE","GLUE"} % SAFE-based analysis
            [Config, LotAnalysisOut] = AAOS_PerformSAFE(Config, Directory,LotAnalysisOut);
            AnalysisOut.(LotNameFull) = LotAnalysisOut;
    end
end

end