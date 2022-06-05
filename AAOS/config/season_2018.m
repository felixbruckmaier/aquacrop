%% CONFIG 2/2: Season-specific analysis settings:
% Incl. lots, number of irrigation files, depth of analyzed oil water content
% (SWC) variable, simulated initial SWC depths, substitutes for missing
% initial SWC values
% For meanings of analysis type acronyms ("DEF", ...), see CONFIG 1/2
% = "default.m" (config folder)


%% Season 2018:

%% 1. Settings for all analysis types:

% Select plots to be analysed:
Config.SimulationLots = [8 9 13 14 18 19]; % Options: x; [x y..];

% Define type of irrigation input: "0" = 1 irrigation file per plot; "1" =
% only 1 irrigation file for all plots
Config.N_IrrigationFiles = 1;

% Determine SWC depth idx to be analyzed:
Config.SWC_depth = 1;

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


%% 2. Settings for DEF/ CAL/ VAL analysis only:

% "DEF"/ "CAL"/ "VAL": Choose test variable(s): CC (1), SWC (2), HI (3):
% Options: [] (only for option "EE") / [1] / [2] / [1 2] / [1 2 3]
% (resetting to [1 2] for option "EE");
Config.TestVarIds = [1 2];

%% TO REVISE:

% CAL:
Config.CalibrationLots = Config.SimulationLots;

% % VAL:
% Config.ValidationLots = [];