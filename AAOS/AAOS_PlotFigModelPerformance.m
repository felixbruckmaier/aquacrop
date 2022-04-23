%% REVISE, particularly sorting of GoF values box
%% Plot figures for analysis DEF & CAL
function []=AAOS_PlotFigModelPerformance(Directory,...
    OutputDirectoryFilename,Config,ModelOut,idx_TestVar)

SimRounds = Config.SimRounds;

% Get 2 output arrays from model output structure:
ModelEval = ModelOut.ModelEvaluation;
SimOut = ModelOut.SimulationOutput;

if Config.WriteFig == 'Y'
Excel = actxserver('Excel.Application');
Excel.DisplayAlerts = false; % Suppress Excel warning popups,
% e.g. when overwriting a file
end
fig_width = 19;
fig_height = 10;

fclose ('all'); % Close open files

[TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(idx_TestVar);
    
% Specify Graphical Plot Characteristics
% SimName = ["Obs","Def","Cal","Recalc"];
% if VarIdx == 1
Color = ['g','r','b','m','y']; % obs - def - calc - rec
% elseif VarIdx == 2
%    Color = ['g','b','c','r']; % obs - def - rec - calc
% end
LineStyle = ["-","-.","--",":"];
MarkerStyle = ["s","*","o","x"];
MarkerFaceColor = Color;
MarkerEdgeColor = Color;
MarkerSize = [5.5,5.5,5.5,5.5];
FontSize = 8;


for LotIdx = 1:max(1,size(ModelEval,1)-1) % loop through all tested plots
fig(LotIdx) = figure('units','centimeters','position', [0,0,fig_width,fig_height]);
    
    % -1 since last row = overall GoFs
    PlotName = ModelEval(LotIdx,1);
    

    legend_finalvar2 = [];
    legend_finalvar3 = [];
    legend_finalvar4 = [];
    legend_finalvar5 = [];
    legend_testvar1 = [];
    legend_testvar2 = [];
    legend_testvar3 = [];
    
    Days = [];
    % TestVarSim = [];
    FinalVar = [];
    N_GoF = size(Config.GoF,2);
    GoF = nan(min(3,SimRounds),N_GoF); % Possible 4th SimRound (HI calibration doesnt contribute to GoFs)

    
    %     TestVarNameShort+' (Def)',...
    %         TestVarNameShort+' (Obs)',TestVarNameShort+' (Def)'];
    %     TestVarNameShort+
    FinalVar(1,1) = ModelEval(LotIdx,8);
    FinalVar(2,1) = ModelEval(LotIdx,14);
    
    if not(isempty(FinalVar(1,1)))
        legend_finalvar1 = TestVarNameShort+' (Obs) = '+FinalVar(1,1);
    end
    
    if 0 == (SimOut(LotIdx,2,1,idx_TestVar)) | isnan((SimOut(LotIdx,2,1,idx_TestVar))) % SimDays Array
        %         Config.noSWC = 1;
        
        ChartsTestVar = 0; %RE
        ChartsFinalVar = 1; %RE
        
        Days = Config.SimMaturity(LotIdx);

    else
        
        Days = SimOut(LotIdx,2:end,1,idx_TestVar);
        Days(isnan(Days)) = [];
%     end %RMV
        
        
        TestVar1 = SimOut(LotIdx,2:end,2,idx_TestVar);
        TestVar1(isnan(TestVar1)) = [];
        % TestVar = zeros(4,size(Days,2)); % OLD
        TestVar = zeros(4,size(TestVar1,2));
        TestVar(1,:) = TestVar1;
        TestVar2 = SimOut(LotIdx,2:end,3,idx_TestVar);
        TestVar2(isnan(TestVar2)) = [];
        TestVar(2,:) = TestVar2;
        
        for idx = 1:N_GoF
            GoF(1,idx) = ModelEval(LotIdx,16+idx_TestVar^2+(idx-1)*6); % GoF_Def Columns: CC=15; SWC=18
        end
        ChartsTestVar = 2; % Number of model simulations to be plotted
        legend_finalvar2 = [TestVarNameShort+' (Def) = '+FinalVar(2)];
        legend_testvar1 = [TestVarNameShort+' (Obs)',...
            TestVarNameShort+' (Def)'];
        
        
        
        
        if SimRounds > 1 % CAL/ VAL
            
            %             ChartsTestVar = 3;%SimRounds;
            %             legend_testvar2
            TestVar3 = SimOut(LotIdx,2:end,4,idx_TestVar);
            TestVar3(isnan(TestVar3)) = [];
            TestVar(3,:) = TestVar3;
            FinalVar(3,1) = ModelEval(LotIdx,14-idx_TestVar); % TestVar_Cal Columns: CC=11; SWC=10
            for idx = 1:N_GoF
                GoF(2,idx) = ModelEval(LotIdx,15+idx_TestVar^2+(idx-1)*6);
                
            end

            legend_finalvar3 = [TestVarNameShort+' (CC) = '+FinalVar(3,1)];
            legend_testvar2 = [TestVarNameShort+' (CC)'];
