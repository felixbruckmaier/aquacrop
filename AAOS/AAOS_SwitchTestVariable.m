%% Determines the name of the test variable for the given index
% Available variables: Canopy Cover, Soil Water Content, Harvest Index:
function [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(VarIdx)

% Get full variable name:
    switch VarIdx
        case 1
            TestVarNameFull = 'CanopyCover';
        case 2
            TestVarNameFull = 'SoilWaterContent';
        case 3
            TestVarNameFull = 'HarvestIndex';
    end

% Store abbreviated variable name as string:
idx = isstrprop(TestVarNameFull,'upper');
TestVarNameShort = string(upper(TestVarNameFull(idx)));

% Store full variable name as string:
TestVarNameFull = string(TestVarNameFull);