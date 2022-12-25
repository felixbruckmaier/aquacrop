%% "GLUE Idx" not working probably (therefore until now: workaround by
% explicitely using the GLUE threshold for beh. simulations here)
function [GLF_AllVar_AllLots, idcsBHS_AllVar_AllLots] =...
    AAOS_GLUE_PrepareGraphicalOutputStatistics...
    (AnalysisOut, LotIdx, LotNameFull, GLF_AllVar_AllLots, idcsBHS_AllVar_AllLots,...
    GLF_Type, Idx_Type, VarNameFull,N_Sims,ColIdx)

GLUE_Output = AnalysisOut.(LotNameFull).GLUE_Out;

AnalysisOut.Lot1.GLUE_Out.Yield  

%% Retrieve lot-specific analysis results and store them in 1 array:
% 1) "General Likelihood Function" (GLF) values for target or test variable
GLF_Current = GLUE_Output.(VarNameFull).(GLF_Type);
% 2) Indices of simulations with good target variable results:
idxGoodVar_Current = GLUE_Output.(VarNameFull).(Idx_Type);


GLF_AllVar_AllLots(1:N_Sims, ColIdx, LotIdx) = GLF_Current;
idcsBHS_AllVar_AllLots(1:N_Sims, ColIdx, LotIdx) = idxGoodVar_Current;