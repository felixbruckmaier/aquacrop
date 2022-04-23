function GSA_OAT

global extrainput;

[Y_def] = GSA_ReadSimOutput();
GDD_daily = table2array(sim_cropgrowth((1:end-1),6));
GDD_cumsum = cumsum(GDD_daily);
extrainput.GDDsum = GDD_cumsum;

% Define parameters with potentially conflicting bounds
extrainput.PhenoConflictParsNames =...
    ["Emergence";"HIstart";"Flowering";"YldForm";"Senescence";"MaxCC"];
extrainput.MaxCCcalcNames =...
    ["PlantPop";"SeedSize";"CCx";"CGC"];
% Set up array for parameter GDD values
allconflict = 0;
extrainput.PhenoConflictParsVal = zeros(size(extrainput.PhenoConflictParsNames,1),1,'double');

% 
% if allconflict == 1
%     disp("No "+extrainput.TestVarName+" measurements available for current plot"+...
%         "-> Switching to next variable/plot, resp. discard analysis.");
% else




% Number of uncertain parameters subject to SA:                                
M    = extrainput.TestParsNumber;             

% Parameter ranges:
xmin = lowlim_test';
xmax = upplim_test';

    % Adjust figure dimensions (acc. to number of parameters M, but min = 13)
    % (Excel-cell-dependent)
    fig_height = excelcell_height * max(13,M + 3); % cells * cell height
    fig_width = excelcell_width * 7; % cells * cell width


% Parameter distributions:                                                     
DistrFun  = 'unif'  ;                                                          
DistrPar = cell(M,1);

for i=1:M; DistrPar{i} = [ xmin(i) xmax(i) ];
end

% Name of parameters (will be used to customize plots):
X_labels = {};
X_labels(1) = cellstr(plotvar_name); % plot title
testparsnames = extrainput.AllParsNames(extrainput.FixvsTestPars == 0);
disp(testparsnames);
X_labels(2:length(testparsnames)+1) = testparsnames;

disp("X_labels");
disp(X_labels);
% Define output:
 
myfun = 'GSA_RUN' ;                                                          
                                                                               
%% Step 3 (sample inputs space)                                                




r = EE_num ; % Number of Elementary Effects
% needs to be here to be able to be resetted on user-defined value 

% option 1: use the sampling method originally proposed by Morris (1991):      
% L = 6  ; % number of levels in the uniform grid                              
% design_type  = 'trajectory'; % (note used here but required later)           
% X = Morris_sampling(r,xmin,xmax,L); % (r*(M+1),M)                            
disp("M: "+M);                                                                               
% option 2: Latin Hypercube sampling strategy                                  
SampStrategy = 'lhs' ; % Latin Hypercube
design_type = 'radial'; 
%design_type = 'radial';                                                        
% other options for design type:                                               
%design_type  = 'trajectory';

[X,r] = OAT_sampling(r,M,DistrFun,DistrPar,SampStrategy,design_type,extrainput);
disp("r: "+r);
% NEW: round Xnew:
for idx_par = 1:size(X,2) % no. of columns = parameters
for idx_sample = 1:size(X,1) % no. of rows = samples
X(idx_sample,idx_par) = round(X(idx_sample,idx_par),extrainput.AllParsDec(extrainput.TestParsIdx(idx_par)));
end
end
                                                                             
%% Step 4 (run the model)
% SA_Calib_Initialize(par_number,index_test_par,par_names,...
%     SWC_par_names,SWC_val_used,par_type,val_testpar,val_rest) 
Y = model_evaluation(myfun,X,extrainput) ; % size (r*(M+1),1)              
                                                                               
%% Step 5 (Computation of the Elementary effects)                              
  
%% RECENT ERROR:
% Compute Elementary Effects:                                                  
[ mi, sigma ] = EET_indices(r,xmin,xmax,X,Y,design_type);    
                  
% USING BM AS Y:
% Error using EET_indices (line 102)
% 'Y' must be a column vector
% % Error in workflow_eet_AOS (line 149)
% [ mi, sigma ] = EET_indices(r,xmin,xmax,X,Y,design_type);
                                                                               
% Plot results in the plane (mean(EE),std(EE)):                                
EET_plot(mi,sigma,X_labels);

set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])
fig_row = ceil((idx_array - 1) * (2 *fig_height - 1)) + 1;
Excel = actxserver('Excel.Application');
Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file
xlswritefig(gcf,filename,1,string("A"+fig_row));

% %% TEMPORARY EXCLUDED
% % Use bootstrapping to derive confidence bounds:                               
% Nboot=100;                                                                     
% [mi,sigma,EE,mi_sd,sigma_sd,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...               
% EET_indices(r,xmin,xmax,X,Y,design_type,Nboot);                                
%                                                                                
% % Plot bootstrapping results in the plane (mean(EE),std(EE)):                  
% EET_plot(mi,sigma,X_labels,mi_lb,mi_ub,sigma_lb,sigma_ub)
% set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])
% xlswritefig(gcf,filename,count_partest,string("J"+fig_row));


