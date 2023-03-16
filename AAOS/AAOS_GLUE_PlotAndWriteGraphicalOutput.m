function [] = AAOS_GLUE_PlotAndWriteGraphicalOutput(Config, Directory, ...
    AnalysisOut)


% Determine thresholds defined for target and test variable model errors:
ThreshTargetVar = Config.thresh_TargetVar; ThreshTestVar = Config.thresh_TestVar;


PlotGraphs = Config.PlotGraphs;
Heatmaps = Config.GLUE_ChartNames.Heatmaps;
Boxcharts = Config.GLUE_ChartNames.Boxcharts;

PlotBCandHM = ismember([Boxcharts, Heatmaps],...
    Config.PlotGraphs);



%% I) (A+B) Get simulation output required for all graphical plots

% I.1) (A+B) Get general (= valid for all lots) simulation characteristics:
[FileName, GraphColors, GraphSizes, VarIds_User, N_Var_User,...
    TargetVarNameFull, TargetVarNameShort] =...
    AAOS_GLUE_GetSimulationSettingsForOutput(Config, Directory);

[N_Lots,~] = AAOS_GetLotNumberAndName(Config, 0);

fns = fieldnames(AnalysisOut);
N_AllSim_AllLots = (size(AnalysisOut.(string(fns(2))).Values,1) - 5) * N_Lots;
% sloppy - explicitely define number of simulations somewhere

VarIdsAllLots = {};
% Simulated generalized likelihood function output values for every simulation:
GLF_AllSim_AllVarAllLots = [];
% Indices of behavioural simulations of all lots:
idcsBHS_AllVar_AllLots = [];

for LotIdx = 1:N_Lots
    % Determine lot name & extract lot-specific part from simulation output:
    [~,LotNameFull] = AAOS_GetLotNumberAndName(Config, LotIdx);
    LotAnalysisOut = AnalysisOut.(LotNameFull);

    % I.1) (A+B) Get lot-specific simulation outputs:
    [TargetVarObs, TargetVarSim, HarvestDays, AvailTestVars, ...
        N_TestVars, N_AllSim, N_Sim_txt] =...
        AAOS_GLUE_GetLotSpecificSimulationOutput(LotAnalysisOut, TargetVarNameFull);


    %% II) (A) Plot time-series graphs:

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

        %             PlotTS_GraphsTypes = contains(PlotGraphs,["TS","PL"]);
        %             for idxTS_GraphType = 1:size(PlotTS_GraphsTypes,2)
        %                 if PlotTS_GraphsTypes(idxTS_GraphType) ~= 0
        %                     GraphType = PlotGraphs(idxTS_GraphType);


        if any(contains(PlotGraphs, ["TS"]))
            fprintf(1,"... generating time-series graph for '%s' (#%s/%s)"+...
                " & variable '%s' (#%s/%s)...\n",...
                LotNameFull,string(LotIdx),string(N_Lots),...
                string(TestVarNameFull),string(TestVarIdx),string(N_TestVars));

            % x axis left: Time (unit = days):
            xlabel_text = 'Day After Sowing';

            AAOS_GLUE_Graph_PlotTimeSeries...
                (LotAnalysisOut, LotNameFull, GraphSizes, GraphColors, ...
                TargetVarNameFull,TargetVarNameShort, HarvestDays, TargetVarObs,...
                TargetVarSim, TestVarNameFull, TestVarNameShort, TestVarDays,...
                TestVarSim, TestVarObs,xlabel_text, N_Sim_txt)

            % Location in Excel file:
            GraphColumn = 'A';
            GraphSheet = "TimeSeries";
            if Config.WriteFig == 'Y'
                AAOS_GLUE_Graph_WriteTimeSeriesPredictionLimits...
                    (Config, Directory, FileName, LotIdx, GraphSheet, GraphColumn, N_Sim_txt);
                cd(Directory.BASE_PATH);
            end
            hold off;

        end
        if any(contains(PlotGraphs, ["PL"]))
            fprintf(1,"... generating prediction-limits graph for '%s' (#%s/%s)"+...
                " & variable '%s' (#%s/%s)...\n",...
                LotNameFull,string(LotIdx),string(N_Lots),...
                string(TestVarNameFull),string(TestVarIdx),string(N_TestVars));

            % x axis left: Time (unit = days):
            xlabel_text = 'Day After Sowing';

            AAOS_GLUE_Graph_PlotPredictionLimits...
                (LotAnalysisOut,LotNameFull, GraphSizes, GraphColors, TargetVarNameFull,TargetVarNameShort,...
                TestVarNameFull,TestVarNameShort,HarvestDays,TestVarDays,TestVarObs,xlabel_text, N_Sim_txt)

            % Location in Excel file:
            GraphColumn = 'M';
            GraphSheet = "PredictionLimits";
            if Config.WriteFig == 'Y'
                AAOS_GLUE_Graph_WriteTimeSeriesPredLimits...
                    (Config, Directory, FileName, LotIdx, GraphSheet, GraphColumn);
                cd(Directory.BASE_PATH);
            end
            hold off;

        end

    end

    % III) (B) Merge lot-specific model performance (= Generalized Likelihood
    % Function" / GLF & indices of "Behavioural Simulations" / BHS) into
    % one single array:
    if any(contains(PlotGraphs, Config.GLUE_ChartNames.NonTimeSeriesCharts))
        [GLF_AllSim_AllVarAllLots, idcsBHS_AllVar_AllLots, VarIdsAllLots] =...
            AAOS_GLUE_Graph_SetupNonTimeSeriesCharts...
            (AvailTestVars, AnalysisOut, LotIdx, LotNameFull, N_AllSim, ...
            GLF_AllSim_AllVarAllLots, idcsBHS_AllVar_AllLots, VarIdsAllLots);
    end
end
%     end
% end

%% Plot Culminated Distribution Function (CDF) for Variable(s):
if any(contains(PlotGraphs,["CDF"]))
    AAOS_GLUE_Graph_SetupAndPlotCDF(VarIds_User, GLF_AllSim_AllVarAllLots, ...
        TargetVarNameFull, Directory, PlotGraphs, GraphSizes, ...
        N_AllSim_AllLots, N_Lots, ThreshTargetVar, ThreshTestVar)
end
%% Plot 4-Quadrant classification of simulations (Q):
if any(contains(PlotGraphs,["Q"]))
    if size(VarIds_User,2) < 2
        fprintf(1,"... only evaluation of 1 variable possible - 4-Quadrant graph requires at least 2 variables...");
    else
        AAOS_GLUE_Graph_PlotAndWriteQuadrants...
            (Directory, GraphSizes, GraphColors,TargetVarNameFull, TargetVarNameShort,...
            ThreshTargetVar, ThreshTestVar,...
            VarIds_User, idcsBHS_AllVar_AllLots ,GLF_AllSim_AllVarAllLots, N_Lots, N_AllSim)
    end
end


%% Plot all parameter-visualizing GLUE-related graphs:
if any(contains(PlotGraphs,...
        [Boxcharts, Heatmaps]))

    AAOS_GLUE_Graph_SetupAndPlotParameterCharts(...
        AnalysisOut, Config, N_Lots, N_Var_User, N_AllSim, idcsBHS_AllVar_AllLots,...
    GLF_AllSim_AllVarAllLots, TargetVarNameFull, TargetVarNameShort, PlotGraphs, PlotBCandHM);


end

end
