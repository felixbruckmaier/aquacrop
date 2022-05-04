%% Sets a certain parameter in a AOS config txt file to a certain value.
% Since the parameters are just defined by line number, this function
% stores a mapping for all relevant config files (adopted from respective
% AOS files)
%
% Usage:
% AAOS_ReplaceVariableInFile("Config","Directory","Soil","0","Zsoil","2");

%[Filename] =
function [] = AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
    Filename,VarName,VarValue)

global AOS_InitialiseStruct

if Filename == "FileLocations"
    varnames = [1,2];
    SkipCell = VarName - 1;
elseif Filename == "Clock"
    SkipCell = 0;
    colWidth = 16;
    varnames ={'SimulationStartTime';'SimulationEndTime';'OffSeason'};
elseif Filename == "CropRotation"
    varnames = {'PlantDate';'HarvestDate'};
elseif Filename == "IrrigationSchedule"
    SkipCell = 1;
    colWidth = 12;
    varnames = {'Day';'Month';'Year';'Irrigation'};
elseif Filename == "InitialWaterContent"
    varnames = string(Config.SimulatedSWCdepths);
    SkipCell = 4;
    colWidth = 17;
elseif Filename == "Crop"
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
elseif Filename == "IrrigationManagement"
    SkipCell = 1;
    colWidth = 26;
    varnames = {'IrrMethod';'IrrInterval';'SMT1';'SMT2';'SMT3';'SMT4';...
        'MaxIrr';'AppEff';'NetIrrSMT';'WetSurf'};
elseif Filename == "Soil"
    SkipCell = 3;
    colWidth = 20;
    varnames = {'CalcSHP';'Zsoil';'nComp';'nLayer';'AdjREW';'REW';'CN';'zRes'};
elseif Filename == "SoilHydrology"
    SkipCell = 1;
    colWidth = 20;
    varnames = {'th_s','th_fc','th_wp','Ksat','Penetrability'};
else
    fprintf(2,'Could not find template: ' + Filename + '\n\n');
end

if ismember(Filename,["FileLocations","IrrigationSchedule","CropRotation",...
        "InitialWaterContent","Crop"])
    % Filename not specified in AOS_InitialiseStruct
    File = strcat(Filename,".txt");
elseif Filename == "IrrigationManagement"
    CropName = string(AOS_InitialiseStruct.CropChoices);
    File = AOS_InitialiseStruct.Parameter.Crop.(CropName).IrrigationFile;
elseif Filename == "FieldManagement"
    CropName = string(AOS_InitialiseStruct.CropChoices);
    File = AOS_InitialiseStruct.Parameter.Crop.(CropName).FieldMngtFile;
else
    File = AOS_InitialiseStruct.FileLocation.(Filename+"Filename");
end

% find the line in which the variable is defined
VarIdx = find(ismember(varnames, VarName));
if Filename ~= "CropRotation"
    VarIdx = VarIdx + 1 + SkipCell;
end



if Filename == "FileLocations"
    cd(Directory.AOS);
    FileContent = readlines(File);
    VarValue = char(VarValue);
    VarValue(VarValue=='\') = '/';
    VarValue = string(VarValue);
    FileContent(VarIdx) = VarValue;
else
    %     if OmitTemplate == 0
    %         cd(Directory.AOS_Input + filesep + Config.season + filesep + "templates");
    %     elseif OmitTemplate == 1
    cd(Directory.AOS_Input + filesep + Config.season);
    %     end


    if ismember(Filename,["CropRotation";"SoilHydrology";"IrrigationSchedule"])
        % replace all cells of the column with the same value (assumption: homogeneous soil)
        Data = readlines(File);
        Header = Data(1:2,:);

        if Filename == "CropRotation"
            DataArr(1,:) = split(Data(3,:));
        else
            DataArr = table2array(readtable(File));
        end
        DataLines = size(DataArr,1);



        if Filename == "SoilHydrology"
            DataArr(:,VarIdx) = VarValue;
            N_col = 7;
            spaces = [8, 12, 10];

        elseif Filename == "IrrigationSchedule"
            DataArr = VarValue;
            N_col = 4;
            spaces = [5, 5, 6];
        elseif Filename == "CropRotation"
            DataArr(1,VarIdx) = VarValue;
            N_col = 3;
            spaces = [7, 7, 7];
        end

        DataStr = strings(DataLines,1);

        for idxrow = 1:DataLines
            DataStr(idxrow) = string(DataArr(idxrow,1));
            for idxcol = 2:N_col
                space = spaces(min(idxcol-1,3));
                % build up rows in .txt file:
                DataStr(idxrow) = strcat(DataStr(idxrow),string(blanks(space)),string(DataArr(idxrow,idxcol)));
            end
        end
        FileContent(1:2,1) = Header;
        FileContent(3:DataLines+2,1) = DataStr;
    else
        FileContent = readlines(File);
        VarLine = FileContent(VarIdx);
        if Filename == "InitialWaterContent" % update either column:
            delimiter = " ";
            leftcol = VarName;
            rightcol = VarValue;
        else
            leftcol = VarValue;
            delimiter = ":";
        end
        parts = strsplit(VarLine, delimiter);

        if Filename ~= "InitialWaterContent" % only update left column (value) & keep the right one (description)
            rightcol = parts(2);
        end

        % replace the value with the given one & update the line:
        NewLine = sprintf("%-" + colWidth + "s"+delimiter+"%s", leftcol, rightcol);
        FileContent(VarIdx) = NewLine;
    end
    cd(Directory.AOS_Input + filesep + Config.season);
end




% open & write the output file

fileID = fopen(File, 'w');
if fileID == -1
    fprintf(2,'AOS parameter file not found: ' + File);
end

fprintf(fileID, "%s\n", FileContent);
fclose(fileID);

cd(Directory.BASE_PATH)

end
