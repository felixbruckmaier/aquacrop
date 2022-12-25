%% Calculate for all tested phenology parameters (except CGC + CDC) that are
% relevant for the subsequent check within AAOS_CheckPhenologyConstraints.m
% both units Growing Degree Days (GDD); Calendar Days (CD).
function [CD_Values,GDD_Values] =...
    AAOS_ComputePhenologyUnits(GDDcumsum,TestCropParameters)

Names = string(fieldnames(TestCropParameters.InputValues));
Values = TestCropParameters.InputValues;
InputUnits = TestCropParameters.InputUnits;
GDD_Values = nan(size(InputUnits,1),1);
CD_Values = GDD_Values;

% Determine user-defined Crop Calendar Type for every phenology parameter
size(InputUnits,1)
for idx = 1:size(InputUnits,1)
    Unit = InputUnits(idx);
    Name = Names(idx);


    Value = Values.(Name);

    % translation CD<->GDD for CGC/ CDC below (-> depend on other
    % phenology parameters):
    if ismember(Name,["CDC","CGC"])
        if Unit == "CD"
            CD_Values(idx) = Value;
        elseif Unit == "GDD"
            GDD_Values(idx) = Value;
        end
    elseif ismember(Name,["CCx","SeedSize","PlantPop"])
        GDD_Values(idx) = Value;
    else

%         if Unit == "CD" % Parameter values given in CD
%             % Adjust maturity first -> other parameters will be
%             % adjusted if they exceed maturity
%             if ismember(Name,"Maturity")
%                 if Value >= find(GDDcumsum,1,'last')
%                     Value = GDDcumsum(end-1);
%                     CD_Values(1) = Value;
%                 end
%             else
% 
%                 if Value >= CD_Values(1)
%                     Value = CD_Values(1) - 2; % -2 since actual Maturity value is already Input Maturity - 1
%                 end
% 
%             end
%             CD_Values(idx) = Value;
%             GDD_Values(idx) = GDDcumsum(Value);
% 
% 
%         elseif Unit == "GDD" % Parameter values given in GDD
% 
%             if idx == 1
%                 if Value >= GDDcumsum(end)
%                     Value = GDDcumsum(end-1); % -1 since last day always excl. from AOS simulation
%                     CD_Values(1) = find(GDDcumsum,1,'last')-1;
%                 end
% 
%             else
%                 if Value >= GDD_Values(1)
%                     GDD_Values(idx) = GDD_Values(1);
%                     CD_Values(idx) = CD_Values(1);
%                 end
% 
%             end
%             CD_Values(idx) = find(GDDcumsum > Value,1,'first');
%             GDD_Values(idx) = Value;
%         end


if Unit == "CD" % Parameter values given in CD
    HarvestDayCD = find(GDDcumsum,1,'last');
    if Value >= HarvestDayCD
        Value = HarvestDayCD - 1;
    end

    CD_Values(idx) = Value;
    GDD_Values(idx) = GDDcumsum(Value);


elseif Unit == "GDD" % Parameter values given in GDD
HarvestDayGDD = GDDcumsum(end);
    if Value >= HarvestDayGDD
        Value = GDDcumsum(end-1); % -1 since last day always excl. from AOS simulation
    end

    CD_Values(idx) = find(GDDcumsum > Value,1,'first');
    GDD_Values(idx) = Value;
end
    end
end



