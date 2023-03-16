function [] = AAOS_GLUE_Graph_SetHeatmapXaxis(ParName, ParDec,HeatmapParTicks)


xt = get(gca, 'XTick');
N_Ticks = size(xt, 2);
% Exclude last tick = on the right to keep the same chart size for all
% stacked plots
N_Labels = N_Ticks - 1;
xlbl = strcat(ParName, '\newline', 'input values');
xtlbl = round(HeatmapParTicks,ParDec);
% If parameter with logarithmic scale -> rewrite as, e.g., "1.234 x 10²"
if (xtlbl(3) - xtlbl(2)) ~= (xtlbl(2) - xtlbl(1))
    xtlbl_temp = strings(1,N_Labels);
    for idx = 1:N_Labels
        x = abs(xtlbl(idx));
        b = floor(log10(x));
        a = x/(10^b);
        xtlbl_temp(idx) = strcat(string(a),' x10^{',string(b),'}');
    end
    xtlbl = xtlbl_temp;
end
% Set x axis ticks & labels
set(gca, 'XTick',xt(1:N_Labels), 'XTickLabel',xtlbl(1:N_Labels),...
    'XTickLabelRotation',0);
xlabel(xlbl);


hold off;