% %% TEMPORARY EXCLUDED
% % Repeat computations using a decreasing number of samples so as to assess     
% % if convergence was reached within the available dataset:                     
% rr = [ r/5:r/5:r ] ;
% disp(rr);
% % NEW: Round r
% for i = 1:5
%     rr(i) = round(rr(i));
% end
% disp(rr);
% m_r = EET_convergence(EE,rr);                                                  
% % Plot the sensitivity measure (mean of elementary effects) as a function      
% % of model evaluations:                                                        
% figure; plot_convergence(m_r,rr*(M+1),[],[],[],...                             
% 'no of model evaluations','mean of EEs',X_labels)                              
%                                                                                
% % Repeat convergence analysis using bootstrapping:                             
% Nboot = 100;                                                                   
% rr = [ r/5:r/5:r ] ;  
% % NEW: Round r
% for i = 1:5
%     rr(i) = round(rr(i));
% end
% disp(rr);
% [m_r,s_r,m_lb_r,m_ub_r] = EET_convergence(EE,rr,Nboot);                        
% % Plot the sensitivity measure (mean of elementary effects) as a function      
% % of model evaluations:                                                        
% figure; plot_convergence(m_r,rr*(M+1),m_lb_r,m_ub_r,[],...                     
% 'no of model evaluations','mean of EEs',X_labels)                              

timer1 = toc;
timer1 = timer1/60 % mins.
sim_cropgrowth = readtable(ACoutput_filename,'ReadVariableNames',false);

% %% Step 6 (Adding up new samples)                                              
%                                                                                
% r2 = 100 ; % increase of base sample size                                      
% [X2,Xnew,r2] = OAT_sampling_extend(X,r2,DistrFun,DistrPar,design_type,extrainput,1);% extended 
% % sample (it includes the already evaluated sample 'X' and the new one)        
%                            
% % NEW: round Xnew:
% for idx_par = 1:size(Xnew,2) % no. of columns = parameters
% for idx_sample = 1:size(Xnew,1) % no. of rows = samples
% Xnew(idx_sample,idx_par) = round(Xnew(idx_sample,idx_par),extrainput.extrainput.AllParsDec(extrainput.TestParsIdx(idx_par)));
% end
% end
% %  extrainput = {N_parall,N_partest,names_all,names_test,names_fix,type_all,val_all,log_fix,dec_all,idxs_test};
%                                                
% % Evaluate model against the new sample                                        
% Ynew = model_evaluation(myfun,Xnew,extrainput) ; % size((r2-r)*(M+1),1)    
%                                                                                
% % Put new and old results together                                             
% Y2=[Y;Ynew]; % size (r2*(M+1),1)                                               
%                                                                                
% % Recompute indices                                                            
% Nboot=100;                                                                     
% [mi_n,sigma_n,EEn,mi_sdn,sigma_sdn,mi_lbn,sigma_lbn,mi_ubn,sigma_ubn] = ...      
% [mi_n,sigma_n] = ...      
% EET_indices(r2,xmin,xmax,X2,Y2,design_type,Nboot); 
% EET_plot(mi_n,sigma_n,X_labels,mi_lbn,mi_ubn,sigma_lbn,sigma_ubn)
 
%                                                                                
% % Repeat convergence analysis                                                  
% Nboot = 100;                                                                   
% rr2 = [ r2/5:r2/5:r2 ] ;                                                       
% [m_rn,s_rn,m_lb_rn,m_ub_rn] = EET_convergence(EEn,rr2,Nboot);                  
% % Plot the sensitivity measure (mean of elementary effects) as a function      
% % of model evaluations:                                                        
% figure; plot_convergence(m_rn,rr2*(M+1),m_lb_rn,m_ub_rn,[],...                 
% 'no of model evaluations','mean of EEs',X_labels)
% end

ParvsVar_plot(1:size(X,1),1) = Y; % all simulated output variables on current plot
ParvsVar_plot(:,2:size(X,2)+1) = X; % all tested input parameters on current plot
%% CHANGE! here: only valid for max (= NSE, R2) -> missing: yield deviation, RMSE?
[~,row_best] = max(Y); % for best simulation, determine position in output vector
ParvsVar_plot_best(idx_plot,7,idx_vartest) = Y(row_best); % all simulated output variables on current plot
ParvsVar_plot_best(idx_plot,8:size(X,2)+7,idx_vartest) = X(row_best,:); % all tested input parameters on current plot



Var_all(1:size(Y,1),idx_plot,idx_vartest) = Y; % all simulated output variables on all plots (accumulating during loop)
ParsvsVar_all.(extrainput.TestVarName).(plot_name) = ParvsVar_plot;
ParvsVar_plot = [];

extrainput.TestParsValues = X(row_best,:);
testparidx_old = extrainput.TestParsIdx;
var_name_temp = extrainput.TestVarName;
extrainput.TestVarName = "Yield";
% Run simulation with best parameter values to retrieve best yield
GSA_Initialize(extrainput.TestParsVals,extrainput);
while AOS_ClockStruct.ModelTermination == false
    AOS_PerformTimeStep();
end
AOS_Finish();

[yield_best] = GSA_ReadSimOutput(extrainput);
ParvsVar_plot_best(idx_plot,1,idx_vartest)...
    = 100*abs(extrainput.ObsYield(idx_plot,2) - yield_best)/extrainput.ObsYield(idx_plot,2);
ParvsVar_plot_best(idx_plot,2,idx_vartest)=yield_best;
ParvsVar_plot_best(idx_plot,3,idx_vartest)...
    = 100*abs(extrainput.ObsYield(idx_plot,2) - yield_def)/extrainput.ObsYield(idx_plot,2);
ParvsVar_plot_best(idx_plot,4,idx_vartest)=yield_def;
ParvsVar_plot_best(idx_plot,5,idx_vartest)=extrainput.ObsYield(idx_plot,2);
ParvsVar_plot_best(idx_plot,6,idx_vartest)=Y_def;

extrainput.TestVarName = var_name_temp; % reset variable name to calibration variable



