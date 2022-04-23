
% Script tayloring the SAFE toolbox to AquaCrop-OS Global Sensitivity
% & Uncertainty Analysis.
%
% The analysis is based on the Elementary Effects Test (EET) or 'method of
% Morris' (Morris, 1991; Saltelli et al., 2008), and uses the application
% example "workflow_eet_hymod.m" from the SAFE toolbox               
% of the Elementary Effects Test. Useful to get started with the EET.          
%                                                                              
% METHOD                                                                       
%                                                                                                                                                  
% The EET is a One-At-the-Time method for global Sensitivity Analysis.         
% It computes two indices for each input:                                      
% i) the mean (mi) of the EEs, which measures the total effect of an input     
% over the output;                                                             
% ii) the standard deviation (sigma) of the EEs, which measures the degree     
% of interactions with the other inputs.                                       
% Both sensitivity indices are relative measures, i.e. their value does not    
% have any specific meaning per se but it can only be used in pair-wise        
% comparison (e.g. if input x(1) has higher mean EEs than input x(3) than      
% x(1) is more influential than x(3)).                                         
%                                                                                                                                                                                        
% MODEL AND STUDY AREA                                                         
%                                                                                                      
%                                                                              
% INDEX                                                                        
%                                                                              
% Steps:                                                                       
% 1. Add paths to required directories                                         
% 2. Load data and set-up the HBV model                                        
% 3. Sample inputs space                                                       
% 4. Run the model against input samples                                       
% 5. Compute the elementary effects                                            
% 6. Example of how to repeat computions after adding up new                   
%    input/output samples.                                                     
%                                                                              
% REFERENCES                                                                   
%                                                                              
% Morris, M.D. (1991), Factorial sampling plans for preliminary                
% computational experiments, Technometrics, 33(2).                             
%                                                                                         
%                                                                              
% Saltelli, A., et al. (2008) Global Sensitivity Analysis, The Primer,         
% Wiley.                                                                       
%                                                                                                                                                             
% This script prepared by Francesca Pianosi and Fanny Sarrazin                 
% University of Bristol, 2014                                                  
% mail to: francesca.pianosi@bristol.ac.uk                                     
                                                                               
tic
fclose ('all'); % Close open files
% clear extrainput;
global AOS_ClockStruct
global extrainput

%% Step 1 (add paths)
% a) Desktop
% D_AOS = 'C:\AquaCropOS_v60a';
% D_SAFE = 'C:\safe_R1.1';
% D_AOSInput = 'C:\AquaCropOS_v60a\Input';
% D_CalibInput = 'C:\AquaCropOS_v60a\Calibration_SA\Input_Obs';
% a) Remote
season = "2019"; % here: 2018 or 2019

Excel = actxserver('Excel.Application');
% Excel.ActiveWorkbook.Save;
Excel.Quit; % Shut down Excel (= any open files)
Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file

% extrainput = struct;
extrainput.season = season;
D_AOS = "H:\AquaCropOS_v60a";
D_SAFE = "H:\safe_R1.1";
D_AOSInput = "H:\AquaCropOS_v60a\Input\"+season+"\";
D_AOSOutput = "H:\AquaCropOS_v60a\Output\"+season+"\";
extrainput.Directory.AOS(1) = D_AOSInput;
extrainput.Directory.AOS(2) = D_AOSOutput;
D_Calib = "H:\AquaCropOS_v60a\Calibration_SA\";
D_CalibInput = "H:\AquaCropOS_v60a\AAOS\AAOS_Input\"+season+"\";
D_CalibOutput = "H:\AquaCropOS_v60a\AAOS\AAOS_Output\"+season+"\";
% extrainput.Directory.AAOS = D_Calib;
currentday_full = clock;
currentday = string(currentday_full(:,1))+string(currentday_full(:,2))+string(currentday_full(:,3));
extrainput.Directory.AAOS_Input = D_CalibInput;
extrainput.Directory.AAOS_Output = D_CalibOutput;

plotstotest = 0; % [x x]; 0 = all plots
% [8 9 13 14 18 19 24] CC
% [5 7 8 9 10 11 14 15 16 17 20 21 22 23 24 26] SWC




%% Soil Hydrology
extrainput.NoSoilLayer = 2; % (here also = depths); must agree with AOS input files!
extrainput.TestSWCidx = 1;
% Which value to assign at missing SWC depths: "FC" = field capacity;
% "EQ" = equal to adjacent value; "IP" = interpolate b/w 2 adj. values
extrainput.MissingSWC.DepthMiddle = "FC"; % b/w 2 depths w/ values: "FC" or "IP"
extrainput.MissingSWC.DepthEdge = "FC"; % last or first depth: "FC" or "EQ"
% Which value to assign at 1. Simulation Day (for all depths) = "FC"; % only "FC" possible

extrainput.IrrDiff = 0; % "0" = 1 irrigation file for all plots; "1" different files

EE_num = 20; % Number of Elementary Effects to be tested; >= 4?
extrainput.GoF = "NSE";
extrainput.RUN_type = "GDD"; % "DEF"; "GSA"
% if RUN_type = GGD:
% 1. Select types for which parameter input files shall be written
extrainput.WriteParFiles = ["TUNE","CAL"]; % TUNE & CAL
% 2. Choose parameters whose ranges are to be determined, by
% transforming the AquaCrop Manual ranges [GDD] into [CD]:
extrainput.PhenoNamesGDD = ["Emergence", "Senescence", "HIstart", "Flowering",];
extrainput.PhenoRangesGDD = [100,1000,1000,150; 250,2000,1300,280]; % 1. row = lower / 2. row = upper bound

