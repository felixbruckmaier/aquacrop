%% Determine user-defined simulation characteristics and output file name:
function [FileName, GraphColors, GraphSizes, VarIds_User, N_Var_User,...
    TargetVarNameFull, TargetVarNameShort] =...
    AAOS_GLUE_GetSimulationSettingsForOutput(Config, Directory)

% Derive output file name:
FileName = AAOS_DeriveOutputFileName(Config, Directory);

% Determine graph specifications:
GraphColors = Config.GraphColors;
GraphSizes = [Config.GraphFontSizeTitle,Config.GraphFontSizeSubtitle,...
    Config.GraphFontSizeNormal,Config.GraphLineWidth,...
    Config.GraphMarkerSize,Config.GraphMarkerSizeDotPlot];
% Derive number & IDs of variables:
TestVarIds_User = Config.TestVarIds; % Test variable IDs
VarIds_User = [0 TestVarIds_User]; % Target ("0") & test variable IDs
N_Var_User = size(VarIds_User,2); % Number of variables (test & target)
% Derive target variable name:
TargetVarNameFull = Config.TargetVar.NameFull;
TargetVarNameShort = Config.TargetVar.NameShort;