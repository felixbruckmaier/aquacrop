%% Writes all numerical input and output data to a single spreadsheet
function [FileName] = AAOS_WriteModelEvaluation(Directory,Config,ModelOut)

%% 0. Get data and define output directory & filename:
% Get 2 output arrays from model output structure:
ModelEval = ModelOut.ModelEvaluation;
SimOut = ModelOut.SimulationOutput;

% Get number of test variables except HI (doesnt influence the sheet no.):
N_TestVar = min(2,numel(Config.TestVarIds));

% Change to and, in case, create directory for AAOS output files:
DirOutput = Directory.AAOS_Output;
if ~exist(DirOutput, 'dir')
    mkdir(DirOutput)
end

% Derive filename:
% ... from current timestamp (to avoid output file conflicts):
currentday_full = clock;
currentday = strcat(string(currentday_full(:,1)),"-",string(currentday_full(:,2)),"-",string(currentday_full(:,3))...
    ,"_",string(currentday_full(:,4)),"-",string(currentday_full(:,5)));
FileName = strcat(currentday,"_");
% ... season, analysis type:
FileName = strcat(FileName,"S",Config.season,"_",Config.RUN_type,"_");
if Config.CalcMean == 1
    FileName = strcat(FileName,"MEAN_");
end
% ...test & target variable(s) and GoFs:
% - Create string with all test variables:
TestVarNamesShortArr = strings(2,1);
TestVarNamesShortStr = "";
for idx_TestVar = 1:2
    [~,TestVarNameShort] = AAOS_SwitchTestVariable(idx_TestVar);
    TestVarNamesShortArr(idx_TestVar,1) = TestVarNameShort;
    TestVarNamesShortStr = strcat(TestVarNamesShortStr,"_",TestVarNameShort);
end
% - Create string with all calculated GoFs:
GoF_NamesStr = "";
GoF_NamesArr = strings(3,1);
for idx = 1:length(Config.GoF)
    GoF_NamesArr(idx) = Config.GoF(idx);
    GoF_NamesStr = strcat(GoF_NamesStr,"_",GoF_NamesArr(idx));
end
% - Assign all elements to filename:
if Config.RUN_type ~= "STQ"
    FileName = strcat(FileName,"of",TestVarNamesShortStr,"_on_",Config.TargetVar.NameShort,"_via",GoF_NamesStr);
end
% Determine final filename & add extension:
FileName = char(strcat(...
    Directory.AAOS_Output,filesep,FileName,Config.filename_xtra,".xlsx"));


%% A) Sheet: Parameter input data:

% Print 1 sheet each for default and calibrated parameter values, respect.
for idx_ParFile = 1:min(2,Config.SimRounds)
    if idx_ParFile == 1
        ParFileType = "DEF";
    elseif idx_ParFile == 2
        ParFileType = "CAL";
    end

    % Assign parameter file name as sheet name
    SheetName = strcat("Parameters_",ParFileType);

    % Get parameter input file content:
    % Header (1. row):
    ColumnTitlesCell = table2array(cell2table(...
        Config.ParameterValues.(ParFileType).Properties.VariableNames));
    % Parameter & AOS input files names (1. & 2. column):
    Names_AOSfiles = table2array(...
        Config.ParameterValues.(ParFileType)(:,1:3));
    % All numerical values (rest of the file):
    NumericValues = table2array(...
        Config.ParameterValues.(ParFileType)(:,4:end));

    % Write data to Excel file:
    cd(DirOutput);
    writematrix(NumericValues,...
        char(FileName),'Sheet',SheetName,'Range','D2');
    writecell(ColumnTitlesCell,...
        char(FileName),'Sheet',SheetName,'Range','A1');
    writecell(Names_AOSfiles,...
        char(FileName),'Sheet',SheetName,'Range','A2');
end

%% B) Sheet: ModelEval
% Set up sheet headers (32 columns / first 3 rows)
% (1 version, valid for all 3 analysis DEF/ CAL/ VAL, and 1-3 target variables) 

