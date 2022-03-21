%% Determines parameters & their values to analyze for current simulation
% round:
function Config = AAOS_ReadParameterValues(Config,VarIdx)

ParData = Config.ParameterValues.(char(Config.RUN_type));
ParTestSet = table2array(ParData(:,7));



% all parameters except the ones explicitely excluded
% (= negative index in par input file):
if VarIdx == 0 
    FixParAllLots = ParTestSet==0;

% only parameters defined for specific round (i.e. either CC- or
% SWC-related):
elseif VarIdx > 0
    FixParAllLots = ParTestSet~=VarIdx;

end



column_lot = find(string(ParData.Properties.VariableNames) == "Lot"+Config.LotName);
AllValues = zeros(Config.AllParameterNumber,1);
Decimals = zeros(Config.AllParameterNumber,1);

for idx_allpar = 1:Config.AllParameterNumber
    Decimals(idx_allpar,:) = -log10(table2array(ParData(idx_allpar,6)));
    val_i = table2array(ParData(idx_allpar,column_lot));
    if val_i > -999
        AllValues(idx_allpar) = val_i;
        % if no value for this parameter on this Lot -> calculate the mean
    elseif val_i <= -999 
        val_j = table2array(ParData(idx_allpar,8:end));
        val_j(val_j<=-999)=[];
        AllValues(idx_allpar) = round(mean(val_j),Decimals(idx_allpar,:));
    end
end

ParData(:,column_lot) = array2table(AllValues);

Config.AllParameterValues = AllValues;
Config.AllParameterDec = Decimals;


FixParsCurrentLot = table2array(ParData(:,column_lot))<=-999;
FixParAll = FixParAllLots + FixParsCurrentLot;
FixParAll(FixParAll == 2) = 1;
Config.FixvsTestParameter = FixParAll;
Config.TestParameterIdx = find(FixParAll==0);

Config.FixParNames = Config.AllParameterNames(Config.FixvsTestParameter==1);
% only parameters to be tested on current lot:
Config.TestParameterNames = Config.AllParameterNames(Config.FixvsTestParameter==0);
Config.TestParameterAOSFile = table2array(ParData(FixParAll==0,2));
Config.TestParameterLowLim = table2array(ParData(FixParAll==0,4));
Config.TestParameterUppLim = table2array(ParData(FixParAll==0,5));
Config.TestParameterValue = Config.AllParameterValues(Config.TestParameterIdx);
%Config.TestParameterNumber = size(Config.TestParameterNames,1);


