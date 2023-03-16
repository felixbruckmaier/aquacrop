function [] =  AAOS_GLUE_Graph_SetupAndPlotParameterCharts(...
    AnalysisOut, Config, N_Lots, N_Var_User, N_AllSim, idcsBHS_AllVar_AllLots,...
    GLF_AllSim_AllVarAllLots, TargetVarNameFull, TargetVarNameShort, PlotGraphs, PlotBCandHM)

[N_Par, ParNamesAnalyzed_OutputFormat, LotNames, N_Combi, ...
    ParValues_AllParAllCombisAllLots, ...
    GLF_AllParAllCombisAllLots]...
    = AAOS_GLUE_PrepareGraphicalOutputBoxchartHeatmap(...
    AnalysisOut, N_Lots, N_AllSim, idcsBHS_AllVar_AllLots, Config, ...
    TargetVarNameShort, N_Var_User, GLF_AllSim_AllVarAllLots);

Config = AAOS_ReadParameterValues(Config,1,0);
LogScalePars = Config.LogScalePars;

ParNamesAnalyzed_InputFormat0 = strrep(ParNamesAnalyzed_OutputFormat, "-", "_");
ParNamesAnalyzed_InputFormat = strrep(ParNamesAnalyzed_InputFormat0, "HIo", "HI0");
LocParsToPlot = ismember(ParNamesAnalyzed_InputFormat,Config.ParametersToPlot)';
IdcsParsAll = 1:N_Par;
IdcsParsToPlot = IdcsParsAll(LocParsToPlot);



StackHeatmaps = Config.StackHeatmaps;


% Determine whether to plot both boxcharts (BC) and heatmaps (HM)
% -> run the following loop twice, once with parameter values (BC),
% once with GLF values (HM).

PlotTypesAll = ["BC", "HM_All", "HM_Lots"];
PlotTypesActive = [max(PlotBCandHM(1:2)), PlotBCandHM(3:4)];

for PlotType = PlotTypesAll(PlotTypesActive)




countPar = 0;

    for IdxPar = IdcsParsToPlot
