Soil = struct;
Soil.nLayer = 1;
Soil.Layer = {};
Soil.Layer.Clay = 0.7;
Soil.Layer.Sand = 0.0133;
Soil.Layer.OrgMat = 0.012;

[thdry,thwp,thfc,ths,ksat] = AOS_SoilHydraulicProperties(Soil)