function [] = AAOS_EE_WriteNumericalOutput(Config, Directory, FileName, SA_Output, LotNames, LotIdx)



% Assign parameter file name as sheet name
LotName = LotNames(LotIdx);
LotNameFull = "Lot" + LotName;
% SheetName = strcat(LotNameFull + "_Num");

% Get parameter input file content:
% Header (1. row):
ColumnTitles(1) = "Season"+Config.season+"/ "+LotNameFull+" / "+Config.TargetVar.NameFull+" --- Parameters:";
ColumnTitles(2:1+size(Config.SampledParNames,1)) = SA_Output.(LotNameFull).ParameterNames';
cell_ColumnTitles = cellstr(ColumnTitles);
% Row titles (3. row - end):
RowTitles = SA_Output.(LotNameFull).RowTitles;
cell_RowTitles = cellstr(RowTitles);
% Data (numerical):
NumericValues = SA_Output.(LotNameFull).Values;

% Write data to Excel file:
cd(Directory.AAOS_Output);
writematrix(NumericValues,...
    char(FileName),'Sheet',LotNameFull,'Range','B3');
writecell(cell_RowTitles,...
    char(FileName),'Sheet',LotNameFull,'Range','A3');
writecell(cell_ColumnTitles,...
    char(FileName),'Sheet',LotNameFull,'Range','A1');
cd(Directory.BASE_PATH);