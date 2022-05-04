% Automated AquaCrop-OpenSource (AAOS) - Execution file
% Felix Bruckmaier (2022)
% Script to run AAOS
%
%% Provided & expected AAOS functionalities:
% > automated model setup and simulation for several lots and seasons,
% for up to 2 test variable timeseries (Canopy Cover/ Soil Water Content),
% and 2 target variables (Harvested Biomass/ Harvested Yield), 2 different
% parameter value sets (Default/ Calibrated), and up to 3 different
% calibration rounds (according to the AquaCrop calibration guidelines)
% (now possible for season = 2019)
% NOTE: The tool automatizes the AOS model run to facilitate an easier and
% more efficient comparison of different simulation outputs, does NOT automatically
% calibrate AOS, hence the user is required to still manually calibrate,
% by adjusting the parameter values in the AAOS speadsheet input files.

% COMING SOON:
% > Validation of the calibrated model through the 'Validation Set Approach';
% > Quantification of water, aeration, heat, and cold stresses;
% > Parameter sensitivity analysis (link to SAFE toolbox);
% > Uncertainty analysis via the 'GLUE method' (link to SAFE toolbox);
% > Output file creation incl. graphical evaluation for every feature;
% > App feature for non-Matlab users.
%
%% Usage:
% Specify config files in subfolder 'config': 'default.m' and config file
% for respective season
function [] = RUN_AAOS(config_custom)
tic % Set timer

% Determine directories and load config & input data:
[Directory,Config,AnalysisOut] = AAOS_Initialize();

% Perform selected AAOS analysis:
[Config,AnalysisOut] = AAOS_Analyze(Directory,Config,AnalysisOut);

% Finalize output and, in case, write to Excel file:
AnalysisOut = AAOS_Finalize(Directory,Config,AnalysisOut);

disp("Time elapsed: "+round(toc/60)+" mins."); % Output computation time
