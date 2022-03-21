%% Run the chosen AAOS analysis for every simulation lot:
% Until now: Only default analysis available.
function [Config] = AAOS_PerformAnalysis(Config,Directory)

% Define arrays for output files and fill in lot-unspecific data:
[ModelEval,SimOut] = AAOS_StoreTestLotsAndObservations(Config);

% Determine number of lots to simulate:
LotNum = numel(Config.SimulationLots);

for Idx_SimLot = 1:LotNum

    % For current lot...
    % ... store index (of all lots to be simulated):
    Config.LotIdx = Idx_SimLot;
    % ... store "name" (= index of all lots specified by the user):
    Config.LotName = Config.SimulationLots(Config.LotIdx);
    % ... give out status quo:
    fprintf(1,"... analyzing lot '%s' (#%s/%s)...\n",...
        string(Config.LotName),string(Idx_SimLot),string(LotNum));

    % Coming Soon:
    % Read user irrigation data and write AOS irrigation input file(s)
    % Read user soil water content (SWC) data and write AOS initial SWC file

    % Run chosen analysis:
    switch Config.RUN_type
    case "DEF"
        AAOS_PerformDefaultSimulation(Config,Directory,ModelEval,SimOut)
    end



end