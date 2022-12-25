%% Check if soil hydrology parameters (SHP) are realistic; i.e., meet the
% constraint "Permanent Wilting Point < Field Capacity < Saturation";
% ("th_wp" < "th_fc" < "th_s"):
function breakloop = AAOS_CheckSoilHydrologyConstraints(SHP_Values)

breakloop = 0;

if (SHP_Values.th_wp > SHP_Values.th_fc) | ...
        (SHP_Values.th_fc > SHP_Values.th_s)
    breakloop = 1;
end