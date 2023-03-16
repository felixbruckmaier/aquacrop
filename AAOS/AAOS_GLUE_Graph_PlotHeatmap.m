function [] = AAOS_GLUE_Graph_PlotHeatmap(...
    HeatmapValues, ymin, ymax, PlotPosition)
    
    ax1 = axes('position', PlotPosition);

    [nr,nc] = size(HeatmapValues);
    pcolor(ax1,[HeatmapValues nan(nr,1); nan(1,nc+1)]);
    shading flat;

    yt = get(gca, 'YTick');
    ytlbl = round(linspace(ymin, ymax, numel(yt)),0);
    set(gca,'YTick',yt, 'YTickLabel',ytlbl,'YDir','normal');
   

    hold on;

end