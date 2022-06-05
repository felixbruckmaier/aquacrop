%% CONFIG 1/2: Settings applicable for all analyzed seasons



%% 1. Settings for all analysis types:

% Choose season:
Config.season = "2018"; % here available: "2018" or "2019"

% Choose target variable:
Config.TargetVarEE = "Yield"; % available: "Yield" or "Biomass"

% Add text to output filename (-> inserted at the end):
Config.filename_xtra = "";

% Decide whether to save graphical output in Excel ("Y" or "N")
% (there is only a function available that plots graphics into Excel spreadsheets)
Config.WriteFig = "Y";

% Define graphical Excel output specifications (NOT USED ATM):
Config.OutputSheet.CellWidth = 2.1;
Config.OutputSheet.CellHeight = 0.45;
Config.OutputSheet.FontSize = 10;


% Select type of analysis:

% A) WORKING:
% - "DEF" = Only simulation with default parameter values
% - "CAL" = Default run & calibration & recalculation of resp. other variables;
% - "EE" = Elementary Effects/ Morris method ("Glocal" sensitivity analysis)
% - "GLUE" = "Generalized Likelihood Uncertainty Estimation" method
% (Uncertainty quantification)

% B) CURRENTLY NOT WORKING:
% - "STQ" : Quantification of water, aeration, heat, & cold stresses;
% - "VAL" = See "CAL", but (automatically) calibr. & validating 50 % of the plots
% - "CAL/VAL/STQ/MEAN" = Calculating mean values for all plots (include in
% respective analysis!)

Config.RUN_type = "GLUE";
Config.thresh_TargetVar = 15;
Config.thresh_TestVar = 15;



%% 2. Settings for EE & GLUE analysis only (sampling specifications):

% Define Sampling strategy and type of parameter space exploration:
Config.SampStrategy = 'lhs' ; % = Latin Hypercube                                       
Config.DesignType = 'radial'; % Alternative: 'trajectory';

% Define whether to create new samples or use a given .mat file (.mat file
% must be stored in folder AAOS_Input)
Config.CreateNewSamples = 0;

% Define name of sampling .mat file to be either created or opened during
% the analysis (created for every lot -> the corresponding lot name will be
% automatically attached at the end of the file name):
Config.SamplingOut_FileNamePrefix = strcat("SamplesForSAFE_Season",Config.season);


% Define number of sampling points:

% "target"/ final number = to be achieved after removal of unrealistic samples:
Config.r_target = 530;

% "default" number = samples to be derived initially, including unrealistic
% samples, and thus required to be substantially larger than the target number;
% for the given specifications regarding unrealistic samples required a default
% number that is 18 times larger than the target:
Config.r_default = Config.r_target * 18;

% Alternative: automatically adding new samples by integrating the SAFE sampling
% function into a while loop: https://www.safetoolbox.info/faqs/



%% (REVISE:)


%% 3. Settings for STQ analysis only:
Config.CalcMeanStress = 0; % Mean STQ in addition to individual = plot-specific STRQ


%% 4. Settings for CAL/ VAL analysis:

% Select Goodness of Fit criteria:
%% Keep order:"R2","RMSE","NSE" !
Config.GoF = ["R2","RMSE","NSE"]; % available: "R2", "RMSE", "NSE"

% CAL:
Config.CalcMean = 0; % 1 makes "extrainput.validation" irrelevant

% VAL:
Config.validation = 0; % only labels figures (input data by the user, no automatic calculation of mean for the validation plots) 

% Selection via ttest -> define ttest probability threshold for train vs. test popul. split [0..1]
Config.ttestThreshold = 0.95;
% Example for ttested populations of plots:
% -> season 2018: Biomass, p = 1, test plots = [1 4 5 9 10 11 14 15 16 18 21 23 24 26 29 32];
% -> season 2019: Yield, p = 1, test plots = [1,3,8,9,10,11,13,15,17,19,20,24]



