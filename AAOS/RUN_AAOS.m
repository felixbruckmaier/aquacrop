%% Automated AquaCrop-OpenSource (AAOS) - Execution file
% Felix Bruckmaier (2022)
% Script to run AAOS
%
%% Provided & expected AAOS functionalities:
% > automated model setup and simulation for several lots and seasons,
% for up to 2 test variable timeseries (Canopy Cover/ Soil Water Content),
% and 2 target variables (Harvested Biomass/ Harvested Yield), 2 different
% parameter value sets (Default/ Calibrated), and up to 3 different
% calibration rounds (according to the AquaCrop calibration guidelines)
% (now possible for season = 2019, lot #1, CanopyCover, Yield)
% NOTE: The tool does NOT offer automated calibration; the user is required
% to provide input files with both default, and calibrated parameter values.

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
fclose ('all'); % Close open files

% Determine directories and loads config & input data:
[Directory, Config] = AAOS_Initialize();

Config = AAOS_PerformAnalysis(Config,Directory);

fclose ('all'); % Close open files
%if InclExcel == 'Y'; actxserver('Excel.Application').Quit; end
timer = toc/60; % mins.
disp("Time elapsed: "+timer+" mins.");
%end
