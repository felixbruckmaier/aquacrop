%% Determines test parameters & their specifications current simulation round:
function Config = AAOS_ReadParameterValues(Config,VarIdx,SimRound)



ParData = Config.ParameterValues.(Config.ParFileType);
TestRound = table2array(ParData(:,7));
Allidx = 1:size(TestRound,1);

if SimRound == 0 % Sensitivity/ Uncertainty Analysis( Morris/ GLUE)
    FixParIdx = TestRound==0;

else % Default Run/ Calibration/ Validation/ Stress Quantification
    % For calibration - see official AquaCrop calibration guideline:
    % SimRound #1: all variables default
    % SimRound #2: if only 1 variable -> calibrated;
    if numel(Config.TestVarIds) > 1 && ismember(SimRound,[2,3])
        AllRows = 1:size(TestRound,1);
        switch SimRound
            % SimRound #2/ >1 variable -> CC calibrated, SWC (& HI) default:
            case 2

                TestParRows = AllRows(TestRound==2 | TestRound==3);

                % SimRound #3 (only for >1 variable): CC & SWC calibrated (, HI default):
            case 3
                TestParRows = AllRows(TestRound==3);
        end
        ParData(TestParRows,8:end) = Config.ParameterValues.DEF(TestParRows,8:end);
    end
    % SimRound #4 (only for 3 variables): all variables calibrated = SimRound #1

    Header = string(ParData.Properties.VariableNames);
    AllColumns = 1:size(Header,2);
    LotColumn = AllColumns(Header=="Lot"+Config.LotName);

    % only parameters defined for specific round (i.e. either CC- or
    % SWC-related):
    FixParIdx = (TestRound~=VarIdx);
end


TestParIdx = Allidx(FixParIdx==0);


Config.AllParameterNames = table2array(ParData(TestParIdx,1));
Config.AllParameterAOSfile = table2array(ParData(TestParIdx,2));
Config.AllParameterUnits = table2array(ParData(TestParIdx,3));
Config.AllParameterLowLim = table2array(ParData(TestParIdx,4));
Config.AllParameterUppLim = table2array(ParData(TestParIdx,5));
Config.AllParameterDecimals = -log10(table2array(ParData(TestParIdx,6)));

if SimRound == 0 % Sensitivity/ Uncertainty Analysis( Morris/ GLUE):
% Temporarily assign dummy values, will be replaced during sampling:
    Config.AllParameterValues = Config.AllParameterLowLim;
else
% only parameters to be tested on current lot:
Config.AllParameterValues = table2array(ParData(TestParIdx,LotColumn));
end


%% Store tested crop parameter values and units:
Config = AAOS_SeparateCropParameters(Config);