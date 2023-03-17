%% General, study-independent specifications to be determined by the user

%% 1) Define general input and output settings:
% 1.1) Choose season (default: "template"):
Config.season = "Template";
% 1.2) Select type of analysis
% ... available:
% - Generalized Likelihood Uncertainty Estimation ("GLUE")
% - Elementary Effects method ("EE"):
Config.RUN_type = "GLUE";
% 1.3) Add additional text to output filename (-> inserted at the end):
Config.filename_xtra = "";
% 1.4) Determine type of graphical output to be created
% (Config.PlotGraphs = ["x", "y", ...])
%
%% - CURRENTLY UNavailable for EE:
% -- Sensitivity analysis of parameters ("EE")
%
% - available for GLUE (model error analysis for variables & parameters):
%% -- Time-series analysis ("TS")
%% -- Time-series analysis/ Predicton limits ("PL")
%% -- Culminated distribution function for variables ("CDF")
%% -- Distribution of simulations according to model error for 2 variables,
%% classified in quadrants ("Q")
% -- Distribution of behavioural parameter values through boxcharts
%% ---> 1 boxchart = 1 variable combination for all lots & 1 parameter ("BC_Combi")
%% ---> 1 boxchart = 1 lot for 1 variable combination & 1 parameter ("BC_Lots")
% -- Distribution of all parameter values with respect to GLF values classified
% within heatmap, differentiated between lots & variable combinations:
%% ---> differentiated between lots and variable combinations ("HM_Lots")
%% ---> differentiated between variable combinations only ("HM_All")
%% ---> Additional option: all lots & variable combinations stacked within 1 figure
%% or distributed over separate figures ("Config.StackHeatmaps")

Config.PlotGraphs =...
    ["TS","PL","CDF","Q","BC_Combi","BC_Lots","HM_Lots","HM_All"];
% 1.5) Parameter visualization options can result in a high number of graphical
% plots - specify a reduced number of parameters to plot in the following
% array ["x", "y", ...] (when left empty, all parameters will be plotted):
Config.ParametersToPlot = ["Ksat", "th_fc", "th_wp", "Senescence"];
% 1.6) Stack heatmaps for different lots or variable combinations ("Y") or
% plot them in separate figures ("N"):
Config.StackHeatmaps = "Y";
% 1.7) Decide which output to save in Excel sheet: "Y" or "N", respectively
% (only available for Excel file format ".xlsx")
Config.WriteFig = "N"; % Write figures
Config.WriteNum = "N"; % Write numerical output

%% 2) Define SAFE settings (“Sensitivity Analysis For Everybody” toolbox):
% 2.1) Select error thresholds for determining the model’s goodness of fit (GoF):
% ... here: GoF criteria = fixed:
% - TargetVar -> Absolute Relative Error (ARE) [%]
% - TargetVar -> Normalized Root Mean Square Error (NRMSE) [%]
Config.thresh_TargetVar = 15; % ... for target variable simulations
Config.thresh_TestVar = 15; % ... for test variable simulations
% 2.2) Select sampling strategy & design of sampling space exploration:
Config.SampStrategy = 'lhs' ; % Latin Hypercube Sampling (LHS)                                      
Config.DesignType = 'radial'; % 'radial' or 'trajectory'
% 2.3) Define parameters to be sampled in log scale ["x", "y"]
Config.LogScalePars = ["Ksat"];

%% 3) Define output specifications:
% 3.2) Graphical output:
% 3.2.1) Spreadsheet dimensions (-> Position & size of graphs)
Config.OutputSheet.CellWidth = 2.1; % Cell width
Config.OutputSheet.CellHeight = 0.45; % Cell height
% 3.2.2) Graph characteristics:
Config.GraphFontSizeNormal = 16; % Font size of normal text
Config.GraphFontSizeTitle = 18; % Font size of titles
Config.GraphFontSizeSubtitle = 16; % Font size of subtitles
Config.GraphLineWidth = 4; % Line width
Config.GraphMarkerSizeDotPlot = 50; % Marker size in dot plots
Config.GraphMarkerSize = 14; % Marker size in mixed plots
Config.GraphColors = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980];...
    [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880];...
    [0.3010 0.7450 0.9330];[0.6350 0.0780 0.1840]]; % Graph colors
% ... = blue/orange/yellow/purple/green/cyan/red; see...:
% https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html