%% Assigns values to each of the soil hydrology parameters (SHP);
% Required for substituting non-user-defined input values when deriving the
% Initial soil water content, and for checking SHP constraints in function
% 'AAOS_CheckSoilHydrologyConstraints.m':
function SHP_Values = AAOS_UpdateSoilHydrologyParameters(ParNames, ParValues)

global AOS_InitialiseStruct

SHP_Names = ["th_wp","th_fc","th_s"];

for idx1 = 1:3
    % Assign values from AOS input files to SHP (only works for homogenous
    % soil layers, therefore the value from the first layer is taken):
    SHP_Values.(SHP_Names(idx1)) = AOS_InitialiseStruct.Parameter.Soil.Layer.(SHP_Names(idx1))(1);
end

% Check which/ if any SHP are defined in AAOS input file:
Rows_All = 1:size(ParNames,1);
[Loc_SHPinParNames,Loc_ParNamesInSHP] = ismember(string(ParNames),SHP_Names);
Rows_ParNamesInSHP = Loc_ParNamesInSHP(Loc_ParNamesInSHP>0)';
Rows_SHPinParNames = Rows_All(Loc_SHPinParNames>0);

% Update all AAOS-defined SHP parameters with respective values:
if ~isempty(Rows_SHPinParNames)
    for idx2 = 1:numel(Rows_SHPinParNames)
        SHP_Values.(SHP_Names(Rows_ParNamesInSHP(idx2))) = ParValues(Rows_SHPinParNames(idx2));
    end
end