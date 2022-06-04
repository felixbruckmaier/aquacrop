% Select plots to be analysed:
% Options: x; [x y..];
Config.SimulationLots = [8 9 13 14 18 19];
Config.CalibrationLots = Config.SimulationLots;
% % Validation:
% Config.ValidationLots = [];

% "DEF"/ "CAL"/ "VAL": Choose test variable(s): CC (1), SWC (2), HI (3):
 % Options: [] (only for option "EE") / [1] / [2] / [1 2] / [1 2 3]
 % (resetting to [1 2] for option "EE");
Config.TestVarIds = [1 2];

% Determine SWC depth idx to be analyzed:
Config.SWC_depth = 1;

% Define type of irrigation input: "0" = 1 irrigation file per plot; "1" =
% only 1 irrigation file for all plots
Config.N_IrrigationFiles = 1;

% Define soil depths (centerpoints [m]) to be assigned an initial SWC value
Config.SimulatedSWCdepths = [0.01 0.03 0.1 0.165 2.15];

% Define substitute for EACH above-defined simulation depth, for the case of
% missing soil water content observations;
% Available: a) numerical value [frac], e.g. 0.2; b) value of one of the 3
% hydrological parameters that are specified for the resp. lot, i.e.
% "th_wp" = wilting point, "th_fc" = field capacity, or "th_sat" = saturation. 
% (dimension == Config.SimulatedSWCdepths!)
Config.SWC_substitute(1:4) = "th_fc";
Config.SWC_substitute(5) = "th_wp";