% Header (1. row):
ColumnTitlesStr =...
    ["Output type:","|"+string(Config.TargetVar.NameFull),... % 1. row
    " dev.","from","OBS [%]","","--->",...
    "|"+string(Config.TargetVar.NameFull)," Abs."," val. ","[t/ha]",...
    "","","--->",...
    "|GoF:",GoF_NamesArr(1),"","","","--->",...
    "|GoF:",GoF_NamesArr(2),"","","","--->",...
    "|GoF:",GoF_NamesArr(3),"","","","--->";...
    "Test variable:","-",TestVarNamesShortArr(1),TestVarNamesShortArr(2),TestVarNamesShortArr(2),TestVarNamesShortArr(1),... % 2. row
    "-","-","-",TestVarNamesShortArr(1),TestVarNamesShortArr(2),TestVarNamesShortArr(2),TestVarNamesShortArr(1),"-",...
    TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(2),TestVarNamesShortArr(2),TestVarNamesShortArr(2),...
    TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(2),TestVarNamesShortArr(2),TestVarNamesShortArr(2),...
    TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(1),TestVarNamesShortArr(2),TestVarNamesShortArr(2),TestVarNamesShortArr(2);...
    "Plot v","HI","REC","CAL","REC","CAL","DEF",...% 3. row
    "OBS","HI","REC","CAL","REC","CAL","DEF",...
    "REC","CAL","DEF","CAL","REC","DEF",...
    "REC","CAL","DEF","CAL","REC","DEF",...
    "REC","CAL","DEF","CAL","REC","DEF"];
ColumnTitlesCell = cellstr(ColumnTitlesStr);


% Write data to Excel file:

% Column titles, first 3 rows:
writecell(ColumnTitlesCell,char(FileName),'Sheet','ModelEval','Range','A1');
% Lot IDs, first column:
writematrix(ModelEval(:,1),char(FileName),'Sheet','ModelEval','Range','A4');
% If more than 1 lot being simulated: Set up row for "overall GoF values",
% i.e. GoFs calculated for observed/simulated values from ALL lots:
if numel(Config.SimulationLots) > 1
    % Index "All", first column/ last row:
    writecell(cellstr('All:'),char(FileName),'Sheet','ModelEval',...
        'Range','A'+string((3+size(ModelEval,1))));
end
% Observation & model performance output (target variable and GoF values),
% second till last column:
writematrix(ModelEval(:,2:end),...
    char(FileName),'Sheet','ModelEval','Range','B4');



%% C) Sheets: AOS model simulation output


% Define Excel sheets according to analysis and used test variables:

% DEF mode needs 3 sheets per test variable for simulation days, observed
% values & default simulation output:
AnalysisNames(1,:) = ["DAY","OBS","DEF"];
if N_TestVar>1
    AnalysisNames(2,:) = AnalysisNames(1,:);
end
% CAL requires 2 more sheets/ test variable for calibration & recalculation:
if Config.RUN_type == "CAL"
    AnalysisNames(1,4:5) = ["CAL","REC"];
    if N_TestVar>1
        AnalysisNames(2,4:5) = ["REC","CAL"];
    end
end

% Define header for every sheet (1. row):
SimOutHeader = cellstr(["Lot", "| Values", "-> ..."]);

% Write Output for all used test variables:
for idx_TestVar = 1:N_TestVar
    % Determine name of current variable:
    cd(Directory.BASE_PATH);
    [TestVarNameFull,~] = AAOS_SwitchTestVariable(idx_TestVar);
    cd(DirOutput);
    
    % Write every defined sheet:
    for SimTypeIdx = 1:length(AnalysisNames)
        % Create sheet name from current test variable & model output type:
        SheetName = char(strcat(TestVarNameFull,"_",AnalysisNames(idx_TestVar,SimTypeIdx)));
        % Write header (1. row)
        writecell(SimOutHeader,...
            char(FileName),'Sheet',SheetName,'Range','A1');
        % Write numerical output (from 2. row), incl. lot index (1. column)
        % and values (from 2. column)
        writematrix(SimOut(:,:,SimTypeIdx,idx_TestVar),...
            char(FileName),'Sheet',SheetName,'Range','A2');
    end
end
cd(Directory.BASE_PATH);

% Assign 2 output arrays to model output structure:
ModelOut.ModelEvaluation = ModelEval;
ModelOut.SimulationOutput = SimOut;