%             if VarIdx == 1
%                 legend_finalvar3 = [TestVarNameShort+' (Cal) = '+FinalVar(3,1)];
%                 legend_testvar2 = [TestVarNameShort+' (Cal)'];
%             elseif VarIdx == 2
%                 legend_finalvar3 = [TestVarNameShort+' (Recalc) = '+FinalVar(3,1)];
%                 legend_testvar2 = [TestVarNameShort+' (Recalc)'];
%             end
            %             if VarIdx == 1 && Config.noSWC == 0
        end
        if SimRounds > 2 % CAL/ VAL w/ 2 variables -> Recalculation
            ChartsTestVar = 4;
            
            %                 legendtext = char(append(legendtext,...
            %                     string(TestVarNameShort)+" (Recalc)")); %, TestVarNameShort+' (Recalc)'];
            TestVar4 = SimOut(LotIdx,2:end,5,idx_TestVar);
            TestVar4(isnan(TestVar4)) = [];
            TestVar(4,:) = TestVar4;
            FinalVar(4,1) = ModelEval(LotIdx,9+idx_TestVar); % TestVar_Cal Columns: CC=8; SWC=9
            for idx = 1:N_GoF
                GoF(3,idx) = ModelEval(LotIdx,14+idx_TestVar^2+(idx-1)*6);
            end

            legend_finalvar4 = [TestVarNameShort+" (SWC) = "+FinalVar(4,1)];
            legend_testvar3 = [TestVarNameShort+" (SWC)"];
