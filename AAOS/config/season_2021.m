% Select plots to be analysed:
% Options: x; [x y..];
Config.SimulationLots = 1;
Config.CalibrationLots = Config.SimulationLots;
% % Validation:
% Config.ValidationLots = [];

% Define number of sampling points 'r' for LHS:
Config.r_target = 500;
Config.TargetVarEE = "Biomass"; % Yield or Biomass
% Determine the number of samples to be created and tested against
% phenological conflicts ("Config.r_test"), as a multitude of the number of
% valid samples that should be created in the end ("Config.r_target").
% Their relationship depends on the specified conflicts and crop/weather
% input data (the fewer the possible valid options for phenology parameters,
% the higher the factor should be): 
Config.r_test = Config.r_target * 15;

% Either load existing samples ("0") or create new samples ("1"):
Config.CreateNewSamples = 1;
% Define file name prefix for samples to be created/loaded:
Config.Samples_FileNamePrefix = "SamplesForSAFE_";

% "DEF"/ "CAL"/ "VAL": Choose test variable(s): CC (1), SWC (2), HI (3):
 % Options: [] (only for option "EE") / [1] / [2] / [1 2] / [1 2 3]
 % (resetting to [1 2] for option "EE");
Config.TestVarIds = [];

% Determine SWC depth idx to be analyzed:
Config.SWC_depth = 1;

% Define type of irrigation input: "0" = 1 irrigation file per plot; "1" =
% only 1 irrigation file for all plots
Config.N_IrrigationFiles = 1;

% Define soil depths (centerpoints [m]) to be assigned an initial SWC value
Config.SimulatedSWCdepths = [1];

% Define type of observation input for irrigation data and all analyzed test
% variables: "1" = 1 file per plot; "0" = 1 file for all plots
% - dim.= ["Irrigation file" "Test variable #1 file" "Test variable #2 file"]
% - test variable no. as defined in "Config.TestVarIds" (see above)
Config.N_FilesObsInput = [0]; 

% Define soil depths (centerpoints [m]) to be assigned an initial SWC value
Config.SimulatedSWCdepths = [0.5];

% Define substitute for EACH above-defined simulation depth, for the case of
% missing soil water content observations;
% Available: a) numerical value [frac], e.g. 0.2; b) value of one of the 3
% hydrological parameters that are specified for the resp. lot, i.e.
% "th_wp" = wilting point, "th_fc" = field capacity, or "th_sat" = saturation. 
% (dimension == Config.SimulatedSWCdepths!)
Config.SWC_substitute = "th_fc";

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
Config.PhenoConflicts =  [1084.7, -9999, 600, 1393.2, -9999, 679.6];

% SenescenceGDD < EmergenceGDD + 1150,...
%     SenescenceGDD > EmergenceGDD + 1500,...
%     MaturityGDD < EmergenceGDD + 1303.8,...
%     MaturityGDD > EmergenceGDD + 1348.95,...
%     HIstartGDD < EmergenceGDD + 600,...
%     HIstartGDD > EmergenceGDD + 900
% % MaturityGDD < EmergenceGDD + 1450,...
% %     MaturityGDD > EmergenceGDD + 1850,...