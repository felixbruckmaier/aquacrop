%% Writes all user-specified parameter input values in AOS input files:
function [] =...
    AAOS_WriteAOSinputFiles(Directory,Config,VarNames,VarValues,FileNamesNew)

% FileNameOld = strings(1);
SimPeriodFirst = 0;
FileNamesCheck = strings(3);

for idx_Var = 1:size(VarNames,1)
    VarNameAllFiles = VarNames(idx_Var);

    FileNames = FileNamesNew(idx_Var);

    SimPeriodNamesInput = ["PlantingDate","HarvestDate"];
    if ismember(VarNameAllFiles, SimPeriodNamesInput)
        FileNames = ["Clock","CropRotation","Crop"];
        SimPeriodNamesOutput =...
            ["SimulationStartTime","PlantDate","PlantingDate";...
            "SimulationEndTime","HarvestDate","HarvestDate"];
        formatOut = ["yyyy-mm-dd","dd/mm/yyyy","dd/mm"];

        Idcs = 1:size(SimPeriodNamesInput,2);
        Idx_Par = Idcs(SimPeriodNamesInput == VarNameAllFiles);
        VarNameAllFiles = SimPeriodNamesOutput(Idx_Par,:);
    end

    for idx_File = 1:numel(FileNames)
        FileName = FileNames(idx_File);
        VarName = VarNameAllFiles(idx_File);
        VarValue = VarValues(idx_Var);

        if ismember(VarNames(idx_Var), SimPeriodNamesInput)
            Format = formatOut(idx_File);
            VarValue = string(datestr(VarValue,Format));
        else
            VarValue = string(VarValue);
        end

%         if or(FileName == FileNameOld,SimPeriodFirst == 1)
%             OmitTemplate = 1;
%         else
%             OmitTemplate = 0;
%         end
%         [FileNameOld] = 
        AAOS_OverwriteVariableInAOSfile(Config, Directory, ...
            FileName, VarName, VarValue);

        if ismember(VarName, SimPeriodNamesInput)
            if SimPeriodFirst == 0
                FileNamesCheck(idx_File) = FileName;
            end
            if FileNamesCheck == FileNames
                SimPeriodFirst = 1;
            end
        end
    end
end
