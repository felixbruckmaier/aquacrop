function [HeatmapValues, HeatmapParTicks] = ...
    AAOS_GLUE_Graph_DeriveHeatmapValues(ParValues, GLF, LogScale)

GLF(GLF>=100) = nan;

ParMin = min(ParValues);
ParMax = max(ParValues);

if LogScale == 0
    ParStep = (ParMax - ParMin)/10;
    HeatmapParTicks = ParMin:ParStep:ParMax;
elseif LogScale == 1
    ParMin_exp = log(ParMin) /  log(10);
    ParMax_exp = log(ParMax) /  log(10);
    HeatmapParTicks = logspace(ParMin_exp,ParMax_exp,11);
end
HeatmapValues = hist3([GLF ParValues],'Ctrs',{0:10:100 HeatmapParTicks});
HeatmapValues(HeatmapValues==0) = nan;