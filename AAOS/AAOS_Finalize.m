%% REVISE: GRAPHICAL OUTPUT FUNCTIONS
%% Calculate GoFs for all observation values together, and plot & write figures
function AnalysisOut = AAOS_Finalize(Directory,Config,AnalysisOut)


% Determine graph specifications:
colors = Config.GraphColors;
GraphSizes = [Config.GraphFontSizeTitle,Config.GraphFontSizeSubtitle,...
    Config.GraphFontSizeNormal,Config.GraphLineWidth,...
    Config.GraphMarkerSize,Config.GraphMarkerSizeDotPlot];

% Derive name of output file:
FileName = AAOS_DeriveOutputFileName(Config, Directory);

% Derive number of test variables:
TestVarIds = Config.TestVarIds;

TargetVarNameFull = Config.TargetVar.NameFull;
TargetVarNameShort = Config.TargetVar.NameShort;

AllSamplesAllLots = [];
GLF = [];
idcsBHS_AllVar = [];


switch Config.RUN_type
    case {"EE","GLUE"}
        LotNames = Config.SimulationLots;
        %% Initialize parameters:
        % Samples_All = [];
        % idx_GoodTestAndTarget_AllLots = [];
        % GLF_TargetVar_AllLots = [];
        % idx_GoodTarget_AllLots = [];
        % AllSamplesAllLots = {};

        N_Lots = numel(LotNames);

        for LotIdx = 1:N_Lots
            LotName = LotNames(LotIdx);
            LotsObs = Config.TargetVar.Observations;
            [~,row_Lot] = ismember(Config.LotName,LotsObs(:,1));

            if row_Lot == 0
                fprintf(2,'No Harvested ' + TargetVarNameFull +...
                    ' value available for lot #'+LotName+'.\nSwitching to next lot.\n');
            else
                fprintf(1,"... generating numerical output for lot '%s' (#%s/%s)...\n",...
                    string(LotName),string(LotIdx),string(N_Lots));
                % Assign parameter file name as sheet name
                LotNameFull = "Lot" + LotName;
                LotAnalysisOut = AnalysisOut.(LotNameFull);

                AAOS_SAFE_WriteNumericalOutput(Config, Directory, FileName, LotAnalysisOut, LotNameFull);


                %% Graphical Output
                if Config.RUN_type == "EE" &&...
                        any(contains(Config.PlotGraphs,["EE"]))
                    fprintf(1,"... generating graphical EE output for lot '%s' (#%s/%s)...\n",...
                        string(LotName),string(LotIdx),string(N_Lots));
                    cd(Directory.BASE_PATH)
                    AAOS_EE_PlotAndWriteGraphicalOutput(Config, Directory, FileName, LotAnalysisOut, LotIdx, LotNameFull);
                elseif Config.RUN_type == "GLUE" &&...
                        any(contains(Config.PlotGraphs,["CDF","Q","V","TS","PL"]))

                    %% Get target var analysis results:
                    TargetVarSim = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).TargetVarSim; % Simulated values
                    %% Get user settings & analysis results:
                    ParameterNames = LotAnalysisOut.ParameterNames;
                    N_Pars = size(ParameterNames,1); % Number of parameters
                    % Number of simulated values for every test variable:
                    AvailTestVarSizes = LotAnalysisOut.GLUE_Out.AvailableTestVariableSizes;
                    AvailTestVars = LotAnalysisOut.GLUE_Out.AvailableTestVariables;
                    N_TestVars = numel(AvailTestVars);

                    % Number of simulations:
                    N_Sim = size(TargetVarSim,1);
                    N_Sim_All = N_Sim * N_Lots;
                    N_Sim_txt = string(N_Sim);


                    % Determine & process simulation results of variables:

                    if any(contains(Config.PlotGraphs,["CDF","Q","PL","V"]))
                        VarIds1 = [0 AvailTestVars];
                        ColIdx = 0;
                        for VarIdx1 = VarIds1
                            ColIdx = ColIdx + 1;
                            if VarIdx1 == 0
                                GLF_Type = "GLF_TargetVar";
                                Idx_Type = "idx_GoodTarget";
                                VarNameFull = AnalysisOut.TargetVar.NameFull;
                            else
                                GLF_Type = "GLF_TestVar";
                                Idx_Type = "idx_GoodTest";
                                [VarNameFull,~] = AAOS_SwitchTestVariable(VarIdx1);
                            end
                            [GLF, idcsBHS_AllVar] = AAOS_GLUE_PrepareGraphicalOutputStatistics...
                                (AnalysisOut, LotIdx, LotNameFull, GLF, idcsBHS_AllVar,...
                                GLF_Type, Idx_Type, VarNameFull,N_Sim,ColIdx);
                            cd(Directory.BASE_PATH);

                        end
                    end

                    PlotTS_GraphsTypes = contains(Config.PlotGraphs,["TS","PL"]);
                    if any(PlotTS_GraphsTypes==1)
                        [fs, fst, fsst, ms, lw, colors, TargetVarNameFull,...
                            TargetVarNameShort,HarvestDays, TargetVarObs,...
                            TargetVarSim, xlabel_text]...
                            = AAOS_GLUE_PrepareGraphicalOutputTimeSeriesPredLimits...
                            (Config, LotAnalysisOut);


                        for idxTS_GraphType = 1:size(PlotTS_GraphsTypes,2)
                            if PlotTS_GraphsTypes(idxTS_GraphType) ~= 0
                                GraphType = Config.PlotGraphs(idxTS_GraphType);
                                for TestVarIdx = 1:N_TestVars


                                    if any(~isnan(AvailTestVars))
                                        [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(TestVarIdx);
                                        % Test variable simulation days (= days with observations):
                                        TestVarDays = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarDays;
                                        % Observed test variable values:
                                        TestVarObs = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarObs;
                                        % Simulated test variable values:
                                        TestVarSim = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarSim;
                                    else
                                        TestVarNameFull = nan;
                                        TestVarNameShort = nan;
                                        TestVarDays = nan;
                                        TestVarObs = nan;
                                        TestVarSim = nan;
                                    end

                                    if GraphType == "TS"
                                        %fprintf(1,"... generating time-series graph for lot '%s' (#%s/%s)"+...
                                            %" & variable '%s' (#%s/%s)...\n",...
                                            %string(LotName),string(LotIdx),string(N_Lots),...
                                            %string(TestVarNameFull),string(TestVarIdx),string(N_TestVars));

                                        AAOS_GLUE_PlotGraphicalOutputTimeSeries...
                                            (LotAnalysisOut, LotNameFull, fs, fst, fsst, ms, lw, colors, ...
                                            TargetVarNameFull,TargetVarNameShort, HarvestDays, TargetVarObs,...
                                            TargetVarSim, TestVarNameFull, TestVarNameShort, TestVarDays,...
                                            TestVarSim, TestVarObs,xlabel_text, N_Sim_txt)

                                        % Location in Excel file:
                                        GraphColumn = 'A';
                                        GraphSheet = "TimeSeries";
                                        if Config.WriteFig == 'Y'
                                            AAOS_GLUE_WriteGraphicalOutputTimeSeriesPredLimits...
                                                (Config, Directory, FileName, LotIdx, GraphSheet, GraphColumn, N_Sim_txt);
                                            cd(Directory.BASE_PATH);
                                        end
                                        hold off;

                                    end
                                    if GraphType == "PL"
                                        fprintf(1,"... generating prediction-limits graph for lot '%s' (#%s/%s)"+...
                                            " & variable '%s' (#%s/%s)...\n",...
                                            string(LotName),string(LotIdx),string(N_Lots),...
                                            string(TestVarNameFull),string(TestVarIdx),string(N_TestVars));


                                        AAOS_GLUE_PlotGraphicalOutputPredLimits...
                                            (LotAnalysisOut,LotNameFull, fs, fst, fsst, colors,TargetVarNameFull,TargetVarNameShort,...
                                            TestVarNameFull,TestVarNameShort,HarvestDays,TestVarDays,TestVarObs,xlabel_text, N_Sim_txt)

                                        % Location in Excel file:
                                        GraphColumn = 'M';
                                        GraphSheet = "PredictionLimits";
                                        if Config.WriteFig == 'Y'
                                            AAOS_GLUE_WriteGraphicalOutputTimeSeriesPredLimits...
                                                (Config, Directory, FileName, LotIdx, GraphSheet, GraphColumn);
                                            cd(Directory.BASE_PATH);
                                        end
                                        hold off;

                                    end


                                end


                            end
                        end
                    end

                end
            end
        end

        %% Plot and, in case, write all req statistical GLUE-related graphs:
        if Config.RUN_type == "GLUE" &&...
                any(contains(Config.PlotGraphs,["CDF","Q","V"]))

            % Create 1 single array containing GLF values and BHS indices
            % from all plots and for all analyzed variables:
            idx_arr_temp = permute(idcsBHS_AllVar,[1 3 2]);
            idcsBHS_AllVar_AllLots = reshape(idx_arr_temp,[],size(idcsBHS_AllVar,2),1);
            GLF_arr_temp = permute(GLF,[1 3 2]);
            GLF_AllLots = reshape(GLF_arr_temp,[],size(GLF,2),1);
            % Set up graphical output array & fill it with target variable
            % values (test variable values: see loop below):
            idcsBHS = idcsBHS_AllVar_AllLots(:,1);
            GLF = GLF_AllLots(:,1);


            ThreshTargetVar = Config.thresh_TargetVar;
            ThreshTestVar = Config.thresh_TestVar;

            VarIds2 = [0 TestVarIds];
            ColIdx_TestVar = 1;
            for VarIdx2 = VarIds2

                if VarIdx2 == 0
                    fprintf(1,"... generating CDF graph for '%s'...\n",...
                        string(TargetVarNameFull));
                    % Define function input for target variable:
                    GLF_TargetVar = GLF(:,1);
                    TitleErrorName = "Absolute Relative Error (ARE)";
                    AxisLabel = 'ARE [%]';
                    ThreshVar_CDF = string(ThreshTargetVar);

                    %% Culminated Distribution Function (CDF) for Target Variable:
                    if any(contains(Config.PlotGraphs,["CDF"]))
                        AAOS_GLUE_PlotGraphicalOutputCDF(Directory, GLF_TargetVar,...
                            TargetVarNameFull, TitleErrorName, AxisLabel,...
                            ThreshVar_CDF, GraphSizes, N_Sim_All, N_Lots);
                    end
                else
                    [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(VarIdx2);
                    fprintf(1,"... generating CDF graph for '%s'...\n",...
                        string(TestVarNameFull));
                    ColIdx_TestVar = ColIdx_TestVar + 1;
                    % Define function input for test variable X:
                    GLF_TestVar = GLF_AllLots(:,ColIdx_TestVar);
                    GLF(:,2) = GLF_TestVar;
                    idcsBHS(:,2) = idcsBHS_AllVar_AllLots(:,ColIdx_TestVar);
                    TitleErrorName = "Normalized Root Mean Square Error (NRMSE)";
                    AxisLabel = 'NRMSE [%]';
                    ThreshVar_CDF = string(ThreshTestVar);

                    %% Culminated Distribution Function (CDF) for Test Variable(s):
                    if any(contains(Config.PlotGraphs,["CDF"]))
                        AAOS_GLUE_PlotGraphicalOutputCDF(Directory, GLF_TestVar,...
                            TestVarNameFull, TitleErrorName, AxisLabel,...
                            ThreshVar_CDF, GraphSizes, N_Sim_All, N_Lots);
                    end

                    %% 4-Quadrant classification of simulations (Q):
                    if any(contains(Config.PlotGraphs,["Q"]))
                        fprintf(1,"... generating Quadrant graph for '%s' & '%s'...\n",...
                            string(TargetVarNameFull),string(TestVarNameFull));
                        AAOS_GLUE_PlotAndWriteGraphicalOutputQuadrants...
                            (Directory, GraphSizes, colors,TargetVarNameFull, TargetVarNameShort,...
                            TestVarNameFull, TestVarNameShort, ThreshTargetVar, ThreshTestVar,...
                            idcsBHS ,GLF, N_Lots, N_Sim)
                    end

                end

            end

            %% Violin plot of parameter values (V):
            if any(contains(Config.PlotGraphs,["V"]))

            end
        end


        % % customize the plot:
        % X_Labels = {'Sm','beta','alfa','Rs','Rf'} ;
        % figure
        % scatter_plots(X,Y,[],'RMSE',X_Labels)
        % % Highlight 'behavioural parameterizations' in different colour:
        % figure
        % scatter_plots(X,Y,[],'RMSE',X_Labels,idx)
        %
        % % Parallel coordinate plots:
        % parcoor(X,X_Labels,[],idx);


    case {"DEF", "CAL"}
        % Delete all rows that only contain either zero or NaN values:
        ModelEval = AnalysisOut.ModelEvaluation(:,2:end);
        [rows,cols] = find(all(or(isnan(ModelEval),ModelEval==0),2));
        AnalysisOut.ModelEvaluation(rows,:,:,:) = [];
        AnalysisOut.SimulationOutput(rows,:,:,:) = [];

        % Calculate GoFs for all-plot timeseries, if >1 lots are tested:
        if numel(Config.SimulationLots) > 1
            AnalysisOut = AAOS_ModelEval_CalculateGoFsOverall(Config,AnalysisOut);
        end

        % Write numerical outputs to spreadsheet:
        AAOS_ModelEval_WriteNumericalOutput(Directory,Config,FileName,AnalysisOut);

        %% Plot figures and, in case, write them to the Excel file:
        % For every lot, plot one figure per used test variable CC and SWC, while
        % plotting the results from the 3. test variable (HI) within those figures:
        for idx_TestVar = 1:min(2,max(TestVarIds))
            % Only plot figures for lots with observations for this test variable:
            if not(isempty(AnalysisOut.SimulationOutput(1,1,1,idx_TestVar)))
                %% GRAPHICAL OUTPUT: REVISE
                %         AAOS_ModelEval_PlotFigure(Directory,FileName,...
                %             Config,ModelOut,idx_TestVar);
            end
        end
end

fclose ('all'); % Close open files
if Config.WriteFig == 'Y'; actxserver('Excel.Application').Quit; end
