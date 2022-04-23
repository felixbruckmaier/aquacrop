%% Performs one AAOS simulation round, i.e., for all test variables:
% Read variable observations & parameter values, check & write parameter
% values, run AOS, read AOS model output & calculate GoF, fill output arrays
function [Config,ModelOut] =...
    AAOS_PerformSimulationRound(Config,Directory,ModelOut,TestVarIds,SimRound)

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
        % Assign SWC depth to be tested (set to "1" when analyzing Canopy Cover):
        % -> column idx
        if TestVarNameShort == "SWC"
            idx_Observation = Config.idx_SimDepthsObservations(Config.idx_TestSWC);
        elseif TestVarNameShort == "CC"
            idx_Observation = 1;
        end
        % Read observed values for given test variable & depth:
        [ObsTestVar,~] = AAOS_ReadTestVariableObservations(Directory,Config,...
            TestVarNameShort,idx_Observation);
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

        % Convert SimPeriod parameters to serial format:
        ParNames = Config.AllParameterNames;
        ParValues = Config.AllParameterValues;
        [SimPeriodVals,~] = AAOS_ConvertSimPeriodParameters(Config,ParNames,ParValues);

        % Adjust simulation period, if test values require it:
        SimPeriodValsDef = Config.SimPeriodValsDef;
        if any(SimPeriodVals > SimPeriodValsDef)
            % Write adjusted sim period days to all related AOS input files:
            VarValues = AAOS_ConvertSimPeriodParameters(SimPeriodValsDef,SimPeriodVals);
            VarNames = ["PlantingDate","HarvestDate"];
            FileType = "SimPeriod";
            AAOS_WriteAOSinputFiles(Directory,Config,VarNames,VarValues,FileType)
            % Assign the SimPeriod currently stored in the AOS input .txt
            % files to the default SimPeriod array:
            Config.SimPeriodValsDef = VarValues;
            % Store adjusted simulation period, and weather inputs, to be
            % able to retrieve the updated GDD's in the subsequent step:
            cd(Directory.AOS);
            AOS_Initialize();
            cd(Directory.BASE_PATH)
        end


        % Store cumulated sum of GDD's within simulation period
        GDDcumsum = AAOS_ComputeGDD;

        % Calculate for all tested phenology parameters (except CGC + CDC)
        % the values for both calendar type units, CD and GDD:
        CropParameters = Config.CropParameters;
        [CD_Values,GDD_Values] =...
            AAOS_ComputePhenologyUnits(GDDcumsum,CropParameters);

        % Update all phenology parameters in the test parameter array with
        % the correct unit (according to 'Crop.txt'):
        AllNames = Config.AllParameterNames;
        AllValues = Config.AllParameterValues;
        CropParameters.InputValues = Config.CropParameters.InputValues;

        [CropParameters,AllValues,PhenoUnitAOS] =...
            AAOS_HomogenizePhenologyUnits(...
            CD_Values,GDD_Values,AllNames,AllValues,CropParameters);

        Config.AllParameterValues = AllValues;

        % stop analysis in case there is any conflict regarding the user-defined phenology values:
        breakloop = 0;
        [Config, breakloop] = ...
            AAOS_CalculateAndCheckCropCalendar(Config,CropParameters,GDDcumsum,PhenoUnitAOS);

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
                Config = AAOS_CalculateGoF(Config,SimTestVar,ObsTestVar);
            end

            % Store (simulated & derived) absolute & relative model output values:
            ModelOut = AAOS_StoreSimulationsAndGoF...
                (Config,ModelOut,SimRound,TestVarNameShort,SimTestVar,ObsTestVar);
        end
    end
end