%% Outputs number of all considered lots (Option a) & b)) and, in case,
% name and index of currently analyzed lot (Option b))
function [N_Lots,LotNameFull] = AAOS_GetLotNumberAndName(Config, LotIdx)

%% Option a) & b):
% Derive all lot names:
LotNames = Config.SimulationLots;
% Derive number of lots (not needed for option b))
N_Lots = numel(LotNames);

%% Option a) Define empty lot name (not needed for option a))
LotNameFull = string([]);

%% Option b) Derive name of current lot:
if LotIdx > 0
    LotName = LotNames(LotIdx); % Derive user-defined name
    LotNameFull = "Lot" + LotName; % Add 'Lot' as prefix
end