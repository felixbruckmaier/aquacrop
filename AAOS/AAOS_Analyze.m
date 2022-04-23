%% Run the chosen AAOS analysis for every simulation lot:
% Until now: Only default analysis available.
function [Config,ModelOut] = AAOS_Analyze(Directory,Config,ModelOut)

% Determine number of lots to simulate:
LotNum = numel(Config.SimulationLots);

% Run analysis on every included lot:
for idx_SimLot = 1:LotNum

    % Lot indices & status message for user:
    Config.LotIdx = idx_SimLot; % index (of all lots to be simulated):
    Config.LotName = Config.SimulationLots(Config.LotIdx); % "name" (= index of all lots specified by the user):
    fprintf(1,"... analyzing lot '%s' (#%s/%s)...\n",...
        string(Config.LotName),string(idx_SimLot),string(LotNum));


    %% Adopts the config of the parameter set currently active in this round:
    Config = AAOS_ReadParameterConfig(Config);


    %% Read lot-specific user-input & write to respective AOS input file:
    % Irrigation schedule
    AAOS_WriteIrrigationSchedule(Directory,Config);

    % Initial Soil Water Content
    Config = AAOS_WriteInitialSoilWaterContent(Config,Directory);

    %% Perform chosen analysis:
    switch Config.RUN_type
        case {"DEF","CAL"}
            [Config,ModelOut] = AAOS_PerformModelEvaluation...
                (Config,Directory,ModelOut);
        case {"SA","UQ"}
AAOS_PerformSensitivityAnalysis(Config, Directory);

    end

end