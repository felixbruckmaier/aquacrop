%% Sets a certain parameter in a AOS config txt file to a certain value.
% Since the parameters are just defined by line number, this function
% stores a mapping for all relevant config files (adopted from respective
% AOS files)
%
% Usage:
% AAOS_ReplaceVariableInFile("Config","Directory","Soil","0","Zsoil","2");

function[FileName] = AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
    FileName,OmitTemplate,ParName, ParValue)


if FileName == "InitialWaterContent"
    File = FileName+".csv";
else
    File = FileName+".txt";
end

if FileName == "InitialWaterContent" 
    SkipCell = 1;
    colWidth = 26;
    varnames = {'Depth/Layer';'Value'};
elseif FileName == "Crop"
    SkipCell = 0;
    colWidth = 12;
    % variable in the template are referenced by their file number, so we
    % need to define the variable  order here
    varnames = {'CropType';'PlantMethod';'CalendarType';'SwitchGDD';'PlantingDate';...
        'HarvestDate';'Emergence';'MaxRooting';'Senescence';'Maturity';...
        'HIstart';'Flowering';'YldForm';'GDDmethod';'Tbase';'Tupp';...
        'PolHeatStress';'Tmax_up';'Tmax_lo';'PolColdStress';'Tmin_up';...
        'Tmin_lo';'TrColdStress';'GDD_up';'GDD_lo';'Zmin';'Zmax';...
        'fshape_r';'SxTopQ';'SxBotQ';'SeedSize';'PlantPop';'CCx';'CDC';...
        'CGC';'Kcb';'fage';'WP';'WPy';'fsink';'HI0';'dHI_pre';'a_HI';'b_HI';...
        'dHI0';'Determinant';'exc';'p_up1';'p_up2';'p_up3';'p_up4';...
        'p_lo1';'p_lo2';'p_lo3';'p_lo4';'fshape_w1';'fshape_w2';'fshape_w3';...
        'fshape_w4'};
elseif FileName == "IrrigationManagement"
    SkipCell = 1;
    colWidth = 26;
    varnames = {'IrrMethod';'IrrInterval';'SMT1';'SMT2';'SMT3';'SMT4';...
        'MaxIrr';'AppEff';'NetIrrSMT';'WetSurf'};
elseif FileName == "Soil"
    SkipCell = 3;
    colWidth = 20;
    varnames = {'CalcSHP';'Zsoil';'nComp';'nLayer';'AdjREW';'REW';'CN';'zRes'};
elseif FileName == "SoilHydrology"
    SkipCell = 1;
    colWidth = 20;
    varnames = {'thwp','thfc','ths','ksat','Penetrability'};
else
    fprintf(2,'Could not find template: ' + File + '\n\n');
end



% find the line in which the variable is defined
ParIdx = find(ismember(varnames, ParName));
ParIdx = ParIdx + 1 + SkipCell;

if OmitTemplate == 0
    cd(Directory.AOS_Input + filesep + "templates");
elseif OmitTemplate == 1
    cd(Directory.AOS_Input + filesep + Config.season);
end

if FileName == "SoilHydrology"
    % replace all cells of the column with the given value (assumption: homogeneous soil)
    Header = readlines(File);
    Header = Header(1:2,:);
    DataArr = table2array(readtable(File));
    DataLines = size(DataArr,1);
    DataArr(:,ParIdx) = ParValue;

    DataStr = strings(DataLines,1);
    spaces = [8, 12, 10];
    for idxrow = 1:DataLines
        DataStr(idxrow) = string(DataArr(idxrow,1));
        for idxcol = 2:7
            space = spaces(min(idxcol-1,3));
            DataStr(idxrow) = strcat(DataStr(idxrow),string(blanks(space)),string(DataArr(idxrow,idxcol)));
        end
    end
    FileContent(1:2,1) = Header;
    FileContent(3:DataLines+2,1) = DataStr;
elseif FileName == "InitialWaterContent"
FileContent = readlines(File);

else
    FileContent = readlines(File);
    ParLine = FileContent(ParIdx);
    % value / description are separated by ":" (we want to only update the value
    % & keep the description)
    parts = strsplit(ParLine, ":");
    description = parts(2);
    % replace the value with the given one & update the line
    NewLine = sprintf("%-" + colWidth + "s:%s", ParValue, description);
    FileContent(ParIdx) = NewLine;
end





% open & write the output file
cd(Directory.AOS_Input + filesep + Config.season);
fileID = fopen(File, 'w');
if fileID == -1
    fprintf(2,'AOS parameter file not found: ' + File);
end

fprintf(fileID, "%s\n", FileContent);
fclose(fileID);

cd(Directory.BASE_PATH)

end
