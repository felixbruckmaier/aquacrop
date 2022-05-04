%% Calculates currently active goodness of fit criteria (A, B, or C)
% for the given simulated & observed values of the current target variable.
% Available GoF: R2, RMSE, NSE.
function Config = AAOS_ModelEval_CalculateGoF(Config,SimValues,ObsValues)

% GoF is only meaningful for timeseries with >1 value -> Check length of
% observation timeseries and dont calculate GoF if there is only one value:
if size(SimValues,1) == 1
    GoFs_val = nan(3,1);

else
    % For timeseries with >1 value -> Determine active GoF and calculate value:

    % A) Calculate R2:
    if find(strcmp(Config.GoF,"R2"))
        % R2 is only meaningful for timeseries with >2 value -> Check length
        % length of observation timeseries and dont calculate R2 if there
        % are <=2 values:
        if size(SimValues,1) == 2
            GoFs_val(1) = nan;
        else

            % For timeseries with 21 value -> Calculate & store R2:
            R = corrcoef(ObsValues(:,2),SimValues);
            if isnan(R(1,2)) % Formula would yield "NaN" -> Set R2 to "0"
                R2 = 0;
            else
                R2 = R(1,2)^2;
            end
            GoFs_val(1) = R2;
        end
    end

    % B) Calculate & store RMSE:
    if find(strcmp(Config.GoF,"RMSE"))
        GoFs_val(2) = sqrt(mean((ObsValues(:,2)-SimValues).^2));
    end

    % C) Calculate & store NSE:
    if find(strcmp(Config.GoF,"NSE"))
        E = ObsValues(:,2) - SimValues;
        SSE = sum(E.^2);
        u = mean(ObsValues(:,2));
        SSU = sum((ObsValues(:,2) - u).^2);
        NSE = 1 - SSE/SSU;
        GoFs_val(3) = NSE;
    end
end

% Store GoF value in temporary SimOut array:
Config.SimOutTemp(:) = round(GoFs_val(:),2);
end
