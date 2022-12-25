%% Plot culminate Dsitribution Functions (CDF) for designated variable:
function [] = AAOS_GLUE_PlotGraphicalOutputCDF(Directory, GLF_Values,...
    VariableName, TitleErrorName, AxisLabel,...
    ErrorThreshold, ChartSizes, N_Sim_All, N_Lots)
cd(Directory.SAFE_util);
if ~all(GLF_Values==0)
    figure;
    plot_cdf(GLF_Values, AxisLabel);
    title('Cumulative Distribution Function (CDF) of '+VariableName+'-evaluated simulations (N)','FontSize',ChartSizes(1));
    subtitle(N_Lots+" Lot(s) | N = "+N_Sim_All+" | evaluating via "+TitleErrorName,'FontSize',ChartSizes(2));
    xline(15,'--r',{'Threshold = '+ErrorThreshold},'Linewidth',ChartSizes(4),'FontSize',ChartSizes(3)-2);
    set(gca,'FontSize',ChartSizes(3));
    grid on;
    xlim([0,max(GLF_Values)]);
end
cd(Directory.BASE_PATH);