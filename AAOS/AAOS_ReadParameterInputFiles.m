%% Reads user-specified parameter values from .csv input files.
% Type and number of input files depends on chosen type of analysis.
function Config = AAOS_ReadParameterInputFiles(Config,Directory)

% Determine number of input files to read
if Config.RUN_type == "CAL"
    FileNum = 2;
else
    FileNum = 1;
end

% Read the content of all parameter input files:
for FileIdx = 1:FileNum
    if FileIdx == 1

        % Determine type of input file(s) to read
        switch Config.RUN_type

            % Default analysis/ calibration (1. round) use default values:
            case {"DEF","CAL"}
                ParFileType = "DEF";

                % Stress quantification/ sensitivity analysis use calibrated
                % values:
            case {"STQ","GSA"}
                ParFileType = "CAL";
        end

    elseif FileIdx == 2
        % Calibration (2. round) uses calibrated values:
        ParFileType = "CAL";
    end

    % Find the file in the correct directory:
    cd(Directory.AAOS_Input);
    ParFileDir = dir(fullfile(Directory.AAOS_Input,...
        '*InputPars*'+Config.season+'*'+ParFileType+'.csv'));

    % Store file content:
    Config.ParameterFileNames(FileIdx,1) = ParFileType;
    Config.ParameterValues.(ParFileType)...
        = readtable(ParFileDir.name,'ReadVariableNames',true);

end
end