%% Reads & stores the test variable observations for the lot, if available
% Available variables: Canopy Cover ('CC'), Soil Water Content ('SWC').
function [ObsTestVar] = AAOS_ReadTestVariableObservations(Directory,Config)

cd(Directory.AAOS_Input);

% Define variable to check whether observations are missing:
missing_obs = 0;

% Determine currently active test variable:
switch Config.TestVarNameFull

    case "CanopyCover"
    % Retrieve CC file name:
        CC_file = dir(fullfile(Directory.AAOS_Input,'*Obs*'+Config.season+'*CC*'+'_'+string(Config.LotName)+'.csv'));
        try
            CC_filename = CC_file.name ;
        catch
            CC_filename = [];
        end
        % Read CC, if available, otherwise set to 'observations missing':
        if not(isempty(CC_filename))
            missing_obs = 0;
            CC_obs_simdays0 = readtable(CC_filename,'ReadVariableNames',true);
            CC_obs_simdays = table2array(CC_obs_simdays0(2:end,1:end));
            
            obs_val_simdays = CC_obs_simdays;
            idx_subvar = 1;
        else
            missing_obs = 1;
        end

%     case "SoilWaterContent" % SWC observations already read before
%         % Check for SWC depth to be calibrated:
%         if not(ismember(Config.TestSWCidx,Config.AllSWCidx))
%             missing_obs = 1;
%         else
%             missing_obs = 0;
%             obs_val_simdays = Config.SimSWCDaysValues;
%             idx_subvar = Config.TestSWCidx;
%         end
end

if missing_obs == 0
    ObsTestVar(:,1) = obs_val_simdays(1:size(obs_val_simdays,1),1);
    ObsTestVar(:,2) = round(obs_val_simdays(1:end,1+idx_subvar),2);
elseif missing_obs == 1
    ObsTestVar = {};
end

end