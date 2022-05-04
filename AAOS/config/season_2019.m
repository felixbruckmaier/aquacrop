% Select plots to be analysed:
% Options: x; [x y..];
Config.SimulationLots = [1];
Config.CalibrationLots = Config.SimulationLots;
% % Validation:
% Config.ValidationLots = [];

% "DEF"/ "CAL"/ "VAL": Choose test variable(s): CC (1), SWC (2), HI (3):
% "GSA" / "STQ": Irrelevant (autom. resetting)
Config.TestVarIds = [1 2 3]; % Options: [1] / [2] / [1 2] / [1 2 3]

% Define type of irrigation input: "1" = 1 irrigation file per plot; "0" =
% only 1 irrigation file for all plots
Config.N_IrrigationFiles = 0;

% Define soil depths (centerpoints [m]) to be assigned an initial SWC value
Config.SimulatedSWCdepths = [0.1 0.25 0.5 0.6 0.8];

% Define, how missing soil water content observations will be substituted;
% Available: a) numerical value [frac], e.g. 0.2; b) value of one of the 3
% hydrological parameters that are specified for the resp. lot, i.e.
% "th_wp" = wilting point, "th_fc" = field capacity, or "th_sat" = saturation. 
Config.SWC_substitute = "th_wp";