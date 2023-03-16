function [] = AAOS_GLUE_Graph_PlotBoxchart(...
    BC_Values, BC_Title, BC_SubTitle, BC_XLabels, BC_Ylabel, LogScale)

figure;
bc = boxchart(BC_Values);
hold on
for IdxValuePoints = 1:size(BC_Values,2)
    b = ones(size(BC_Values,1),1);
    bc = scatter(b + IdxValuePoints-1,BC_Values(:,IdxValuePoints),...
        "filled",'jitter','on','JitterAmount',0.1);
    bc.MarkerFaceAlpha = 0.2;
end
title(BC_Title, 'FontSize', 13);
subtitle(BC_SubTitle, 'FontSize', 12);
set(gca,"XTickLabel",BC_XLabels, 'FontSize', 11);
ylabel(BC_Ylabel, 'FontSize', 11);
if LogScale == 1
    set(gca, 'YScale', 'log');
end
hold off;
