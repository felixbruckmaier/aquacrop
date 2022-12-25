% Select plots to be analysed:
% Options: x; [x y..];
Config.SimulationLots = [9]; % [8 9 13 14 18 19];
Config.CalibrationLots = Config.SimulationLots;
% % Validation:
% Config.ValidationLots = [];

% Define number of sampling points 'r' for LHS:
Config.r_target = 2;
Config.TargetVarEE = "Biomass"; % Yield or Biomass
% Determine the number of samples to be created and tested against
% phenological conflicts ("Config.r_test"), as a multitude of the number of
% valid samples that should be created in the end ("Config.r_target").
% Their relationship depends on the specified conflicts and crop/weather
% input data (the fewer the possible valid options for phenology parameters,
% the higher the factor should be): 
Config.r_test = Config.r_target * 15; % *5

% Either load existing samples ("0") or create new samples ("1"):
Config.CreateNewSamples = 0;

% Define file name prefix for samples to be created/loaded:
Config.Samples_FileNamePrefix = "Samples10070_";

% "GLUE" / "EE" / "DEF"/ "CAL"/ "VAL": Choose test variable(s):
% CC (1) and/ or SWC (2) and/ or HI (3):
% Possible combinations:
% - [] (only for option "EE")
% - [1]
% - [2]
% - [1 2]
% - [1 2 3]
 % (automatically resetting to [1 2] for option "EE");
Config.TestVarIds = [1 2];

% Determine SWC depth idx to be analyzed:
Config.SWC_depth = 1;

% Define type of observation input for irrigation data and all analyzed test
% variables: "1" = 1 file per plot; "0" = 1 file for all plots
% - dim.= ["Irrigation file" "Test variable #1 file" "Test variable #2 file"]
% - test variable no. as defined in "Config.TestVarIds" (see above)
Config.N_FilesObsInput = [0 1 1]; 

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

% Define phenological conflicts for the analyzed crop, based on following
% relations (which are stored as follows: Config.PhenoConflicts = X(1:6)):
% Var.Senescence < Var.Emergence + X(1)
% Var.Maturity < Var.Emergence + X(2)
% Var.HIstart < Var.Emergence + X(3)
% Var.Senescence > Var.Emergence + X(4)
% Var.Maturity > Var.Emergence + X(5)
% Var.HIstart > Var.Emergence + X(6)
%
% -> Determine every x with appropriate values in Growing Degree Days [GDD];
% -> Indicate "-9999" if a conflict shall be ignored during the analysis.
Config.PhenoConflicts =  [1000, 1500, 1000, 2000, 2900, 1300];