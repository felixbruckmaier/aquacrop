function [Config, SA_Output] = AAOS_SAFE_PrepareSamples(Config, Directory, SA_Output)

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

Config.r = 4000;

skip = 0;
if skip == 1
    cd(Directory.AAOS_Output)
    LotName = strcat("Lot",string(Config.LotName));
       FileName = strcat("SA_Output",LotName,".mat");
       FileContent = load(FileName);
       SA_Output.RowTitles = FileContent.SA_Output.RowTitles;
       SA_Output.(LotName) = FileContent.SA_Output.(LotName);
       Config.SampledParNames = SA_Output.(LotName).ParameterNames;
else

    [SampledParNames,Samples_AOS_In,ValueLimits,FixedParIdcs] =...
        AAOS_SAFE_SampleParameterSpace(Directory,Config);

    M_new = size(SampledParNames,1);

    [Col_SAFEinAOS,Col_Conv_SAFEinAOS,Col_Conv_SAFEinSAFE]...
        = AAOS_SAFE_DeriveSamplesToAnalyze(Config,N_ParAll,FixedParIdcs);

    [Samples_AOS_Out,Rows_rmvPheno] =...
        AAOS_SAFE_ConvertandCheckParameters(Config,N_ParAll,Samples_AOS_In);

    [Rows_ValidEEsamples,N_ValidEEsamples] = AAOS_SAFE_IndicateInvaliSamples(M_new,Rows_rmvPheno);

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

    %% Step 5 (Computation of the Elementary effects)

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
    %     r = r_new;


Config.SampledParNames = SampledParNames;
design_type = Config.DesignType;
% design_type = 'trajectory';
cd(Directory.SAFE_Morris);

