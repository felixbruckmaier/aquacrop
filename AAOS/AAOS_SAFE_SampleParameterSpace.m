function [Samples_AOS_In] = AAOS_SAFE_SampleParameterSpace...
        (Directory,Config,N_ParNew,FixParsValues,DistrPar,idx_Ksat,...
        ParDecimals,SampledParIdcs,FixedParIdcs)

DistrFun  = 'unif'  ;
SampStrategy = Config.SampStrategy;                                  
design_type = Config.DesignType;   
cd(Directory.SAFE_Sampling);
N_SimTest = Config.N_SimTest;
% Calculate number of sample points to test:
N_PointsTest = N_SimTest / (N_ParNew + 1); % see 'EET_indices.m': n~=r*(M+1)
SampleValuesMatrix = OAT_sampling(N_PointsTest,N_ParNew,DistrFun,DistrPar,SampStrategy,design_type);
cd(Directory.BASE_PATH);

% Re-convert parameters with heterogenous value ranges back from log scale
% to normal input values (here: hydr. conductivity: ksat) - (2/2):
if ~isempty(idx_Ksat)
    for idx_Sample = 1:size(SampleValuesMatrix,1)
        SampleValuesMatrix(idx_Sample,idx_Ksat) = 10^(SampleValuesMatrix(idx_Sample,idx_Ksat));
    end
end

% Plot parameter distribution (test)
% figure; plot(SampleValuesMatrix(:,1),SampleValuesMatrix(:,end),'ob')

% Round parameter values to decimals AOS can handle (user-defined):
for idx_par = 1:size(SampleValuesMatrix,2) % no. of columns = parameters
    SampleValuesMatrix(:,idx_par) = ...
        round(SampleValuesMatrix(:,idx_par),ParDecimals(idx_par));
end

% Insert parameters that are not part of sampling/ analysis, but were
% assigned a fix value (removed above):
Samples_AOS_In = nan(size(SampleValuesMatrix,1),N_ParNew + 1); % YldForm -> +1
Samples_AOS_In(:,SampledParIdcs) = SampleValuesMatrix;
for idx_FixPar = 1:size(FixedParIdcs,2)
    Samples_AOS_In(:,FixedParIdcs(idx_FixPar)) = FixParsValues(idx_FixPar);
end
