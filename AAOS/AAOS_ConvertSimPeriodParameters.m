%% Temporarily converts the sim period parameter units to serial format
function [SimPeriodVals,SimPeriodValsDef,LocY_SimPeriod] =...
    AAOS_ConvertSimPeriodParameters(Config,ParNames,ParValues)

SimPeriodPars = {'PlantingDate','HarvestDate','Maturity'};
[LocX_SimPeriod,LocY_SimPeriod] = ismember(ParNames,SimPeriodPars);
SimPeriodValsDef = Config.SimPeriodValsDef;
SimPeriodVals(1:3) = SimPeriodValsDef;
SimPeriodVals(LocY_SimPeriod(LocY_SimPeriod>0)) = ParValues(LocX_SimPeriod);
% Converts Planting or Harvest Date if any SimPeriod-relevant parameter
% (=including Maturity) included in the analysis:
if any(SimPeriodVals ~= SimPeriodValsDef)
    Format = 'ddmmyyyy';
    Dates = SimPeriodVals(1:2);
    DatesString = string(Dates);
    DatesSerial = datenum(DatesString,Format);
    SimPeriodVals(1) = - (DatesSerial(1)); % PlantingDate: negative to easify...
    % ... later comparison with AOS default values;
    SimPeriodVals(2) = DatesSerial(2);
end