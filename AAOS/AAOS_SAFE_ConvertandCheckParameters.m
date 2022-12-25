%% Converts Samples_All_Input to Samples_All_Output
% ... by running 'AAOS_ConvertandCheckCropParameters.m" (-> check for details)
% for every SAFE samples of parameter values & store indices of invalid samples; 
function [Samples_Conv_All,Rows_rmvPheno] = AAOS_SAFE_ConvertandCheckParameters(...
    Config,N_ParAll,Samples_Conv_All)

% Get number of samples created by SAFE sampling:
n = size(Samples_Conv_All,1);
% Set up vec for indicating (phenologically) invalid samples:
Rows_rmvPheno = zeros(n,1);


for idx_Samples = 1:n
    % Assign current parameter values to array that is used by subsequent
    % functions:
    Config.AllParameterValues(:,1) = Samples_Conv_All(idx_Samples,:)';

    % Derive which input parameters are crop parameters:
    Config = AAOS_SeparateCropParameters(Config);

    % Convert every sample to AOS output unit & Check phenology constraints
    % for crop parameter value combinations:
    [Config, breakloop] = AAOS_ConvertandCheckParameters(Config);

    % Assign converted parameter values to respective sample:
    Samples_Conv_All(idx_Samples,:) = Config.AllParameterValues;

    % Store phenology constraints check result (0 = pass; 1 = fail):
    Rows_rmvPheno(idx_Samples,1) = breakloop;

    % Assign computed YldForm value to last column, if phenology constraints met: 
    if breakloop == 0  
        Samples_Conv_All(idx_Samples,N_ParAll + 1) = Config.AllParameterValues(end);
    else % actually unnecessary, just to crosscheck which samples are invalid:
        Samples_Conv_All(idx_Samples,:) = nan;
    end

end
% For GLUE: Just remove invalid samples: 
% Samples_Conv_All(Rows_rmvPheno==1,:) = [];
% (More complex for EE/ Morris method, see respective function)