%% Adjusts the default simulation period, if any of the user input values
% for simulation period-relevant parameters, Planting Date, Harvest Date, or
% Maturity exceeds the default simulation period start or end, respectively 
function SimDays = AAOS_DetermineSimPeriodAdjustment(SimDaysDef,SimDays)


% Calculate the difference in days b/w original and user-input simulation
% period for all 3 parameters (see above)
DaysDiff = SimDays - SimDaysDef;

% Harvest Date and Maturity (Days) both define end of SimPeriod -> choose
% the dominating one
[~,idx_SimEnd] = max(DaysDiff(2:3));
if idx_SimEnd == 2
    DaysDiff(2) = DaysDiff(3);
    SimDays(2) = SimDaysDef(2) + DaysDiff(3);
end
% Delete Maturity (adjusted later; here only Planting & Harvest Date needed):
SimDays(3) = [];
DaysDiff(3) = [];
% transform PlantingDate back to its correct value:
SimDays(1) = - (SimDays(1));