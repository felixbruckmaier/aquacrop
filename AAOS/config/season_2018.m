%% Soil Water Content (SWC):
% 1.) Initial SWC:
Config.IrrDepth = 5; % cm
% 1.a) Define soil depths (centerpoints [m]) to be assigned an initial SWC value
Config.SWC_sim = [0.01 0.03 0.1 0.165 2.15];

% 1.b) Method for how to substitute missing Ini SWC observations defined in 1.a):
% here: automatically determined:
Config.SWC_subs_method = 1;


%% Select plots to test:
% a) Calibration -> Always manual selection
% Options: x; [x y..];
% CURRENTLY NOT WORKING: 0 (= all plots)
% HERE: AUTOMATIC DETERMINATION:

% choose from pool of working plots: [2 7 8 9 10 12 13 14 17 18 19 20 21 23 24 29]
Config.CalibrationConfig = {};
Config.CalibrationLots = [9 10 14 18 21 23 24 29];
Config.ValidationLots = [2 7 8 12 13 17 19 20];


% "DEF"/ "CAL"/ "VAL": Choose target variable(s): CC (1), SWC (2), HI (3):
% "GSA" / "STRQ": Irrelevant (autom. resetting)
Config.TargetVarNum = [1 2]; % Options: [1 2] / [1 2 3]; not working yet: [1] / [2]


% No. of irrigation files;
% No. of soil layers (here also = depths) - must agree with AOS input files
Config.IrrDiff = 0; % "0" = 1 general irrigation file/ "1" = plot-specific
Config.NoSoilLayer = 2;
Config.TestSWCidx = 1; % 2018: only 1 depth available


% Calculate overall mean values from individual plot observations & simulations:
% Insert for both calibration variables (CC & SWC):
% 1) Obs. days, 2) Obs. values, 
% FinalVar valus (BM):
Config.mean_obs = 10.37; % Observation
% Simulated values:
Config.finalvarsim_mean(1,1:2) = 9.15; % Default
Config.finalvarsim_mean(2,:) = 10.59; % 1. calib round (CC_CAL / SWC_REC)
Config.finalvarsim_mean(3,:) = 10.9; % 2. calib round (SWC_CAL / CC_REC)

% Calibration variable values (CC / SWC):
Config.CC_obs(:,1) = [36   44  55  59  68  83  90  99];
Config.CC_obs(:,2) = [0.36 0.59    0.81    0.86    0.87    0.82    0.8 0.7];
Config.SWC_obs(:,1) =  [14 15  16  17  18  19  20  21  22  23  24  25  26  27  28  29  30  31  32  33  34  35  36  37  38  39  40  41  42  43  44  45  46  47  48  49  50  51  52  53  54  55  56  57  58  59  60  61  62  63  64  65  66  67  68  69  70  71  72  73  74  75  76  77  78  79  80  81];
Config.SWC_obs(:,2) =  [0.0771 0.0981  0.11    0.1138  0.1075  0.1094  0.1556  0.1553  0.1427  0.134   0.128   0.1867  0.2863  0.2544  0.2325  0.2181  0.2125  0.2025  0.1975  0.2063  0.1669  0.1663  0.1844  0.1788  0.1713  0.17    0.1744  0.1713  0.1675  0.1088  0.1964  0.3055  0.3653  0.3207  0.2833  0.256   0.2427  0.2333  0.2233  0.214   0.2007  0.1947  0.1867  0.1793  0.172   0.2533  0.368   0.34    0.3047  0.2736  0.25    0.2291  0.2136  0.2045  0.1936  0.1873  0.1836  0.1782  0.1718  0.1709  0.3064  0.4018  0.4227  0.4382  0.3927  0.3645  0.3364  0.3164];
Config.CC_sim_mean(:,1) = [0.33    0.43    0.64    0.66    0.73    0.71    0.66    0.51];
Config.CC_sim_mean(:,2) = [0.46    0.55    0.75    0.78    0.85    0.86    0.81    0.68];
Config.CC_sim_mean(:,3) = [0.48    0.6 0.8 0.82    0.88    0.88    0.83    0.7];
Config.SWC_sim_mean(:,1) =     [0.22   0.21    0.21    0.2 0.2 0.19    0.19    0.18    0.18    0.17    0.16    0.18    0.19    0.19    0.18    0.17    0.16    0.15    0.14    0.13    0.1294  0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.21    0.21    0.2 0.19    0.17    0.16    0.14    0.13    0.12    0.12    0.12    0.12    0.12    0.12    0.25    0.2487  0.2213  0.2 0.1809  0.16    0.13    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.37    0.41    0.42    0.35    0.31    0.2809  0.2509  0.2209];
Config.SWC_sim_mean(:,2) =     [0.2193 0.21    0.2019  0.1994  0.1906  0.1894  0.1813  0.1787  0.17    0.16    0.158   0.17    0.18    0.1719  0.1694  0.1594  0.1425  0.1325  0.1225  0.1206  0.1188  0.1188  0.1188  0.1106  0.1106  0.1106  0.1106  0.1106  0.1106  0.11    0.1109  0.2082  0.2087  0.1907  0.1787  0.1613  0.1487  0.1293  0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.25    0.25    0.22    0.2 0.18    0.1573  0.13    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.12    0.3609  0.41    0.42    0.35    0.3 0.2709  0.2409  0.2118];
Config.SWC_sim_mean(:,3) =     [0.2507 0.2413  0.2325  0.2294  0.2213  0.2188  0.2119  0.204   0.1947  0.1873  0.178   0.216   0.2294  0.2213  0.22    0.21    0.1994  0.1825  0.1719  0.1619  0.1544  0.1519  0.1488  0.1475  0.1475  0.1475  0.1475  0.1475  0.1475  0.1413  0.1382  0.2582  0.268   0.2573  0.2393  0.2273  0.2093  0.1893  0.1707  0.152   0.1487  0.1487  0.1487  0.1487  0.1487  0.3193  0.3127  0.2847  0.2587  0.2364  0.2127  0.1845  0.1609  0.1482  0.1482  0.1482  0.1482  0.1482  0.1482  0.1482  0.4018  0.4318  0.4464  0.3591  0.3164  0.2855  0.2555  0.2264];