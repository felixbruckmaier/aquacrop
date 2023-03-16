% Automated AquaCrop-OpenSource (AAOS) - Execution file
% Felix Bruckmaier (December 2022)
% Script to run AAOS
%
%% Provided & expected AAOS functionalities:
%% - Automated model setup and simulation for several lots and seasons,
% for up to 2 test variable timeseries (Canopy Cover/ Soil Water Content),
% and 2 target variables (Harvested Biomass/ Harvested Yield), 2 different
% parameter value sets (Default/ Calibrated), and up to 3 different
% calibration rounds (according to the AquaCrop calibration guidelines)
%% NOTE: The tool automatizes the AOS model run to facilitate an easier and
% more efficient comparison of different simulation outputs, it does NOT
% enable automatical calibration, hence the user is required to still manually
% calibrate AOS, by adjusting the 
% parameter values in the AAOS speadsheet
% input files.
%% - Parameter sensitivity analysis via the 'Morris method'/ Elementary
%% Effects (link to SAFE toolbox);
%% - Uncertainty analysis via the 'GLUE method' (link to SAFE toolbox);
%% - Output file creation incl. graphical evaluation for every feature;
%% - Quantification of water, aeration, heat, and cold stresses;
%% Usage:
% Specify config files in subfolder 'config': 'default.m' and config file
% for respective season
function [] = RUN_AAOS(config_custom)
tic % Set timer

% Determine directories and load config & input data:
[Directory,Config,AnalysisOut] = AAOS_Initialize();

% Perform selected AAOS analysis:
[Config,AnalysisOut] = AAOS_Analyze(Directory,Config,AnalysisOut);

% Finalize output, plot graphics, and, in case, write all output to Excel file:
AnalysisOut = AAOS_Finalize(Directory,Config,AnalysisOut);

disp("Time elapsed: "+round(toc/60)+" mins."); % Output computation time
end