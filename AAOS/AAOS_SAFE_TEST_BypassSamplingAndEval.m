function [Config, SA_Output] = AAOS_SAFE_TEST_BypassSamplingAndEval(Config, Directory, SA_Output)

cd(Directory.AAOS_Output)
LotNameFull = strcat("Lot",string(Config.LotName));
FileName = strcat("SA_Output",LotNameFull,".mat");
FileContent = load(FileName);
SA_Output.(LotNameFull) = FileContent.SA_Output.(LotNameFull);
Config.SampledParNames = SA_Output.(LotNameFull).ParameterNames;
M_new = 18;
r_new = 324;
n_new = r_new * (M_new + 1);
cols_Par = 1:M_new;
X_labels(1) = cellstr("Season "+Config.season+"/ Plot #"+...
    LotNameFull+"/ "+string(Config.TargetVar.NameFull)+": Elementary Effects (EE)");
% Remove underscore sign from parameter names (plot function forces characters into lowercase)
SampledParNames = cellstr(replace(string(SA_Output.(LotNameFull).ParameterNames),'_','-'));
X_labels(2:M_new+1) = SampledParNames;
design_type = Config.DesignType

cd(Directory.SAFE_Morris);

%% CONVERGENCE:
% Repeat computations using a decreasing number of samples so as to assess
% if convergence was reached within the available dataset:
n_Rep = 10; % number of repetitions


n_sig = 1;
rows_mean = [2 : (1 + n_Rep)]';
rows_sig = [(rows_mean(end) + 1) : (rows_mean(end) + n_sig)]';
rows_EE = [(rows_sig(end) + 2) : (rows_sig(end) + 1 + r_new)]';
rows_Lim = [(rows_EE(end) + 3) : (rows_EE(end) + 4)]';
rows_Samp = [(rows_Lim(end) + 2) : (rows_Lim(end) + 1 + n_new)]';



xmin = SA_Output.(LotNameFull).Values(rows_Lim(1), cols_Par);
xmax = SA_Output.(LotNameFull).Values(rows_Lim(2), cols_Par);
X = SA_Output.(LotNameFull).Values(rows_Samp, cols_Par);
Y = SA_Output.(LotNameFull).Values(rows_Samp, cols_Par(end)+1);
EE = SA_Output.(LotNameFull).Values(rows_EE, cols_Par);
EE(EE<0) = nan;
mi       = mean(EE,'omitnan');
sigma    = std(EE,'omitnan');
EE_adj = fillmissing(EE,'constant',mi);
EE_adj(isnan(EE_adj)) = 0;
EE(isnan(EE)) = -999999;




cd(Directory.SAFE_Morris);

%% COMPUTE BOOTSTRAPPING:
% Compute EE & extra measures:
Nboot=round(n_new/100);
[mi,sigma,EE,mi_sd,sigma_sd,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...
    EET_indices(r_new,xmin,xmax,X,Y,design_type,Nboot);

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
[SA_Output] = AAOS_EE_StoreOutput(Config,r_new,rr,M_new,n_Rep,...
    cols_Par,m_r,sigma,EE,xmin,xmax,X,Y,SampledParNames,SA_Output);


cd(Directory.BASE_PATH);