countPar = countPar + 1;

        ParName_InputFormat = ParNamesAnalyzed_InputFormat(IdxPar);
        ParName_OutputFormat = ParNamesAnalyzed_OutputFormat(IdxPar);
        ParValues_AllSim_AllParAllLots =...
            ParValues_AllParAllCombisAllLots.AllSimulations(:,IdxPar);
        BC_Ylabel = strcat(ParName_OutputFormat, " input values");



        % Find Parameter in all-parameter array (which includes
        % parameters that haven't been sampled & analyzed, e.g. CDC),
        % to get the correct decimals:
        IdxParAll = ismember(Config.AllParameterNames,ParName_InputFormat);
        ParDec = Config.AllParameterDecimals(IdxParAll);

        if PlotType == "BC" % Boxcharts / Behavioural parameter value distribution
            Values_AllParAllCombisAllLots = ParValues_AllParAllCombisAllLots;
        elseif any(contains(PlotType,["HM_Lots", "HM_All"])) % Heatmaps / GLF value distribution
            Values_AllParAllCombisAllLots = GLF_AllParAllCombisAllLots;
            IdxPar = 1;
        end




        if ismember(ParName_InputFormat, LogScalePars)
            LogScale = 1;
        else
            LogScale = 0;
        end

        %% Extract simulated values for current parameter:
        CombiValues_OnePar = nan(N_AllSim, N_Combi, N_Lots);
        for IdxLot2 = 1:N_Lots
            Values_OneLot = Values_AllParAllCombisAllLots.(LotNames(IdxLot2));
            VarCombiNamesShortAll_FieldNames = fieldnames(Values_OneLot);
            for IdxCombi = 1 : N_Combi
                Values_OneParOneLot = Values_OneLot.(string(VarCombiNamesShortAll_FieldNames(IdxCombi)))(:,IdxPar);
                CombiValues_OnePar(1:size(Values_OneParOneLot,1),IdxCombi,IdxLot2) = Values_OneParOneLot;
            end

        end
        CombiValues_OnePar(CombiValues_OnePar == -999) = nan;

        VarCombiNamesShortAll_ChartNames = replace(VarCombiNamesShortAll_FieldNames,...
            "_"," ");
        VarCombiNamesFullAll_adj1 = replace(VarCombiNamesShortAll_ChartNames,...
            TargetVarNameShort,TargetVarNameFull);
        VarCombiNamesFullAll_adj2 = replace(VarCombiNamesFullAll_adj1,...
            "CC","CanopyCover");
        VarCombiNamesFullAll_ChartNames = replace(VarCombiNamesFullAll_adj2,...
            "SWC","SoilWaterContent");
        %%%


        CombiNamesForTitle_Full = replace(...
            VarCombiNamesFullAll_ChartNames(end), " ", " and/or ");
        CombiNamesForTitle_Short = replace(...
            VarCombiNamesShortAll_ChartNames(end), " ", " and/or ");

        CombiNamesForTitle = strcat("for: ", CombiNamesForTitle_Full, ' (',...
            CombiNamesForTitle_Short,')');


        Values_DiffByCombi = [];
        XTickLabels_All = ["All"];


        BC_Title = strcat(...
            "Behavioural Parameter Value Distribution of ",ParName_OutputFormat);



        for IdxCombi2 = 1 : N_Combi

            XTickLabels_BC_DiffByLots = [XTickLabels_All, LotNames];
            VarCombiNamesShortCurrent = VarCombiNamesShortAll_ChartNames(IdxCombi2);


            if PlotType == "BC" & any(contains(PlotGraphs,["BC_Lots"]))
                Values_BC_DiffByLots = reshape(...
                    CombiValues_OnePar(:, IdxCombi2, :), [N_AllSim, N_Lots]);

                Values_BC_DiffByLots(end+1 : N_AllSim * N_Lots, :) = nan;

                ParValues_All_vs_BHS_DiffByLots = horzcat(...
                    ParValues_AllSim_AllParAllLots,...
                    Values_BC_DiffByLots);

                BC_SubTitle_DiffByLots = strcat("for: ",...
                    replace(VarCombiNamesFullAll_ChartNames(IdxCombi2)," "," and "));
           
                
                fprintf(1,"... generating boxchart graph for parameter '%s' (#%s/%s),"+...
                " & variable combination '%s', differentiating b/w lots...\n",...
                    ParName_InputFormat, string(countPar), ...
                    string(numel(IdcsParsToPlot)), string(CombiNamesForTitle_Full));

                AAOS_GLUE_Graph_PlotBoxchart(...
                    ParValues_All_vs_BHS_DiffByLots, BC_Title,...
                    BC_SubTitle_DiffByLots, XTickLabels_BC_DiffByLots,...
                    BC_Ylabel, LogScale);
                ylabel(BC_Ylabel, 'FontSize', 11);
                hold off;
            end
            if any(contains(PlotType,["HM_Lots", "HM_All"]))
                for LotIdx1 = 1:N_Lots
                    startrow = (LotIdx1 - 1) * N_AllSim + 1;
                    endrow = startrow + N_AllSim - 1;
                    Values_HM_DiffByLots =...
                        CombiValues_OnePar(:, IdxCombi2, LotIdx1);

                    ParValues_AllSim =...
                        ParValues_AllSim_AllParAllLots(startrow:endrow);
                    [HeatmapValues_AllCombisAllLots(:,:,LotIdx1,IdxCombi2),HeatmapParTicks] =...
                        AAOS_GLUE_Graph_DeriveHeatmapValues(...
                        ParValues_AllSim, Values_HM_DiffByLots, LogScale);
                end


            end



        end







        BC_SubTitle_DiffByCombi = strcat("for all lots and: ", CombiNamesForTitle);
        VarCombiNamesShortCurrent = VarCombiNamesShortAll_ChartNames(IdxCombi2);

        if PlotType == "BC" & any(contains(PlotGraphs,["BC_Combi"]))
            %% Differentiate columns by combinations -> merge lots within 1 column
            % -> 1 figure = 1 parameter & all lots

            for IdxLot3 = 1 : N_Lots
                Values_DiffByCombi = vertcat(Values_DiffByCombi,CombiValues_OnePar(:,:,IdxLot3));
            end


            XTickLabels_BC_DiffByCombi = [XTickLabels_All, VarCombiNamesShortAll_ChartNames'];

            ParValues_All_vs_BC_DiffByCombi = horzcat(...
                ParValues_AllSim_AllParAllLots,...
                Values_DiffByCombi);

            fprintf(1,"... generating boxchart graph for parameter '%s' (#%s/%s),"+...
                " differentiating between variable combinations...\n",...
                ParName_InputFormat, string(countPar), string(numel(IdcsParsToPlot)));

            AAOS_GLUE_Graph_PlotBoxchart(...
                ParValues_All_vs_BC_DiffByCombi, BC_Title,BC_SubTitle_DiffByCombi,...
                XTickLabels_BC_DiffByCombi,BC_Ylabel, LogScale);

        end
        if any(contains(PlotType,["HM_Lots", "HM_All"]))

            if PlotType == "HM_Lots"
                addstring = " & lots";
            elseif PlotType == "HM_All"
                addstring = "";
            end

     fprintf(1,"... generating heatmap graph for parameter '%s' (#%s/%s),"+...
                " differentiating between variable combinations%s...\n",...
                ParName_InputFormat, string(countPar), string(numel(IdcsParsToPlot)),...
                addstring);

            AAOS_GLUE_Graph_SetupAndPlotHeatmap(HeatmapValues_AllCombisAllLots,...
                CombiValues_OnePar,ParName_OutputFormat,...
                PlotType,CombiNamesForTitle,LotNames,N_Lots,N_Combi,StackHeatmaps,...
                VarCombiNamesShortAll_ChartNames, ParDec, HeatmapParTicks);
        end
        hold off;


    end
end