%             if VarIdx == 1
%                 legend_finalvar4 = [TestVarNameShort+" (Recalc) = "+FinalVar(4,1)];
%                 legend_testvar3 = [TestVarNameShort+" (Recalc)"];
%             elseif VarIdx == 2
%                 legend_finalvar4 = [TestVarNameShort+' (Cal) = '+FinalVar(4,1)];
%                 legend_testvar3 = [TestVarNameShort+' (Cal)'];
%                 
%             end
        end
        ChartsFinalVar = ChartsTestVar;
        if numel(Config.TestVarIds) == 3 % HI included as a test variable (SimRound #4)
            ChartsFinalVar = 5;
            FinalVar(5,1) = ModelEval(LotIdx,9); % Final Variable simulated after HI calibration (SimRound #4)
            legend_finalvar5 = [TestVarNameShort+' (HI) = '+FinalVar(5,1)];
        end
    end

    legendtext = ["","",legend_testvar1,legend_testvar2,legend_testvar3,...
        legend_finalvar1,legend_finalvar2,legend_finalvar3,legend_finalvar4,...
        legend_finalvar5];
    
    % plot: observed & default & calibrated & validated variablevalues
    
    
    
    % X-Axis #1 = Test Variable (CC or SWC)
    
    set(fig, 'units','centimeters','position', [0,0,fig_width,fig_height])
    xlim = ([1,max(Config.SimMaturity)+10]);
    tick = ceil(4*(size(Days,2)/(max(Days)-min(Days)+1)));
    yyaxis left
    
    xlabel('Day After Sowing');
    ylabel(TestVarNameShort+' [-]');

    if Config.CalcMean == 1
        titlestring = "Season "+Config.season+" / All Plots (Mean): "...
            +TestVarNameFull+" ("+TestVarNameShort+") ";
    elseif Config.CalcMean == 0
            titlestring = "Season "+Config.season+" / Plot #"+string(PlotName)...
                +": "+TestVarNameFull+" ("+TestVarNameShort+") ";
    end

    if TestVarNameFull == "SoilWaterContent"
%         titlestring = append(titlestring," #",string(Config.TestSWCidx));
        ylim([0,0.6]);
    else
        ylim([0,1]);
    end

    if Config.RUN_type ~= "DEF"
        if Config.CalcMean == 0
            titlestring = append(titlestring,"on "+string(TestVarNameFull)+...
                " ("+string(TestVarNameShort)+")");
            if ismember(PlotName,Config.CalibrationLots)
                titlestring = append(titlestring," - CALIBRATION");
            elseif ismember(PlotName,Config.ValidationLots)
                titlestring = append(titlestring," - VALIDATION");
            end
        end
    end
    

    
    set(gca,'YColor','black');
    title(titlestring);
    
    xticks(Days(1:tick:end));
    
    hold on;
    plot(0,0);
    plot(xlim(2),0);
    
    
    
    
    for idx = 1:ChartsTestVar
        plot(Days, TestVar(idx,:),'LineStyle',char(LineStyle(idx)),'Marker',...
            char(MarkerStyle(idx)),'Color',MarkerEdgeColor(idx),'LineWidth',2,...
            'MarkerEdgeColor',MarkerEdgeColor(idx),'MarkerSize',MarkerSize(idx));
        %             y_GoF(idx,1) = idx;
        %             y_GoF(idx,2) = TestVar(idx,end);
        
    end
    
    
    yyaxis right
    ylabel(TestVarNameShort+' [t/ha]')

    y_finalvar_max = ceil(max(ModelEval(1:max(1,end-1),8:14))+1);

    % Sort GoFs acc. to performance and determine respect. legend position within chart
    if SimRounds > 1
        idx_GoF = [1 2 3];
        if not(isempty(find(ismember(Config.GoF,"R2"))))
            idx_R2 = find(ismember(Config.GoF,"R2"));
        if isnan(GoF(:,idx_R2)) % no R2, but other GoF
            GoF(:,1) = -999;
            idx_GoF = [2 3]; %skip R2
        end
        end
        
        y_GoF = [];
        rmn = [];
        rmx = [];

        
        for idx = 1:size(GoF,2)
            if all(isnan(GoF(:,idx))) % if no GoFs available
                GoF(:,idx) = -999;

            else
                % Find duplicates = GoF w/ equal performance:
                GoFs_uni = unique(GoF(:,idx));
                GoFs_count = histc(GoF(:,idx),GoFs_uni);
                GoFs_uni(GoFs_count==1) = []; % remove unique values
                if length(GoFs_count) == 1 % 3 duplicates
                    rmn(idx) = -999;
                    rmx(idx) = -999;
                else
                    [val_min,rmn(idx)] = min(GoF(:,idx)); % max value = best performance
                    if ismember(val_min,GoFs_uni) % value = duplicate
                        rmn(idx) = -999;
                    end
                    [val_up,rmx(idx)] = max(GoF(:,idx)); % min value = best ...
                    if ismember(val_up,GoFs_uni) % value = duplicate
                        rmx(idx) = -999;
                    end
                    if idx == 2 % RMSE -> lower values = better
                        rmx_old = rmx(idx);
                        rmx(idx) = rmn(idx);
                        rmn(idx) = rmx_old;
                        
                    end
                end
            end
        end
        
        if all(rmx(:) == -999) | all(rmn(:) == -999)
            rmx = 3;
            rmn = 1;
        else
            rmx(rmx==-999) = [];
            rmn(rmn==-999) = [];
            rmx = mode(rmx);
            rmn = mode(rmn);
        end
        if rmn == rmx % no distinct ranking
            rmx = 3;
            rmn = 1;
        end
        
        
        rmd = setdiff([1,2,3],[rmx,rmn]); % median
        
        y_GoF(rmd) = 0.5 * y_finalvar_max;
        
        %     if all(GoF(:,rmx) == GoF(:,rmd))
        %         dmx = 0.7;
        %     else
        %         dmx = 0.85;
        %     end
        %     if all(GoF(:,rmn) == GoF(:,rmd))
        %         dmn = 0.3;
        %     else
        %         dmn = 0.15;
        %     end
        dmx = 0.85;
        dmn = 0.15;
        y_GoF(rmx) = dmx * y_finalvar_max;
        
        y_GoF(rmn) = dmn * y_finalvar_max;
        
        GoF(GoF==-999) = nan;
        
        for idx = 1:ChartsTestVar-1
            %     for idx = 1:max(round(ChartsTestVar/2)+max(0,ChartsTestVar-2-VarIdx)) % SWC: no recalculation = 3rd run
            text0 = "";
            for idx2 = idx_GoF
                text0 = text0+Config.GoF(idx2)+"="+GoF(idx,idx2)+newline;
            end
            
            
            text(xlim(2)-5,y_GoF(idx),text0,...
                'Color',Color(idx+1),'FontSize', FontSize);
        end
        
    end
    
   
    ylim([0,y_finalvar_max]);
    
    set(gca,'YColor','black');
    
    
    x_harvest = Config.SimMaturity(LotIdx);
    
    %     text(x_harvest,1,"H",'Color','g');
    
    for idx = 1:ChartsFinalVar
        plot(x_harvest+1, FinalVar(idx),'p','MarkerFaceColor',Color(idx),...
            'MarkerEdgeColor','black','MarkerSize',12);
        hold on;
    end
    
    
    
   
    
    
    hold on;
    
    
    
    
    floor(1+0.5*(length(GoF)+length(FinalVar)))
    legend(legendtext,'Orientation','horizontal','Location','southoutside',...
        'NumColumns',min(4,ChartsFinalVar));
    
    
    
    grid;
    

    




    if Config.WriteFig == 'Y'
        cd(Directory.vendor);
        if idx_TestVar == 1
            plot_column = "A";
        elseif idx_TestVar == 2
            plot_column = "J";
        end

        if TestVarNameShort == "SWC"
            disp("");
        end

        xlswritefig(fig,OutputDirectoryFilename,"Figures",...
            string(plot_column+max((LotIdx-1)*(fig_height+10),1)));
        clf(fig); % Clear the figure for the next graph (otherwise Matlab
        %     keeps plotting all graphs into the same figure)
        cd(Directory.BASE_PATH);
    end
    hold off;
end

% end