%% Substitutes missing parameter values in the input file with the mean of all plots.
function Config = AAOS_SubstituteMissingParameters(FileIdx,Config)

ParFileTitles = fieldnames(Config.ParameterValues);
ParValues = Config.ParameterValues.(ParFileTitles{FileIdx});
LastRow = size(ParValues,1);
Decimals = zeros(LastRow,1);

% % Analysis option "Validation":
% if not(isempty(Config.ValidationLots(:,1)))
%     % assign -999 values at plots chosen for validation:
%     for idx = (Config.ValidationLots(:,1))
%     % assign -999 values at plots chosen for validation:
%     ParValues(:,7+idx) = array2table(-999);
%     end
% end

for row = 1:LastRow
    Decimals(row,:) = -log10(table2array(ParValues(row,6)));
    ParValuesRaw = table2array(ParValues(row,8:end));
    par_allplots_mean = round(mean(ParValuesRaw(ParValuesRaw>-999)),...
        Decimals(row,1));
    ParValuesRaw(ParValuesRaw<=-999) = par_allplots_mean;
    ParValues(row,8:end) = array2table(ParValuesRaw);
end

Config.ParameterValues.(ParFileTitles{FileIdx}) = ParValues;