%% Compute EE indices
[ ~, ~, EE ] = EET_indices(r_new,xmin,xmax,X,Y,design_type);
% Discard the mean/ standard deviation obtained by the function, which does
% not ignore NaN values in EE (which occur when parameters don't change their
% value at a sampling point after being rounded to the respective AOS input
% decimals - e.g., the sampling process might adjust the value of the HIo
% parameter from 0.4812 to 0.4756 at one sampling point. However, both values
% will be rounded to 0.48 in AOS, therefore the value stays the same. This
% is more likely to happen for parameters with narrow value ranges.
% Alternatively, adjust the SAFE function 'EET_indices.m' itself.

% EE is the matrix that will be printed in the output spreadsheet (to
% indicate all EEs, which could not be computed, by 'NaN').
% Replace infinitive values in EE matrix by NaN (Maybe unnecessary): 
EE(EE==inf) = nan;

% Calculate mean and sigma from EE matrix while ignoring NaN values:
mi       = mean(EE,'omitnan');
sigma    = std(EE,'omitnan');

% Create EE matrix with valid entries only: Subsequent functions (which
% compute convergence of the results which requires a EE without NaN
% values):
EE_adj = fillmissing(EE,'constant',mi);

% Parameters that only show NaN values at every sampling point cannot be
% provided with their mean value. 
 EE_adj(isnan(EE_adj)) = 0;

 % Replace NaN values in EE matrix with printable "-999999":
 EE(isnan(EE)) = -999999;

cols_Par = 1:M_new;

cd(Directory.SAFE_Morris);

%% CONVERGENCE:
% Repeat computations using a decreasing number of samples so as to assess
% if convergence was reached within the available dataset:
n_Rep = 10; % number of repetitions

% Compute convergence if r is large enough to be split up into the defined
% number of repetitions:
rr = [r_new/n_Rep : r_new/n_Rep : r_new];
if n_Rep <= r_new
    % Round rr down to obtain integers:
    rr = floor(rr);
    % Derive EE for different repetitions:
    m_r = EET_convergence(EE_adj,rr);
else % otherwise only print the available mean values (= the ones computed
    % by 'EET_indices' for the default number of sampling points)...:
    m_r(1:(n_Rep-1), cols_Par) = -999999;
    % ... and assign dummy values to rows of N.A. convergence results:
    m_r(n_Rep, :) = mi;
end



cd(Directory.SAFE_Morris);

% Derive computed number of model evaluations for every repetition:
n_SamplesRep = rr*(M_new+1);
n_new = size(X,1);
n_sig = 1;


rows_mean = [2 : (1 + n_Rep)]';
rows_sig = [(rows_mean(end) + 1) : (rows_mean(end) + n_sig)]';
rows_EE = [(rows_sig(end) + 2) : (rows_sig(end) + 1 + r_new)]';
rows_Lim = [(rows_EE(end) + 3) : (rows_EE(end) + 4)]';
rows_Samp = [(rows_Lim(end) + 2) : (rows_Lim(end) + 1 + n_new)]';



% Create array 
SA_Output_mat = nan(rows_Samp(end), M_new + 1);


SA_Output_mat(rows_mean, cols_Par) = m_r;
SA_Output_mat(rows_sig, cols_Par) = sigma;
SA_Output_mat(rows_EE, cols_Par) = EE;
SA_Output_mat(rows_Lim, cols_Par) = [xmin; xmax];
SA_Output_mat(rows_Samp, cols_Par) = X;
SA_Output_mat(rows_Samp, cols_Par(end)+1) = Y;

LotNameFull = "Lot" + string(Config.LotName);
SA_Output.(LotNameFull) = struct;
SA_Output.(LotNameFull).ParameterNames = SampledParNames;
SA_Output.(LotNameFull).SampleSizes = n_SamplesRep;
% SA_Output.(LotNameFull).EE_adjusted = EE_adj;
SA_Output.(LotNameFull).Values = SA_Output_mat;
SA_Output.(LotNameFull).RowTitles(1,1) = ["ELEMENTARY EFFECTS"];
SA_Output.(LotNameFull).RowTitles(rows_mean,1) = "Mean ("+n_SamplesRep(:)+" samples):";
SA_Output.(LotNameFull).RowTitles(rows_sig,1) = "Standard deviation ("+n_new+" samples):";
SA_Output.(LotNameFull).RowTitles(rows_EE(1)-1,1) = ["Absolute values"];
SA_Output.(LotNameFull).RowTitles(rows_EE,1) = 1:r_new;
SA_Output.(LotNameFull).RowTitles(rows_Lim(1)-1,1) = ["INPUT VALUES"];
SA_Output.(LotNameFull).RowTitles(rows_Lim,1) = ["Lower limit","Upper limit"];
SA_Output.(LotNameFull).RowTitles(rows_Samp(1)-1,1) = ["Samples"];
SA_Output.(LotNameFull).RowTitles(rows_Samp,1) = 1:n_new;

% %% COMPUTE BOOTSTRAPPING:
% Nboot=r_new;
% % Compute EE & extra measures:
% [mi,sigma,EE,mi_sd,sigma_sd,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...
%     EET_indices(r_new,xmin,xmax,X,Y,design_type,Nboot);
% % Repeat convergence analysis using bootstrapping:
% rr = [r_new/5:r_new/5:r_new];
% % Round rr down to integers:
% rr = floor(rr);
% X_labels(1) = [];
% [m_r,s_r,m_lb_r,m_ub_r] = EET_convergence(EE,rr,Nboot);

% %% PLOT BOOTSTRAPPING:
% X_labels = X_labelsalt;
% % Plot bootstrapping results in the plane (mean(EE),std(EE)):
% EET_plot(mi,sigma,X_labels,mi_lb,mi_ub,sigma_lb,sigma_ub);
% % Plot the sensitivity measure (mean of elementary effects) as a function
% % of model evaluations:
% cd(Directory.SAFE_Plotting);
% X_labels(1) = [];
% figure; plot_convergence(m_r,rr*(M_new+1),m_lb_r,m_ub_r,[],...
%     'no of model evaluations','mean of EEs',X_labels)
end
cd(Directory.BASE_PATH);