%% Stores all numerical results of the EE analysis to be a) written in the
% output spreadsheet, and b) used by the graphical plotting;
% Data contains: Value ranges for all used parameters; Samples used by EE
% with every parameter value and the resulting target variable value (biomass
% or yield); all computed EE; standard deviation & mean EE values of every
% parameter, for last & all, respectively, EE convergence repetition(s):
function [SA_Output] = AAOS_EE_StoreOutput(...
    Config,r_new,rr,M_new,n_Rep,cols_Par,m_r,sigma,EE,xmin,xmax,X,Y,SampledParNames,SA_Output)

% Derive computed number of model evaluations for every repetition:
n_SamplesRep = rr*(M_new+1);
n_new = size(X,1);
n_sig = 1;


rows_mean = [2 : (1 + n_Rep)]';
rows_sig = [(rows_mean(end) + 1) : (rows_mean(end) + n_sig)]';
rows_EE = [(rows_sig(end) + 2) : (rows_sig(end) + 1 + r_new)]';
rows_Lim = [(rows_EE(end) + 3) : (rows_EE(end) + 4)]';
rows_Samp = [(rows_Lim(end) + 2) : (rows_Lim(end) + 1 + n_new)]';


% Create numerical array
SA_Output_mat = nan(rows_Samp(end), M_new + 1);
SA_Output_mat(rows_mean, cols_Par) = m_r;
SA_Output_mat(rows_sig, cols_Par) = sigma;
SA_Output_mat(rows_EE, cols_Par) = EE;
SA_Output_mat(rows_Lim, cols_Par) = [xmin; xmax];
SA_Output_mat(rows_Samp, cols_Par) = X;
SA_Output_mat(rows_Samp, cols_Par(end)+1) = Y;

% Add data to final struct, which contains data for every analyzed plot:
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