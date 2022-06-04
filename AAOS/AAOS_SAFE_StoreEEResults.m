%% Stores all numerical results of the EE analysis to be a) written in the
% output spreadsheet, and b) used by the graphical plotting;
% Data contains: Value ranges for all used parameters; Samples used by EE
% with every parameter value and the resulting target variable value (biomass
% or yield); all computed EE; standard deviation & mean EE values of every
% parameter, for last & all, respectively, EE convergence repetition(s):
function [LotAnalysisOut] = AAOS_SAFE_StoreEEResults(r,rr,M,n_Rep,cols_Par,...
    EE,Nboot,mi,mi_lb,mi_ub,sigma,sigma_lb,sigma_ub,m_r,m_lb_r,m_ub_r,xmin,...
    xmax,X,Y,LotAnalysisOut)

% Derive computed number of model evaluations for every repetition:
n_ConvSamples = rr*(M+1);
n_SamplesMax = size(X,1);

rows_mean = 3 : 5;
rows_sig = [rows_mean(end) + 1 : rows_mean(end) + 3]'; 
rows_m_r_low = [rows_sig(end) + 2 : rows_sig(end) + 1 + n_Rep]';
rows_m_r = [rows_m_r_low(end) + 2 : rows_m_r_low(end) + 1 + n_Rep]';
rows_m_r_upp = [rows_m_r(end) + 2 : rows_m_r(end) + 1 + n_Rep]';
rows_EE = [(rows_m_r_upp(end) + 4) : (rows_m_r_upp(end) + 3 + r)]';
rows_Lim = [(rows_EE(end) + 5) : (rows_EE(end) + 6)]';
rows_Samp = [(rows_Lim(end) + 3) : (rows_Lim(end) + 2 + n_SamplesMax)]';

% Create numerical array
EE_Output_mat = nan(rows_Samp(end), M + 1);
EE_Output_mat(rows_mean, cols_Par) = [mi_lb; mi; mi_ub];
EE_Output_mat(rows_sig, cols_Par) = [sigma_lb; sigma; sigma_ub];
EE_Output_mat(rows_m_r_low, cols_Par) = [m_lb_r];
EE_Output_mat(rows_m_r, cols_Par) = [m_r];
EE_Output_mat(rows_m_r_upp, cols_Par) = [m_ub_r];
EE_Output_mat(rows_EE, cols_Par) = EE;
EE_Output_mat(rows_Lim, cols_Par) = [xmin; xmax];
EE_Output_mat(rows_Samp, cols_Par) = X;
EE_Output_mat(rows_Samp, cols_Par(end)+1:end) = Y;

% Add data to final struct, which contains data for every analyzed plot:
% LotAnalysisOut.ParameterNames = SampledParNames;
LotAnalysisOut.ConvergenceSampleSizes = n_ConvSamples;
% SA_Output.(LotNameFull).EE_adjusted = EE_adj;
LotAnalysisOut.Values = EE_Output_mat;
LotAnalysisOut.RowTitles(1,1) = ["STATISTICS (# resamples:"+Nboot+")"];
LotAnalysisOut.RowTitles(rows_mean,1) =...
    ["Mean (lower bound) - "+n_SamplesMax+" samples:";...
    "Mean - "+n_SamplesMax+" samples:";...
    "Mean (upper bound) - "+n_SamplesMax+" samples:"];
LotAnalysisOut.RowTitles(rows_sig,1) =...
    ["St. dev. (lower bound) - "+n_SamplesMax+" samples:";...
    "St. dev. - "+n_SamplesMax+" samples:";...
    "St. dev. (upper bound) - "+n_SamplesMax+" samples:"];
LotAnalysisOut.RowTitles(rows_m_r_low,1) =...
    ["Mean (lower bound) - "+n_ConvSamples(:)+" samples:"];
LotAnalysisOut.RowTitles(rows_m_r,1) =...
    ["Mean - "+n_ConvSamples(:)+" samples:"];
LotAnalysisOut.RowTitles(rows_m_r_upp,1) =...
    ["Mean (upper bound) - "+n_ConvSamples(:)+" samples:"];
LotAnalysisOut.RowTitles(rows_EE(1)-1,1) = ["ELEMENTARY EFFECTS"];
LotAnalysisOut.RowTitles(rows_EE,1) = 1:r;
LotAnalysisOut.RowTitles(rows_Lim(1)-2,1) = ["INPUT VALUES"];
LotAnalysisOut.RowTitles(rows_Lim,1) = ["Lower limit","Upper limit"];
LotAnalysisOut.RowTitles(rows_Samp(1)-1,1) = ["Samples"];
LotAnalysisOut.RowTitles(rows_Samp,1) = 1:n_SamplesMax;