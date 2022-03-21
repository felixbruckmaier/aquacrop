% Choose season - "2018" or "2019":
Config.season = "2019";

% Add additional text to output filename (-> at the end):
Config.filename_xtra = ""; % either "" or "_blablub"

% Decide whether to save graphical output in Excel ("Y" or "N")
Config.InclExcel = "N";

% Select type of analysis:
% WORKING:
% - "CAL" : Default run & calibration & recalculation of resp. other variables;
% - "STRQ" : Quantification of water, aeration, heat, & cold stresses;
% - "CAL" & extrainput.CalcMean : Define if all plots shall be simulated individually
% (extrainput.CalcMean = "0"), or a mean of all simulations/ observations ("1")
% - FOR VALIDATION, CALCULATE FOR ALL PLOTS TO BE VALIDATED THE RESPECTIVE MEAN
% OF PARAMETER VALUES BEFORE-HAND, CHOOSE RUN_type = "CAL" & extrainput.validation = "1"
%
% CURRENTLY NOT WORKING:
% "GSA" = Global Sensitivity Analysis via SAFE toolbox. - REQU SMALL ADJUSTMENTS
% "DEF" = Only simulation with default parameter values
%       ERROR MESSAGE:
%       "Error using histc
%       Edge vector must be monotonically non-decreasing.
%       Error in AAOS_PlotFigCalibration (line 248)
%       GoFs_count = histc(GoF(:,idx),GoFs_uni);"
% "VAL" = See "CAL", but (automatically) calibr. & validating 50 % of the plots
Config.RUN_type = "DEF";
Config.EE_num = 1000;
Config.validation = 0; % only labels figures (input data by the user, no automatic calculation of mean for the validation plots) 
% FOR CAL:
Config.CalcMean = 1; % 1 makes "extrainput.validation" irrelevant
% FOR STRQ:
Config.CalcMeanStress = 1; % Mean STRQ in addition to individual = plot-specific STRQ


% b) Validation:
% b)i) Selection via ttest -> define ttest probability threshold for train vs. test popul. split [0..1]
Config.ttestThreshold = 0.95;


% Example for ttested populations of plots:
% -> season 2018: Biomass, p = 1, test plots = [1 4 5 9 10 11 14 15 16 18 21 23 24 26 29 32];
% -> season 2019: Yield, p = 1, test plots = [1,3,8,9,10,11,13,15,17,19,20,24]

% if fix value used ("2"): assign value
Config.SubstituteSWC = 1; % 1 = WP; 2 = FC; 3 = SAT

% 1.c) Select Ini SWC calculation method: 'Depth'; 'Layer'
Config.IniSWCcalc = "Depth";

% 2.) Calibration: When including SWC, select soil depth idx to analyze:
Config.TestSWCidx = 1; % here: 2019 = 1-4; 2018 = 1 (2018 autom. resets)

% For Analysis Type = "RAW" (GDD<->CD conversion):
% 1. Select types for which parameter input files shall be written:
Config.WriteParFiles = ["CAL"]; % ["CAL", "DEF"]
% 2. Choose parameters whose ranges are to be determined, by
% transforming the AquaCrop Manual ranges [GDD] into [CD]:
Config.SwitchCalType = 0;
Config.AdjustMaturity = 1; % Maturity also being adjusted


% Graphical output specifications (NOT USED ATM):
Config.excel.CellWidth = 2.1;
Config.excel.CellHeight = 0.45;
Config.excel.FontSize = 10;

% Select Goodness of Fit criteria:
Config.GoF = ["R2","RMSE","NSE"]; % !!! keep order:"R2","RMSE","NSE" !!!