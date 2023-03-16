function AAOS_GLUE_Graph_SetupAndPlotCDF(VarIds_User,...
    GLF_AllSim_AllVarAllLots, TargetVarNameFull, Directory,...
    PlotGraphs, GraphSizes, N_AllSim_AllLots, N_Lots, ...
    ThreshTargetVar, ThreshTestVar)

ColIdx_TestVar = 0;

for VarIdx = VarIds_User
    if VarIdx == 0
        fprintf(1,"... generating CDF graph for '%s'...\n",...
            string(TargetVarNameFull));
        % Define function input for target variable:
        GLF_TargetVar = GLF_AllSim_AllVarAllLots(:,1);
        TitleErrorName = "Absolute Relative Error (ARE)";
        AxisLabel = 'ARE [%]';
        ThreshVar_CDF = string(ThreshTargetVar);

        %% Culminated Distribution Function (CDF) for Target Variable:
        if any(contains(PlotGraphs,["CDF"]))
            AAOS_GLUE_Graph_PlotCDF(Directory, GLF_TargetVar,...
                TargetVarNameFull, TitleErrorName, AxisLabel,...
                ThreshVar_CDF, GraphSizes, N_AllSim_AllLots, N_Lots);
        end
    else
        [TestVarNameFull,~] = AAOS_SwitchTestVariable(VarIdx);
        fprintf(1,"... generating CDF graph for '%s'...\n",...
            string(TestVarNameFull));
        ColIdx_TestVar = ColIdx_TestVar + 1;
        % Define function input for test variable X:
        GLF_TestVar = GLF_AllSim_AllVarAllLots(:,ColIdx_TestVar);
        %     GLF(:,2) = GLF_TestVar;
        %     idcsBHS(:,2) = idcsBHS_AllVar_AllLots(:,ColIdx_TestVar);
        TitleErrorName = "Normalized Root Mean Square Error (NRMSE)";
        AxisLabel = 'NRMSE [%]';
        ThreshVar_CDF = string(ThreshTestVar);


        AAOS_GLUE_Graph_PlotCDF(Directory, GLF_TestVar,...
            TestVarNameFull, TitleErrorName, AxisLabel,...
            ThreshVar_CDF, GraphSizes, N_AllSim_AllLots, N_Lots);
    end
end
