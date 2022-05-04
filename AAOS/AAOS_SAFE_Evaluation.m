function AAOS_SAFE_Evaluation(Directory,Config,N_Par,ValueMatrix,ParNames)

% Define output:
myfun = 'AAOS_SAFE_Morris' ;  

% Define title of graphical output plot:
X_Labels(1) = cellstr("Season "+Config.season+"/ Plot #"+...
string(Config.LotName)+": All Parameters on "+string(Config.TargetVar.NameFull )+Config.RUN_type);
X_Labels(2:N_Par+1) = ParNames(1:N_Par);

                                                                    
%% Step 4 (run the model)

cd(Directory.SAFE_Sampling);
Y = model_evaluation(myfun,ValueMatrix,Directory,Config) ; % size (r*(M+1),1)
cd(Directory.BASE_PATH);
Yalt = Y;
X = ValueMatrix(:,1:N_Par);
Y(Y==-999) = 0; % AOS sets variables to -999 when plant dies before designated harvest -> set to 0 instead
% Remove invalid runs (unrealistic parameter combinations):
[row,~] = find(all(isnan(Y),2));
Y(row,:) = [];
X(row,:) = [];
% Isolate final variable values:
FinalVarSim = Y(:,end);

%% GLUE
TestVarObs = Config.TestVarObs;
AAOS_GLUE(X,Y, FinalVarSim,X_Labels)



aux = 0;
if aux == 1
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
    EET_plot(mi,sigma,X_Labels);

    cd(Directory.AAOS_Output);
    set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])
    fig_row = ceil((Config.PlotIdxAll - 1) * (2 *fig_height - 1)) + 1;
    Excel = actxserver('Excel.Application');
    Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file
    xlswritefig(gcf,Config.OutputFileName,1,string("A"+fig_row));
    hold off;
    % clf(gcf);

    
    for idx = 1:size(Config.FinalVarObsAllPlots,2)-2
        finalvar = Config.FinalVarObsAllPlots(Config.PlotIdxAll,idx+2);
        if Config.FinalVarRunType(idx,5) == ' '
            LineStyle = '-';
        else
            LineStyle = '--';
        end
        switch Config.FinalVarRunType(idx,1:2)
            case 'OB'
                Color = 'g';
            case 'DE'
                Color = 'b';
            case 'CC'
                Color = 'r';
            case 'SW'
                Color = 'm';
        end

        line([finalvar,finalvar],ylim,'LineWidth',2,'LineStyle',LineStyle,...
            'Color',Color);

        legendtext = horzcat(legendtext,string(Config.FinalVarNameAbbr+" ("...
            +Config.FinalVarRunType(idx,:)+") = "+finalvar));
    end
    title("Season "+Config.season+"/ Plot #"+Config.PlotIdxAll...
        +": All Parameters on "+string(Config.FinalVarName)+...
        " ("+string(Config.FinalVarNameAbbr)+") - Single Runs & UQ");
    legend(legendtext,'Orientation','horizontal','Location','southoutside',...
        'NumColumns',3);
    xlabel(Config.FinalVarNameAbbr+'[t/ha]');
    ylabel('UQ: No. of runs');
    xlswritefig(gcf,Config.OutputFileName,1,string("H"+fig_row));
    clf(gcf);
    ParvsVar_plot(1:size(X,1),1) = Y; % all simulated output variables on current plot
    ParvsVar_plot(:,2:size(X,2)+1) = X; % all tested input parameters on current plot
    Config.("UQ"+"on"+Config.FinalVarNameAbbr+Config.season).("Plot"+Config.PlotIdxAll)(1,1)...
        = Config.FinalVarNameAbbr;
    Config.("UQ"+"on"+Config.FinalVarNameAbbr+Config.season).("Plot"+Config.PlotIdxAll)(1,2:size(X,2)+1)...
        = Config.TestParsNames;
    Config.("UQ"+"on"+Config.FinalVarNameAbbr+Config.season).("Plot"+Config.PlotIdxAll)(2:size(X,1)+1,:)...
        = ParvsVar_plot;
end

timer1 = toc;
timer1 = toc/60 % mins.
;
% %% TEMPORARY EXCLUDED
% % Use bootstrapping to derive confidence bounds:
% Nboot=100;
% [mi,sigma,EE,mi_sd,sigma_sd,mi_lb,sigma_lb,mi_ub,sigma_ub] = ...
% EET_indices(r,xmin,xmax,X,Y,design_type,Nboot);
%
% % Plot bootstrapping results in the plane (mean(EE),std(EE)):
% EET_plot(mi,sigma,X_Labels,mi_lb,mi_ub,sigma_lb,sigma_ub)
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


%


% %% Step 6 (Adding up new samples)
%
% r2 = 100 ; % increase of base sample size
% [X2,Xnew,r2] = OAT_sampling_extend(X,r2,DistrFun,DistrPar,design_type,Config,1);% extended
% % sample (it includes the already evaluated sample 'X' and the new one)
%
% % NEW: round Xnew:
% for idx_par = 1:size(Xnew,2) % no. of columns = parameters
% for idx_sample = 1:size(Xnew,1) % no. of rows = samples
% Xnew(idx_sample,idx_par) = round(Xnew(idx_sample,idx_par),Config.Config.AllParsDec(Config.TestParsIdx(idx_par)));
% end
% end
% %  Config = {N_parall,N_partest,names_all,names_test,names_fix,type_all,val_all,log_fix,dec_all,idxs_test};
%
% % Evaluate model against the new sample
% Ynew = model_evaluation(myfun,Xnew,Config) ; % size((r2-r)*(M+1),1)
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



% % %% CHANGE! here: only valid for max (= NSE, R2) -> missing: yield deviation, RMSE?
% % [~,row_best] = max(Y); % for best simulation, determine position in output vector
% % ParvsVar_plot_best(idx_plot,7,idx_vartest) = Y(row_best); % all simulated output variables on current plot
% % ParvsVar_plot_best(idx_plot,8:size(X,2)+7,idx_vartest) = X(row_best,:); % all tested input parameters on current plot
% Var_all(1:size(Y,1),idx_plot,idx_vartest) = Y; % all simulated output variables on all plots (accumulating during loop)
% ParvsVar_plot = [];
% Config.TestParsValues = X(row_best,:);
% testparidx_old = Config.TestParsIdx;
% var_name_temp = Config.TestVarName;
% Config.TestVarName = "Yield";
% % Run simulation with best parameter values to retrieve best yield
% GSA_Initialize(Config.TestParsVals,Config);
% while AOS_ClockStruct.ModelTermination == false
%     AOS_PerformTimeStep();
% end
% AOS_Finish();
% [yield_best] = GSA_ReadSimOutput(Config);
% ParvsVar_plot_best(idx_plot,1,idx_vartest)...
%     = 100*abs(Config.ObsYield(idx_plot,2) - yield_best)/Config.ObsYield(idx_plot,2);
% ParvsVar_plot_best(idx_plot,2,idx_vartest)=yield_best;
% ParvsVar_plot_best(idx_plot,3,idx_vartest)...
%     = 100*abs(Config.ObsYield(idx_plot,2) - yield_def)/Config.ObsYield(idx_plot,2);
% ParvsVar_plot_best(idx_plot,4,idx_vartest)=yield_def;
% ParvsVar_plot_best(idx_plot,5,idx_vartest)=Config.ObsYield(idx_plot,2);
% ParvsVar_plot_best(idx_plot,6,idx_vartest)=Y_def;
% Config.TestVarName = var_name_temp; % reset variable name to calibration variable



