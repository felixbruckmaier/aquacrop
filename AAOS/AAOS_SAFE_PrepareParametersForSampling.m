function [SampledParNames,SampledParIdcs,ValueLimits,FixedParIdcs,FixParsValues,...
    DistrPar,idx_logscale,ParDecimals] = AAOS_SAFE_PrepareParametersForSampling(Config)

ParNames = Config.AllParameterNames;
N_Par = size(ParNames,1);
AllParIdcs = 1:N_Par;

ParDecimals = Config.AllParameterDecimals(AllParIdcs);
% Get Parameter ranges:
xmin = Config.AllParameterLowLim(AllParIdcs)'; %lowlim_test';
xmax = Config.AllParameterUppLim(AllParIdcs)'; %upplim_test';

% Determine parameters to be excluded from analysis, but which values are
% supposed to be conveyed to AOS in their user-defined unit (e.g. CDC)
FixedParIdcs = AllParIdcs(xmin==xmax);
% FixParIdcs = sort([ParIdcsLeaveOut, ParIdcsFixValue]);
FixParsValues = Config.AllParameterLowLim(FixedParIdcs)';
xmin(FixedParIdcs) = [];
xmax(FixedParIdcs) = [];
ValueLimits(1,:) = xmin;
ValueLimits(2,:) = xmax;

SampledParNames = ParNames;
SampledParNames(FixedParIdcs) = [];

AllParIdcs(FixedParIdcs) = [];
SampledParIdcs = AllParIdcs;
ParDecimals(FixedParIdcs) = [];



% Convert parameters with heterogenous value ranges to log scale to
% guarantuee homogenous sampling; f.ex.: hydr. conductivity (ksat) - (1/2):
Par_count = 1:size(AllParIdcs,2);
a = ismember(SampledParNames, Config.LogScalePars);
idx_logscale = Par_count(a==1);
xmin(idx_logscale) = log10(xmin(idx_logscale));
xmax(idx_logscale) = log10(xmax(idx_logscale));

% Determine number of parameters to analyze:
N_Par    = size(AllParIdcs,2);

% Parameter distributions:
DistrPar = cell(N_Par,1);
for idx=1:N_Par
    DistrPar{idx} = [ xmin(idx) xmax(idx) ];
end