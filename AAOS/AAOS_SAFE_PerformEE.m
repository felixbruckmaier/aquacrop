function [Config, LotAnalysisOut] = AAOS_SAFE_PerformEE(Config, Directory, LotAnalysisOut)

% Derive samples and target variable created for current lot:
SampledParNames = LotAnalysisOut.SamplingOut.ParameterNames;
M = size(SampledParNames,1);
xmin = LotAnalysisOut.SamplingOut.Values(1, 1:M);
xmax = LotAnalysisOut.SamplingOut.Values(2, 1:M);
X = LotAnalysisOut.SamplingOut.Values(6:end, 1:M);

if Config.TargetVarEE == "Biomass"
    idxTargetVar = 1;
elseif Config.TargetVarEE == "Yield"
    idxTargetVar = 3;
end

TargetVar = LotAnalysisOut.SamplingOut.Values(6:end, M + idxTargetVar);
n = size(TargetVar,1);
r = n / (M + 1);

%% Compute EE indices
cd(Directory.SAFE_Morris);
design_type = Config.DesignType;

% Discard the mean/ standard deviation obtained by the function, which does
% not ignore NaN values in EE (which occur when parameters don't change their
% value at a sampling point after being rounded to the respective AOS input
% decimals - e.g., the sampling process might adjust the value of the HIo
% parameter from 0.4812 to 0.4756 at one sampling point. However, both values
% will be rounded to 0.48 in AOS, therefore the value stays the same. This
% is more likely to happen for parameters with narrow value ranges.
% Alternatively, adjust the SAFE function 'EET_indices.m' itself.
% Compute EE & extra measures:

[ ~, ~, EE_nanvalues ] = EET_indices(r,xmin,xmax,X,TargetVar,design_type);
% EE is the matrix that will be printed in the output spreadsheet (to
% indicate all EEs, which could not be computed, by 'NaN').
% Replace infinitive values in EE matrix by NaN:
EE_nanvalues(EE_nanvalues==inf) = nan;
% Replace NaN values in EE matrix with printable "-999999":
EE_adj = fillmissing(EE_nanvalues,'constant',-999999);

% % Calculate mean and sigma from EE matrix while ignoring NaN values:
% mi       = mean(EE,'omitnan');
% % % Calculate normalized sensitivity index according to Sarrazin et al. 2016:
% % SI_n = mi/max(mi);
% % % Calculate standard deviation of all EE effects for every parameter:
% sigma    = std(EE,'omitnan');
% % Create EE matrix with valid entries only: Subsequent functions (which
% % compute convergence of the results which requires a EE without NaN
% % values):
% EE = fillmissing(EE,'constant',mi);

%% COMPUTE BOOTSTRAPPING:
Nboot=1000;
[mi,sigma,EE,~,~,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...
    EET_indices(r,xmin,xmax,X,TargetVar,design_type,Nboot);


cd(Directory.SAFE_Morris);

%% CONVERGENCE:
% Repeat computations using a decreasing number of samples so as to assess
% if convergence was reached within the available dataset:
n_Rep = 10; % number of repetitions
cols_Par = 1:M;
% Compute convergence if r is large enough to be split up into the defined
% number of repetitions:
rr = [r/n_Rep : r/n_Rep : r];
if n_Rep <= r
    % Round rr down to obtain integers:
    rr = floor(rr);

    %% WITHOUT BOOTSTRAPPING:
    % Derive EE for different repetitions:
    %     m_r = EET_convergence(EE_adj,rr);

    %% WITH BOOTSTRAPPING:
    Nboot=1000;
    [m_r,~,m_lb_r,m_ub_r] = EET_convergence(EE,rr,Nboot);

else % otherwise only print the available mean values (= the ones computed
    % by 'EET_indices' for the default number of sampling points)...:
    m_r(1:(n_Rep-1), cols_Par) = -999999;
    % ... and assign dummy values to rows of N.A. convergence results:
    m_r(n_Rep, :) = mi;
end

LotAnalysisOut.Statistics.mi = mi;
LotAnalysisOut.Statistics.mi_lb = mi_lb;
LotAnalysisOut.Statistics.mi_ub = mi_ub;
LotAnalysisOut.Statistics.sigma = sigma;
LotAnalysisOut.Statistics.sigma_lb = sigma_lb;
LotAnalysisOut.Statistics.sigma_ub = sigma_ub;
LotAnalysisOut.Statistics.m_r = m_r;
LotAnalysisOut.Statistics.m_lb_r = m_lb_r;
LotAnalysisOut.Statistics.m_ub_r = m_ub_r;

cd(Directory.BASE_PATH);
[LotAnalysisOut] = AAOS_SAFE_StoreEEResults(r,rr,M,n_Rep,cols_Par,...
    EE_adj,Nboot,mi,mi_lb,mi_ub,sigma,sigma_lb,sigma_ub,m_r,m_lb_r,m_ub_r,xmin,...
    xmax,X,TargetVar,LotAnalysisOut);
cd(Directory.BASE_PATH);


