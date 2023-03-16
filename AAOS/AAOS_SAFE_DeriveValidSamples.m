%% Samples parameter input space, removes all invalid sampling points, and
% creates separate sample arrays for AOS input files (parameter values in AOS
% output unit) and sensitivity analysis (parameter values in AAOS input unit):
function [Config,SamplingOut] =...
    AAOS_SAFE_DeriveValidSamples(Directory,Config)

% Read test parameter values
cd(Directory.BASE_PATH)
SimRound = 0;
Config = AAOS_ReadParameterValues(Config,[],SimRound);
Config = AAOS_SeparateCropParameters(Config);

ParNames = Config.AllParameterNames;
Config.AllParameterValues = Config.AllParameterUppLim;
N_ParAll = size(ParNames,1);

% Create YldForm field & get unit for AOS output phenology unit:
[Config, ~] = AAOS_ConvertandCheckParameters(Config);

[SampledParNames,SampledParIdcs,ValueLimits,FixedParIdcs,FixParsValues,...
    DistrPar,idx_Ksat,...
    ParDecimals]...
    = AAOS_SAFE_PrepareParametersForSampling(Config);
N_ParNew = size(SampledParNames,1);

%% Sample parameter space & check samples until the number of valid samples
% reaches/ exceeds the user-defined threshold:
N_SimTarget = Config.N_SimTarget;
N_SimCalc = 0;

while N_SimCalc < N_SimTarget

    [Samples_AOS_In] = AAOS_SAFE_SampleParameterSpace...
        (Directory,Config,N_ParNew,FixParsValues,DistrPar,idx_Ksat,...
        ParDecimals,SampledParIdcs,FixedParIdcs);



    [Col_SAFEinAOS,Col_Conv_SAFEinAOS,Col_Conv_SAFEinSAFE]...
        = AAOS_SAFE_DeriveSamplesToAnalyze(Config,N_ParAll,FixedParIdcs);

    [Samples_AOS_Out,Rows_rmvPheno] =...
        AAOS_SAFE_ConvertandCheckParameters(Config,N_ParAll,Samples_AOS_In);



    if Config.RUN_type == "EE"
        % EE method -> remove invalid samples, keeping sample points intact -
        % an explanation can be found within the following function:
        [Rows_ValidSamplesUnnormed,N_ValidSamplesUnnormed] =...
            AAOS_SAFE_IndicateInvalidSamples(N_ParNew,Rows_rmvPheno);
    elseif Config.RUN_type == "GLUE"
        % GLUE -> Remove invalid samples randomly, sample points dont matter:
        Rows_ValidSamplesUnnormed = find(Rows_rmvPheno == 0);
        N_ValidSamplesUnnormed = size(Rows_ValidSamplesUnnormed,1);
    end

    % If the overall sample contains any valid parameter combination...
    if N_ValidSamplesUnnormed > 0
        % ... Derive valid samples with AOS output values/ units:
        Samples_ValidAOS_OutUnnormed = Samples_AOS_Out(Rows_ValidSamplesUnnormed,:);
        % (the output array potentially contains exceeding samples)
    end
N_SimCalc = N_ValidSamplesUnnormed;
end


% Determine number of exceeding simulations, if any:
N_SimExceed = N_SimCalc - N_SimTarget;
% Remove exceeding samples & determine row indices of all samples to be used
if N_SimExceed > 0
    if Config.RUN_type == "EE"
        % EE method -> keeping sample points intact - see the following
        % function for more details:
        % Determine number of calculated sample points:
        N_PointsCalc = N_SimCalc / (N_ParNew + 1); % see 'EET_indices.m': n~=r*(M+1)
    [Rows_ValidSamplesNormed] =...
        AAOS_SAFE_IndicateExceedingSamples(N_PointsCalc, N_PointsCalc, N_ParNew);
    elseif Config.RUN_type == "GLUE"
        % GLUE -> Remove simulations randomly (sample points dont matter):
        Rows_ValidSamplesNormed = randsample(N_SimCalc,N_SimTarget);
    end
else
    % If no exceeding samples, simply adopt the previous array:
    Rows_ValidSamplesNormed = 1:N_SimCalc;
end
ValidSamplesAOS_Out = Samples_ValidAOS_OutUnnormed(Rows_ValidSamplesNormed,:);


% Initialize AOS arrays:
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)

% Evaluate AOS model with sampled parameter value matrix:
X_1 = ValidSamplesAOS_Out(1,:);
% Check test variable availability & get timeseries length for every output
% variable:
[Y1,TestVarSizes] = AAOS_SAFE_EvaluateAOSsimulation(X_1,Config,Directory);
% Get length of all output variable timeseries glued together:
size_Y = size(Y1,2);

% % Delete any test variable with missing observations from user selection:
% nan_TestVars = isnan(TestVarSizes);
% Config.TestVarIds(nan_TestVars(:,2)==1) = [];
% TestVarSizes(:,nan_TestVars(:,2)==1) = [];

%% Run AOS model for all samples and store the simulated values of the target
% variable and all available (and user-defined) test variables:
N = size(ValidSamplesAOS_Out,1);
Y = nan(N,size_Y) ;
for j=1:N
    X_j = ValidSamplesAOS_Out(j,:);
    Y(j,:) = AAOS_SAFE_EvaluateAOSsimulation(X_j,Config,Directory);
end

% Narrow value matrix down to sampled parameters only
Samples_ValidAOS_In = Samples_AOS_In(Rows_ValidSamplesNormed,:);
% Samples_Unconverted(rmvPhenoSamples==1,:) = [];
% Samples_ValidSAFE_In(rmvExceedSamples,:) = [];
Samples_ValidConvert_In = Samples_ValidAOS_In(:,Col_Conv_SAFEinAOS);
Samples_ValidSAFE_In = ValidSamplesAOS_Out(:,Col_SAFEinAOS);
Samples_ValidSAFE_In(:,Col_Conv_SAFEinSAFE) = Samples_ValidConvert_In;

X = Samples_ValidSAFE_In;

xmin = ValueLimits(1,:);
xmax = ValueLimits(2,:);

Config.SampledParNames = SampledParNames;

M = size(SampledParNames,1);

Values =...
    [[xmin nan(1, size_Y)];...
    [xmax nan(1, size_Y)];...
    nan(3, (M+size_Y))];
Values( (6: 5+size(X,1)), (1   : M) ) = X;
Values( (6: 5+size(X,1)), (M+1):(M+size(Y,2)) ) = Y;

SamplingOut.Values = Values;
SamplingOut.ParameterNames = Config.SampledParNames;
SamplingOut.ColumnTitles = Config.SampledParNames';
SamplingOut.TestVariableSizes = TestVarSizes;
