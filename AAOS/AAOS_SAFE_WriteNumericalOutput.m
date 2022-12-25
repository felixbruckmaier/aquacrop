function [] = AAOS_SAFE_WriteNumericalOutput(Config, Directory, FileName, LotAnalysisOut, LotNameFull)

% Get parameter input file content:
% Header (1. row):
ColumnTitles(1) = "Season"+Config.season+"/ "+LotNameFull+" / "+Config.TargetVar.NameFull+" --- Parameters:";
ColumnTitles(2:1+size(LotAnalysisOut.SamplingOut.ColumnTitles,2)) = LotAnalysisOut.SamplingOut.ColumnTitles;
cell_ColumnTitles = cellstr(ColumnTitles);

%% CHANGE!
% Row titles (3. row - end):
RowTitles = LotAnalysisOut.RowTitles;
cell_RowTitles = cellstr(RowTitles);
% Data (numerical):
NumericValues = LotAnalysisOut.Values;

% Write data to Excel file:
cd(Directory.AAOS_Output);
writematrix(NumericValues,...
    char(FileName),'Sheet',LotNameFull,'Range','B3');
writecell(cell_RowTitles,...
    char(FileName),'Sheet',LotNameFull,'Range','A3');
writecell(cell_ColumnTitles,...
    char(FileName),'Sheet',LotNameFull,'Range','A1');
cd(Directory.BASE_PATH);