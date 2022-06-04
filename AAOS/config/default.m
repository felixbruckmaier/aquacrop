% Choose season - "2018" or "2019":
Config.season = "2018";

% Add additional text to output filename (-> put at the end):
Config.filename_xtra = "";

% Decide whether to save graphical output in Excel ("Y" or "N")
% (only function for Excel spreadsheets available)
Config.WriteFig = "Y";

% Select type of analysis:
% WORKING:
% - "DEF" = Only simulation with default parameter values
% - "CAL" = Default run & calibration & recalculation of resp. other variables;
% - "EE" = Elementary Effects/ Morris Method ("Glocal" sensitivity analysis)
% ... TO-DO: Figures (DEF, CAL), Store bootstrapping figures (SA)
%
% CURRENTLY NOT WORKING:
% - "STQ" : Quantification of water, aeration, heat, & cold stresses;
% - "VAL" = See "CAL", but (automatically) calibr. & validating 50 % of the plots
% - "CAL/VAL/STQ/MEAN" = Calculating mean values for all plots (include in
% respective analysis!)
Config.RUN_type = "GLUE";
Config.thresh_TargetVar = 15;
Config.thresh_TestVar = 15;

% Define number of sampling points 'r' for LHS:
Config.r_target = 530;
Config.r = Config.r_target * 18;
Config.CreateNewSamples = 0;
Config.TargetVarEE = "Yield"; % Yield or Biomass

Config.SampStrategy = 'lhs' ; % Latin Hypercube                                       
Config.DesignType = 'radial'; % 'trajectory'; %                                                   

Config.validation = 0; % only labels figures (input data by the user, no automatic calculation of mean for the validation plots) 
% FOR CAL:
Config.CalcMean = 0; % 1 makes "extrainput.validation" irrelevant
% FOR STRQ:
Config.CalcMeanStress = 0; % Mean STRQ in addition to individual = plot-specific STRQ


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
Config.idx_TestSWC = 1;

% Graphical output specifications (NOT USED ATM):
Config.OutputSheet.CellWidth = 2.1;
Config.OutputSheet.CellHeight = 0.45;
Config.OutputSheet.FontSize = 10;

% Select Goodness of Fit criteria:
%% Keep order:"R2","RMSE","NSE" !
Config.GoF = ["R2","RMSE","NSE"];