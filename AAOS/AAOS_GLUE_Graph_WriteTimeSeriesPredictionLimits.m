function [] = AAOS_GLUE_Graph_WriteTimeSeriesPredictionLimits...
    (Config, Directory, FileName, LotIdx, ChartSheet, ChartColumn)

cd(Directory.vendor);
% Initialize Excel:
Excel = actxserver('Excel.Application');
% Suppress Excel warning popups, e.g. when overwriting a file:
Excel.DisplayAlerts = false;
% Adjust figure dimensions (acc. to number of parameters N_Pars,
% but min = 13: spreadsheet-cell-dependent)
fig_height = Config.OutputSheet.CellHeight * max(13,N_Pars + 8); % cells * cell height
fig_width = Config.OutputSheet.CellWidth * 10; % cells * cell width
fig_row = string(ceil((LotIdx - 1) * (2 *fig_height - 1)) + 1);
fig_loc = append(ChartColumn, fig_row);
% Determine figure size & position in file:
set(gcf, 'units','centimeters','position',...
    [0,0,fig_width,fig_height])
% Write figure to file:
xlswritefig(gcf,FileName,ChartSheet,fig_loc);
% Clear the figure for the next graph (otherwise Matlab keeps
% plotting all graphs into the same figure):
clf(gcf);
cd(Directory.BASE_PATH);