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


%% Sample parameter space & check samples until the number of valid samples
% reaches/ exceeds the user-defined threshold:
r_target = Config.r_target;
r_calc = 0;
while r_calc < r_target

    [SampledParNames,Samples_AOS_In,ValueLimits,FixedParIdcs] =...
        AAOS_SAFE_SampleParameterSpace(Directory,Config);

    M_new = size(SampledParNames,1);

    [Col_SAFEinAOS,Col_Conv_SAFEinAOS,Col_Conv_SAFEinSAFE]...
        = AAOS_SAFE_DeriveSamplesToAnalyze(Config,N_ParAll,FixedParIdcs);

    [Samples_AOS_Out,Rows_rmvPheno] =...
        AAOS_SAFE_ConvertandCheckParameters(Config,N_ParAll,Samples_AOS_In);

    [Rows_UnnormedValidEEsamples,N_UnnormedValidEEsamples] =...
        AAOS_SAFE_IndicateInvalidSamples(M_new,Rows_rmvPheno);

    % If the overall sample contains any valid parameter combination...
    % a) Derive valid samples with AOS output values/ units;
    % b) Recalculate number of sampling points 'r'.
    if N_UnnormedValidEEsamples > 0
        % a)
        Samples_UnnormedValidAOS_Out = Samples_AOS_Out(Rows_UnnormedValidEEsamples,:);
        % (the output array potentially contains exceeding samples)

        % b) 
        n_calc = N_UnnormedValidEEsamples;
        r_calc = n_calc / (M_new + 1); % see 'EET_indices.m': n~=r*(M+1)
    end
disp(r_calc);
end

% Determine number of exceeding sample points, if any:
r_exceed = r_calc - r_target;
if r_exceed > 0
    % Remove exceeding samples, keeping sample points intact (see function for
    % more details), and determine row indices of all samples to be used:
    [Rows_NormedValidEE_samples] =...
        AAOS_SAFE_IndicateExceedingSamples(r_calc, r_target, M_new);
else
    % If no exceeding samples, simply adopt the previous array:
    Rows_NormedValidEE_samples = 1:N_UnnormedValidEEsamples;
end
Samples_ValidAOS_Out = Samples_UnnormedValidAOS_Out(Rows_NormedValidEE_samples,:);


% Initialize AOS arrays:
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)

% Evaluate AOS model with sampled parameter value matrix:
X_1 = Samples_ValidAOS_Out(1,:);
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
N = size(Samples_ValidAOS_Out,1);
Y = nan(N,size_Y) ;
for j=1:N
    X_j = Samples_ValidAOS_Out(j,:);
    Y(j,:) = AAOS_SAFE_EvaluateAOSsimulation(X_j,Config,Directory);
end

% Narrow value matrix down to sampled parameters only
Samples_ValidAOS_In = Samples_AOS_In(Rows_NormedValidEE_samples,:);
% Samples_Unconverted(rmvPhenoSamples==1,:) = [];
% Samples_ValidSAFE_In(rmvExceedSamples,:) = [];
Samples_ValidConvert_In = Samples_ValidAOS_In(:,Col_Conv_SAFEinAOS);
Samples_ValidSAFE_In = Samples_ValidAOS_Out(:,Col_SAFEinAOS);
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
