%% Samples parameter input space, removes all invalid sampling points, and
% creates separate sample arrays for AOS input files (parameter values in AOS
% output unit) and sensitivity analysis (parameter values in AAOS input unit):
function [Config,r_new,X,Y,xmin,xmax] =...
    AAOS_SAFE_DeriveValidSamples(Directory,Config,N_ParAll)

[SampledParNames,Samples_AOS_In,ValueLimits,FixedParIdcs] =...
    AAOS_SAFE_SampleParameterSpace(Directory,Config);

M_new = size(SampledParNames,1);

[Col_SAFEinAOS,Col_Conv_SAFEinAOS,Col_Conv_SAFEinSAFE]...
    = AAOS_SAFE_DeriveSamplesToAnalyze(Config,N_ParAll,FixedParIdcs);

[Samples_AOS_Out,Rows_rmvPheno] =...
    AAOS_SAFE_ConvertandCheckParameters(Config,N_ParAll,Samples_AOS_In);

[Rows_ValidEEsamples,N_ValidEEsamples] = AAOS_SAFE_IndicateInvalidEEsamples(M_new,Rows_rmvPheno);

% Derive valid samples with AOS output values/ units:
Samples_ValidAOS_Out = Samples_AOS_Out(Rows_ValidEEsamples,:);

% Recalculate number of sampling points 'r':
% see 'EET_indices.m': n~=r*(M+1)
n_new = N_ValidEEsamples;
r_new = n_new / (M_new + 1);

% Initialize AOS arrays:
cd(Directory.AOS);
AOS_Initialize();
cd(Directory.BASE_PATH)

% Evaluate AOS model with sampled parameter value matrix:
X_1 = Samples_ValidAOS_Out(1,:);
tmp = AAOS_SAFE_EvaluateAOSsimulation(X_1,Config,Directory);
P = length(tmp) ; % number of model output
N = size(Samples_ValidAOS_Out,1);
Y = nan(N,P) ;
for j=1:N
    X_j = Samples_ValidAOS_Out(j,:);
    Y(j,:) = AAOS_SAFE_EvaluateAOSsimulation(X_j,Config,Directory);
end

% Narrow value matrix down to sampled parameters only
Samples_ValidAOS_In = Samples_AOS_In(Rows_ValidEEsamples,:);
% Samples_Unconverted(rmvPhenoSamples==1,:) = [];
% Samples_ValidSAFE_In(rmvExceedSamples,:) = [];
Samples_ValidConvert_In = Samples_ValidAOS_In(:,Col_Conv_SAFEinAOS);
Samples_ValidSAFE_In = Samples_ValidAOS_Out(:,Col_SAFEinAOS);
Samples_ValidSAFE_In(:,Col_Conv_SAFEinSAFE) = Samples_ValidConvert_In;

X = Samples_ValidSAFE_In;

xmin = ValueLimits(1,:);
xmax = ValueLimits(2,:);

Config.SampledParNames = SampledParNames;