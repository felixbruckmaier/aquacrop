%% Performs one AAOS simulation round, i.e., for all test variables:
% Read variable observations & parameter values, check & write parameter
% values, run AOS, read AOS model output & calculate GoF, fill output arrays
function [Config,ModelOut] =...
    AAOS_ModelEval_PerformSimulationRound(Config,Directory,ModelOut,TestVarIds,SimRound)

% Determine variables to simulate
% SimRound 1-3 = Default / Calibration / Recalculation -> for CC and/or SWC
if SimRound < 4
    VarIdcs = min(TestVarIds):min(2,max(TestVarIds));
    % SimRound 4 = HI calibration -> no variable observation reading needed
elseif SimRound == 4
    VarIdcs = 3;
end

for VarIdx = VarIdcs

    % Determine test variable:
    [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(VarIdx);

    if TestVarNameShort == "HI"
        ObsTestVar = [];
    else % For CC & SWC: Retrieve observations:
        [ObsTestVar] = AAOS_ReadTestVariableObservations...
            (Directory, Config, TestVarNameShort);
    end

    % Escape if the current test variable does not show observations:
    % (incl. only SWC observations for the first SimDay -> already used for
    % initial SWC)
    if TestVarNameShort ~= "HI" & (...
            isempty(ObsTestVar) |...
            and(TestVarNameShort == "SWC",...
            and(size(ObsTestVar,1) == 1,ObsTestVar(:,1)==1)))

        fprintf(1,'No ' + TestVarNameFull + ' observations available -> '...
            +' Switch to next variable/ lot.\n');
    else

        % Store test variable observations:
        Config.TestVariableObservations = ObsTestVar;

        % Read test parameter values
        cd(Directory.BASE_PATH)
        Config = AAOS_ReadParameterValues(Config,VarIdx,SimRound);

        % Derive which input parameters are crop parameters:
        Config = AAOS_SeparateCropParameters(Config);

        [Config, breakloop] = AAOS_ConvertandCheckParameters(Config);

        if breakloop == 0
            % Write parameter values to AOS input files:
            AAOS_WriteModelParameters(Directory,Config);

            % Run AOS simulation with now updated input files:
            cd(Directory.AOS);
            AquaCropOS_RUN;
            cd(Directory.BASE_PATH)

            % Read & store simulated values of target and test variables:
            [Config,SimTestVar] = ...
                AAOS_ReadAOSsimulationOutput(Config,TestVarNameShort,ObsTestVar);

            if TestVarNameShort ~= "HI" % For CC & SWC:
                % Calculate GoF for simulated & observed values of the test variable:
                Config = AAOS_ModelEval_CalculateGoF(Config,SimTestVar,ObsTestVar);
            end

            % Store (simulated & derived) absolute & relative model output values:
            ModelOut = AAOS_ModelEval_StoreSimulationsAndGoF...
                (Config,ModelOut,SimRound,TestVarNameShort,SimTestVar,ObsTestVar);
        end
    end
end