% output variable to be tested (only OAT single, or OAT subsequently):
% 1 = "Canopy Cover"; 2 = "Soil Water Content"; 3 = "Biomass"; 4 = "Yield"
idxs_vartest = [1 2];
% Input parameters to be tested -> use idx used in parameter input file
% 0 = all parameters (at the same time); 1 = CC-/Phenology vs 2 = Soil (Water) parameters
idxs_partest = [1 2]; % not relevant when choosing "DEF"
% (dim. must correspond to idx_vartest)



% Excel = actxserver('Excel.Application');
% Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file

addpath(genpath(D_SAFE))
addpath(genpath(D_AOS))
addpath(genpath(D_AOSInput))




% Set current directory to 'my_dir' and add path to sub-folders:    
[FileLocation] = AAOS_ReadFileLocations();
extrainput.ACout_filename = append(FileLocation.OutputFilename,'_CropGrowth');

% Excel cell dinensions:
excelcell_width = 2.1;
excelcell_height = 0.45;

                                              
                                       




GSA_ReadObsGeneral();

ParsvsVar_all = struct;
if plotstotest == 0
    plotstotest = extrainput.FinalVarObsAllPlots(:,1);
end

if extrainput.RUN_type == "GDD" ; plotstotest = plotstotest(8); end
if extrainput.RUN_type == "GSA" ; allplotsout_name = "AllPlotsBestSim";
else ; allplotsout_name = "AllPlotsSim";
end
if extrainput.RUN_type == "TUNE" ; N_parsfiles = 2;
else ; N_parsfiles = 1;
end

filename_testvar = "_";
for idx_vartest = idxs_vartest
    GSA_SwitchVar(idx_vartest);
    filename_testvar = append(filename_testvar,extrainput.TestVarName,"_");
end



% Automatically determine name of the excel output file
extrainput.OutputFileName = currentday+"_"+extrainput.season+extrainput.RUN_type...
    +filename_testvar+"on_"+extrainput.GoF+"_"+extrainput.FinalVarName+"_FINAL2.xlsx";

% Loop through parameters input files (1 or 2)
for parfile_idx = 1:N_parsfiles; extrainput.ParFileIdx = parfile_idx;
GSA_ReadParInputPlotGeneral();
% Loop through plots
for testplot_idx = 1:numel(plotstotest)
    extrainput.PlotIdxTest = testplot_idx;                               

    
    extrainput.PlotIdxAll = plotstotest(testplot_idx);
        plot_name = "Plot"+string(extrainput.PlotIdxAll);




% Loop through variables
count_partest = 1;
extrainput.CountTestVar = 1;
for idx_vartest = idxs_vartest
    
    GSA_SwitchVar(idx_vartest);
    idx_partest = idxs_partest(count_partest);
    % Create figure title: "PlotXonY"; Y = tested (target) variable
    plotvar_name = plot_name+"on"+extrainput.TestVarName;
    if extrainput.TestVarName == "SoilWaterContent"
        plotvar_name = plotvar_name+"#"+extrainput.TestSWCidx;
    end





[lowlim_test,upplim_test]...
    = GSA_ReadParInputPlotTest(idx_partest);

% if idx_vartest == 2 && length(idxs_vartest) > 1 % if 2 variables calibrated subsequently...
%     if extrainput.RUN_type == "TUNE" % ... and "fine-tuning" is selected...
%     disp(extrainput.AllParsVals(testparidx_old));
%     disp(extrainput.TestParsVals');
% extrainput.AllParsValues(testparidx_old) = extrainput.TestParsVals';
% % ... assign best parameters values from previously calibrated variable.
%     end
% end

extrainput.TestParsVals = []; % set test values to zero for subsequent default simulation

 GSA_WriteIniSWCandIrrigation(D_CalibInput,extrainput.PlotIdxAll);
 % if calibration variable = final output variable (only Biomass or Yield)
if extrainput.TestVarName == extrainput.FinalVarName
    var_obs = extrainput.FinalVarObsAllPlots(extrainput.PlotIdxAll);
else
    var_obs = GSA_ReadObsSpecific(D_CalibInput,extrainput.PlotIdxAll);
end
if isempty(var_obs)
    disp("No "+extrainput.TestVarName+" measurements available for current plot"+...
        "-> Switching to next variable/plot, resp. discard analysis.");
else
extrainput.TestVarObs = var_obs;


switch extrainput.RUN_type
    case {"GDD" , "DEF", "TUNE"} ; AAOS_SingleRuns;
      % GDD: Get Growing Degree Days & determine phenology parameter ranges
      % DEF: Run 1 simulation: (e.g. w/ default OR tuned parameters)
      % TUNE: Run 2 simulations (e.g. w/ default AND tuned parameters)
    case "LSA" % Run local sensitivity analysis via AAOS toolbox (own tool)
    case "GSA"; GSA_OAT; % Run global sensitivity analysis via SAFE toolbox
    case "OATC" % Run One-at-a-time calibration via AAOS toolbox (own tool)
    case "AATC" % Run All-at-a-time calibration via DREAM toolbox
end


end
count_partest = count_partest+1;
extrainput.CountTestVar = extrainput.CountTestVar + 1;
end
end
end

% for idx_vartest = idxs_vartest
% GSA_SwitchVar(idx_vartest);
% ParsvsVar_all.(extrainput.TestVarName).AllPlotsModelOut = Var_all(:,:,idx_vartest);
% ParsvsVar_all.(extrainput.TestVarName).(allplotsout_name) = ParvsVar_plot_best(:,:,idx_vartest);
% end

fclose ('all'); % Close open files
actxserver('Excel.Application').Quit;
timer = toc;
timer = timer/60; % mins.
disp("Time elapsed: "+timer+" mins.");
