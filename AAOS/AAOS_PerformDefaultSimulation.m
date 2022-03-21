%% Run default analysis: Simulation for one (default) set of parameter values
% for the specified paramerer set and the current lot & target variable
function AAOS_PerformDefaultSimulation(Config,Directory,ModelEval,SimOut)

% Get number of test Variables
TestVarIds = Config.TestVarIds;

for VarIdx = min(TestVarIds):min(2,max(TestVarIds))

% Determine test variable and read observed values:
[Config.TestVarNameFull,~] = AAOS_SwitchTestVariable(VarIdx);
ObsTestVar = AAOS_ReadTestVariableObservations(Directory,Config);

% Read values of test parameters and overwrite AOS input files:
cd(Directory.BASE_PATH)
Config = AAOS_ReadParameterValues(Config,VarIdx);
AAOS_WriteAOSinputFiles(Directory,Config);

% COMING SOON:
% Determine title for graphical output of current analysis
% Determine index of HI parameter in input file (-> 3. calibration round)
% Convert phenology parameter unit (GDD <-> calendar days)
% Check parameter values for phenology constraints

% Run AOS simulation:
cd(Directory.AOS);
AquaCropOS_RUN;

% Read & store simulated values of target and test variables:
cd(Directory.BASE_PATH)
[Config,SimTestVar] = AAOS_ReadAOSsimulationOutput(Config,ObsTestVar);

% Calculate GoF for simulated & observed values of the test variable:
Config = AAOS_CalculateGoF(Config,SimTestVar,ObsTestVar);

% Store absolute & relative simulated values
SimRound = 1; % default round
[ModelEval,SimOut] = AAOS_StoreSimulationsAndGoF...
    (Config,ModelEval,SimOut,SimRound,SimTestVar,ObsTestVar);

end
