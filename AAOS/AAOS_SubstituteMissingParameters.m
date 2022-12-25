%% Substitutes lots with missing parameter values in the input file with the
% mean of all plots that show a value for the respective parameter.
function Config = AAOS_SubstituteMissingParameters(FileIdx,Config)

% Set up arrays for currently active parameter input file:
Filename = fieldnames(Config.ParameterValues); % get filename
NumValues = Config.ParameterValues.(Filename{FileIdx}); % get parameter values
N_Par = size(NumValues,1); % get number of parameters

% % Analysis option "VAL":
% if not(isempty(Config.ValidationLots(:,1)))
%     % assign -999 values at plots chosen for validation:
%     for idx = (Config.ValidationLots(:,1))
%     % assign -999 values at plots chosen for validation:
%     ParValues(:,7+idx) = array2table(-999);
%     end
% end

% Get the maximum allowed decimals of the parameter:
DecimalsAll = -log10(table2array(NumValues(:,6)));
% Get the parameter value of every lot:
ValuesAll = table2array(NumValues(:,8:end));
% Get the unit for every lot:
Units = table2array(NumValues(:,3));
Config.AllParameterUnits = Units;

% Derive the mean value for every parameter & substitute all missing values
for row = 1:N_Par
    Decimals = DecimalsAll(row);
    Values = ValuesAll(row,:);
    Unit = Units(row);

    % Planting/Harvest Dates: Temporarily convert to serial format for
    % calculating the mean for all missing values (=-999)
    if ~ismember(Unit, ["CD","GDD","NR"])
        AvailDatesArray = Values(Values>-999);
        AvailDatesString = string(AvailDatesArray);
        Format = string(Unit);
        AvailDatesSerial = datenum(AvailDatesString,Format);
        Values(Values>-999) = AvailDatesSerial;
    end
    % Get the mean of all valid values for this parameter &...
    % ... round it to the resp. number of decimals:
    ParMean = round(mean(Values(Values>-999)),...
        Decimals);
    % Assign the derived mean to all lots w/o a value for this parameter:
    Values(Values<=-999) = ParMean;
  % Planting/Harvest Dates: Re-convert to input/output date format (above):
    if ~ismember(Unit, ["CD","GDD","NR"])
        Values = str2double(string(datestr(Values,Format)))';
        % Store date format for usage in 'AAOS_ReadParameterValues.m':
        Config.DateFormat = Format;
    end

    % Reintregate the finished parameter row in the overall table:
    NumValues(row,8:end) = array2table(Values);
end

% Store the cleaned table in the respective parameter values struct:
Config.ParameterValues.(Filename{FileIdx}) = NumValues;