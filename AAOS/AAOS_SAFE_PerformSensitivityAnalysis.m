function [Config, SA_Output] = AAOS_SAFE_PerformSensitivityAnalysis(Config, Directory, SA_Output, N_ParAll)



[Config,r_new,X,Y,xmin,xmax] =...
    AAOS_SAFE_DeriveValidSamples(Directory,Config,N_ParAll);





%% Compute EE indices
cd(Directory.SAFE_Morris);
design_type = Config.DesignType;
%% COMPUTE BOOTSTRAPPING:
% Compute EE & extra measures:
Nboot=round(n_new/100);
[mi,sigma,EE,mi_sd,sigma_sd,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...
    EET_indices(r_new,xmin,xmax,X,Y,design_type,Nboot);


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
% Calculate normalized sensitivity index according to Sarrazin et al. 2016:
SI_n = mi/max(mi);
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

    %% WITHOUT BOOTSTRAPPING:
    % Derive EE for different repetitions:
    %     m_r = EET_convergence(EE_adj,rr);

    %% WITH BOOTSTRAPPING:
    Nboot=round(n_new/100);
    [m_r,s_r,m_lb_r,m_ub_r] = EET_convergence(EE,rr,Nboot);

else % otherwise only print the available mean values (= the ones computed
    % by 'EET_indices' for the default number of sampling points)...:
    m_r(1:(n_Rep-1), cols_Par) = -999999;
    % ... and assign dummy values to rows of N.A. convergence results:
    m_r(n_Rep, :) = mi;
end



cd(Directory.SAFE_Morris);

%% PLOT BOOTSTRAPPING:
% Plot bootstrapping results in the plane (mean(EE),std(EE)):
EET_plot(mi,sigma,X_labels,mi_lb,mi_ub,sigma_lb,sigma_ub);
% Plot the sensitivity measure (mean of elementary effects) as a function
% of model evaluations:
cd(Directory.SAFE_Plotting);
X_labels(1) = [];
figure; plot_convergence(m_r,rr*(M_new+1),m_lb_r,m_ub_r,[],...
    'no of model evaluations','mean of EEs',X_labels)


cd(Directory.BASE_PATH);
[SA_Output] = AAOS_SAFE_StoreEEResults(Config,r_new,rr,M_new,n_Rep,...
    cols_Par,m_r,sigma,EE,xmin,xmax,X,Y,SampledParNames,SA_Output);


cd(Directory.BASE_PATH);


