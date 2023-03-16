function [GLF_AllSim_AllVarAllLots, idcsBHS_AllVar_AllLots, VarIdsAllLots] =...
    AAOS_GLUE_Graph_SetupNonTimeSeriesCharts...
    (AvailTestVars, AnalysisOut, LotIdx, LotNameFull, N_Sim, ...
    GLF_AllSim_AllVarAllLots, idcsBHS_AllVar_AllLots, VarIdsAllLots)


VarIds(1) = 0;
VarIds(2:size(AvailTestVars,1)+1) = AvailTestVars;
VarIdsAllLots{LotIdx, 1} = VarIds;
ColIdx = 0;

for VarIdx = VarIds
    ColIdx = ColIdx + 1;
    if VarIdx == 0
        GLF_Type = "GLF_TargetVar";
        Idx_Type = "idx_GoodTarget";
        VarNameFull = AnalysisOut.TargetVar.NameFull;
    else
        GLF_Type = "GLF_TestVar";
        Idx_Type = "idx_GoodTest";
        [VarNameFull,~] = AAOS_SwitchTestVariable(VarIdx);
    end

    % Etract lot-specific part from simulation output:
    GLUE_Output = AnalysisOut.(LotNameFull).GLUE_Out;
    %% Retrieve lot-specific analysis results and store them in 1 array:
    % 1) "General Likelihood Function" (GLF) values for target or test variable
    GLF_Current = GLUE_Output.(VarNameFull).(GLF_Type);
    % 2) Indices of simulations with good target variable results:
    idxGoodVar_Current = GLUE_Output.(VarNameFull).(Idx_Type);
    GLF_AllSim_AllVarAllLots(1:N_Sim, ColIdx, LotIdx) = GLF_Current;
    idcsBHS_AllVar_AllLots(1:N_Sim, ColIdx, LotIdx) = idxGoodVar_Current;
end