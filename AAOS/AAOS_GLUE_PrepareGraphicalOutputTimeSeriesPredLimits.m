%% Plots all simulated test and target variable results (time-series graphs
% and dots, respectively), contrasting with respective obserTestVarNameFullved values (dots)
% and differentiating between behavioural and non behavioural simulations:
function [fs, fst, fsst, ms, lw, colors, TargetVarNameFull, TargetVarNameShort,...
    HarvestDays, TargetVarObs,TargetVarSim, xlabel_text]...
    = AAOS_GLUE_PrepareGraphicalOutputTimeSeriesPredLimits...
    (Config, LotAnalysisOut)

%% Determine graph specifications:
fs = Config.GraphFontSizeNormal; % Font size of normal text
fst = Config.GraphFontSizeTitle; % Font size of titles
fsst = Config.GraphFontSizeSubtitle; % Font size of subtitles
ms = Config.GraphMarkerSize; % Marker size in mixed plots
lw = Config.GraphLineWidth; % Line width
colors = Config.GraphColors; % Graph colors

%% Get target & test variable user settings & analysis results:
% Target variable name & abbreviation:
TargetVar = LotAnalysisOut.TargetVar;
TargetVarNameFull = TargetVar.NameFull;
TargetVarNameShort = TargetVar.NameShort;
% Harvest Days (= target variable observation days):
HarvestDays =  LotAnalysisOut.GLUE_Out.(TargetVarNameFull).HarvestDays;
% Observed target variable values:
TargetVarObs = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).TargetVarObs;
% Simulated target variable values:
TargetVarSim = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).TargetVarSim;


%% Determine graphs specifications:
% x axis left: Time (unit = days):
xlabel_text = 'Day After Sowing'; % x axis