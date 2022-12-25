function [SampledParNames,AllValuesMatrix,ValueLimits,FixedParIdcs] =...
    AAOS_SAFE_SampleParameterSpace(Directory,Config)

% TestParIdcs = Config.TestParameterIdx;
% N_AllPar = max(TestParIdcs);
% ParNames = Config.AllParameterNames(TestParIdcs);

ParNames = Config.AllParameterNames;
N_Par = size(ParNames,1);
AllParIdcs = 1:N_Par;

% % Parameters not part of the test round:
% ParIdcsLeaveOut = setdiff(AllParIdcs,TestParIdcs);


ParDecimals = Config.AllParameterDecimals(AllParIdcs);
% Get Parameter ranges:
xmin = Config.AllParameterLowLim(AllParIdcs)'; %lowlim_test';
xmax = Config.AllParameterUppLim(AllParIdcs)'; %upplim_test';




% Get Number of Elementary Effects
% needs to be here to be able to be resetted on user-defined value




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
% guarantuee homogenous sampling (here: hydr. conductivity: ksat) - (1/2):
Par_count = 1:size(AllParIdcs,2);
a = ismember(SampledParNames,"Ksat");
idx_Ksat = Par_count(a==1);
xmin(idx_Ksat) = log10(xmin(idx_Ksat));
xmax(idx_Ksat) = log10(xmax(idx_Ksat));

% Determine number of parameters to analyze:
N_Par    = size(AllParIdcs,2);

% Parameter distributions:
DistrFun  = 'unif'  ;
DistrPar = cell(N_Par,1);
for idx=1:N_Par
    DistrPar{idx} = [ xmin(idx) xmax(idx) ];
end

%% sample inputs space
% \GSA:

SampStrategy = Config.SampStrategy;                                  
design_type = Config.DesignType;   
cd(Directory.SAFE_Sampling);
r = Config.r_test;
SampleValuesMatrix = OAT_sampling(r,N_Par,DistrFun,DistrPar,SampStrategy,design_type);
cd(Directory.BASE_PATH);

% Re-convert parameters with heterogenous value ranges back from log scale
% to normal input values (here: hydr. conductivity: ksat) - (2/2):
if ~isempty(idx_Ksat)
    for idx_Sample = 1:size(SampleValuesMatrix,1)
        SampleValuesMatrix(idx_Sample,idx_Ksat) = 10^(SampleValuesMatrix(idx_Sample,idx_Ksat));
    end
end

% figure; plot(SampleValuesMatrix(:,1),SampleValuesMatrix(:,end),'ob')

% Round parameter values to decimals AOS can handle (user-defined):
for idx_par = 1:size(SampleValuesMatrix,2) % no. of columns = parameters
    SampleValuesMatrix(:,idx_par) = ...
        round(SampleValuesMatrix(:,idx_par),ParDecimals(idx_par));
end

% Insert parameters that are not part of sampling/ analysis, but were
% assigned a fix value (removed above):
AllValuesMatrix = nan(size(SampleValuesMatrix,1),N_Par + 1); % YldForm -> +1
AllValuesMatrix(:,SampledParIdcs) = SampleValuesMatrix;
for idx_FixPar = 1:size(FixedParIdcs,2)
    AllValuesMatrix(:,FixedParIdcs(idx_FixPar)) = FixParsValues(idx_FixPar);
end
