function [Config, SA_Output] = AAOS_PerformSAFE(Config, Directory, SA_Output)

% % Get number of test variables
% TestVarIds = Config.TestVarIds;
%
% for VarIdx = TestVarIds
% % Determine test variable:
% [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(VarIdx);
%
%     % For CC & SWC: Retrieve observations:
%     % Assign SWC depth to be tested (set to "1" when analyzing Canopy Cover):
%     % -> column idx
%     if TestVarNameShort == "SWC"
%         idx_Observation = Config.idx_SimDepthsObservations(Config.idx_TestSWC);
%     elseif TestVarNameShort == "CC"
%         idx_Observation = 1;
%     end
%     % Read observed values for given test variable & depth:
%     [ObsTestVar,~] = AAOS_ReadTestVariableObservations(Directory,Config,...
%         TestVarNameShort,idx_Observation);
%
%     % Store test variable observations:
%     Config.TestVariableObservations = ObsTestVar;

if Config.RUN_type == "GLUE"
    % Read & store observations for CC & SWC:
    Config.ObsTestVar = struct;
    TestVarIds = Config.TestVarIds;
    for TestVarIdx = 1:min(2,numel(TestVarIds))
        [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(TestVarIdx);
        [ObsTestVar] = AAOS_ReadTestVariableObservations(Directory, Config, TestVarNameShort);
        if ~isempty(ObsTestVar)
            Config.ObsTestVar.(TestVarNameFull) = ObsTestVar;
        end
    end
end

% Read test parameter values
cd(Directory.BASE_PATH)
SimRound = 0;
Config = AAOS_ReadParameterValues(Config,[],SimRound);
Config = AAOS_SeparateCropParameters(Config);

ParNames = Config.AllParameterNames;
Config.AllParameterValues = Config.AllParameterUppLim;
N_ParAll = size(ParNames,1);

% Create YldForm field & get unit for AOS output phenology unit:
[Config, ~] = AAOS_ConvertandCheckParameters(Config,Directory);

% Option to test existing .mat output files, i.e. skipping the entire
% sampling/model evaluation process:
skip = 0;
if skip == 1
    [Config, SA_Output] = AAOS_SAFE_TEST_BypassSamplingAndEval(Config, Directory, SA_Output);
else
    [Config, SA_Output] = AAOS_SAFE_PerformSensitivityAnalysis(Config, Directory, SA_Output, N_ParAll);
end