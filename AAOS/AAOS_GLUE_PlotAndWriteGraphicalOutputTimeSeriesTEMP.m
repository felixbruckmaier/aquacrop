function [] = AAOS_GLUE_PlotAndWriteGraphicalOutputTimeSeriesTEMP...
    (Config, Directory, FileName, LotAnalysisOut, LotIdx, LotNameFull, colors)

fs = 22;
fst = 24;
fsst = 20;
ms = 50; lw = 4;

ParameterNames = LotAnalysisOut.ParameterNames;
N_Pars = size(ParameterNames,1);
% Define legend for sampled parameters:
X_labels(2:N_Pars+1) = ParameterNames;
HarvestDays = LotAnalysisOut.GLUE_Out.HarvestDays;
MaxHarvestDay = max(HarvestDays);
TargetVar = LotAnalysisOut.TargetVar;
TargetVarSim = LotAnalysisOut.GLUE_Out.TargetVarSim;
TargetVarObs = LotAnalysisOut.GLUE_Out.TargetVarObs;
GLF_TargetVar = LotAnalysisOut.GLUE_Out.GLF_TargetVar;
Samples = LotAnalysisOut.GLUE_Out.Samples;




AvailTestVarSizes = LotAnalysisOut.GLUE_Out.AvailableTestVariableSizes;
if any(~isnan(AvailTestVarSizes))

    AvailTestVars = LotAnalysisOut.GLUE_Out.AvailableTestVariables;
    % Determine user-defined test variables:
    for TestVarIdx = 1:2 %1:numel(AvailTestVars)


        text2 = "N.A.";
        text3 = "N.A.";
        text4 = "N.A.";
        text7 = "N.A.";
        text8 = "N.A.";
        text9 = "N.A.";
        text11_12 = ["N.A.","N.A."];
        text13_14 = ["N.A.","N.A."];

        TestVar = AvailTestVars(TestVarIdx);
        % Determine test variable:
        cd(Directory.BASE_PATH);
        [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(TestVar);



        TestVarDays = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarDays;
        TestVarSim = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarSim;
        TestVarObs = LotAnalysisOut.GLUE_Out.(TestVarNameFull).TestVarObs;
        GLF_TestVar = LotAnalysisOut.GLUE_Out.(TestVarNameFull).GLF_TestVar;
        idx_GoodTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).idx_GoodTest;
        idx_GoodTarget = LotAnalysisOut.GLUE_Out.(TestVarNameFull).idx_GoodTarget;
        Llim_TestFromTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTest;
        Ulim_TestFromTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTest;
        Llim_TestFromTarget = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTarget;
        Ulim_TestFromTarget = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTarget;



        %% BEHAVIOURAL VS. NON-BEHAVIOURAL SIMULATIONS:

        xlabel_text = 'Day After Sowing';
        ylabel_text_left = TestVarNameShort +' [-]';
        ylabel_text_right = TargetVar.NameShort+' [t/ha]';
        %figure('units','centimeters','position', [0,0,fig_width,fig_height]);
        idx_GoodTestAndTarget = and(idx_GoodTest==1,idx_GoodTarget==1);
        idx_BadTestAndTarget = and(idx_GoodTest==0,idx_GoodTarget==0);
        if TestVarNameShort == "CC"
            ylimit = [0,1];
        elseif TestVarNameShort == "SWC"
            ylimit = [0,0.6];
        end
        fs = 16;


        TestVarOff = 0;

        if TestVarOff ==0
            %% Test variables simulations
            figure;
            xlabel(xlabel_text); xlimit = ([MaxHarvestDay+6]);
            xticks(ceil(4*(size(TestVarDays,2)/(max(TestVarDays)-min(TestVarDays)+1))));
            plot(xlimit,0);
            ax = gca;
            ax.FontSize = fs;
            hold on;
            yyaxis left; ylabel(ylabel_text_left,'FontSize',fs);
            xlabel(xlabel_text,'FontSize',fs);
            ylim(ylimit);
            xlim([0,xlimit]);
            Plot1 = plot(-999,0,'-','MarkerFaceColor','k');
            Plot2 = plot(-999,0,'-','Color',colors(1,:));
            Plot3 = plot(-999,0,'-','Color',colors(7,:));
            Plot4 = plot(-999,0,'-','Color',colors(4,:));
            Plot6 = plot(-999,0,'pk','MarkerEdgeColor','k','MarkerSize',fs);
            Plot7 = plot(-999,0,'pk','MarkerEdgeColor',colors(1,:),'MarkerSize',fs);
            Plot8 = plot(-999,0,'pk','MarkerEdgeColor',colors(7,:),'MarkerSize',fs);
            Plot9 = plot(-999,0,'pk','MarkerEdgeColor',colors(4,:),'MarkerSize',fs);




            % All Simulations:
            if any(idx_BadTestAndTarget==1);
                Plot1 = plot(TestVarDays,TestVarSim(idx_BadTestAndTarget, :),'-','MarkerFaceColor','k');
                hold on;
                %% Plot dummy lines with larger thickness for legend only:
                DummyLine1 = xline(-999,'k','linewidth',4);
                hold on;
            end
            % Simulations behavioural towards test variable:
            if any(idx_GoodTest==1); Plot2 = plot(TestVarDays,TestVarSim(idx_GoodTest,:)','-','Color',colors(1,:)); hold on;
                text2 = TestVarNameShort+' ('+TestVarNameShort+'-BS)'; hold on;
                DummyLine2 = xline(-999,'Color',colors(1,:),'linewidth',4); hold on;
            end
            % Simulations behavioural towards target variable:
            if any(idx_GoodTarget==1); Plot3 = plot(TestVarDays,TestVarSim(idx_GoodTarget,:)','-','Color',colors(7,:)); hold on;
                text3 = TestVarNameShort+' ('+Config.TargetVar.NameShort+'-BS)';
                DummyLine3 = xline(-999,'Color',colors(7,:),'linewidth',4); hold on;
            end
            % Simulations behavioural towards target AND test variables:
            if any(idx_GoodTestAndTarget==1); Plot4 = plot(TestVarDays,TestVarSim(idx_GoodTestAndTarget,:)','-','Color',colors(4,:)); hold on;
                text4 = TestVarNameShort+...
                    ' ('+TestVarNameShort+'-&'+Config.TargetVar.NameShort+'-BS)';
                DummyLine4 = xline(-999,'Color',colors(4,:),'linewidth',4); hold on;
            end
            % Observations:
            Plot5 = plot(TestVarDays,TestVarObs,'ok','MarkerFaceColor','g','MarkerSize',14'); hold on

            %% Target variable:
            yyaxis right; ylabel(ylabel_text_right);hold on;
            ylim([0,ceil(TargetVar.MaxValue+1)]); set(gca,'YColor','black');
            % All Simulations:
            if any(idx_BadTestAndTarget==1); hold on; Plot6 = plot(HarvestDays+2,TargetVarSim,'pk','MarkerEdgeColor','k','MarkerSize',fs); end
            % Simulations behavioural towards test variable:
            if any(idx_GoodTest==1); hold on; Plot7 = plot(HarvestDays+3,TargetVarSim(idx_GoodTest)','pk','MarkerEdgeColor',colors(1,:),'MarkerSize',fs);
                text7 = Config.TargetVar.NameShort+' ('+TestVarNameShort+'-BS)';
            end
            % Simulations behavioural towards target variable:
            if any(idx_GoodTarget==1); hold on; Plot8 = plot(HarvestDays+4,TargetVarSim(idx_GoodTarget)','pk','MarkerEdgeColor',colors(7,:),'MarkerSize',fs);
                text8 = Config.TargetVar.NameShort+' ('+Config.TargetVar.NameShort+'-BS)';
            end
            % Simulations behavioural towards target AND test variable:
            if any(idx_GoodTestAndTarget==1); hold on; Plot9 = plot(HarvestDays+5,TargetVarSim(idx_GoodTestAndTarget)','pk','MarkerEdgeColor',colors(4,:),'MarkerSize',fs);
                text9 = Config.TargetVar.NameShort+...
                    ' ('+TestVarNameShort+'-&'+Config.TargetVar.NameShort+'-BS)';
            end
            % Observations:
            Plot10 = plot(HarvestDays+6,TargetVarObs,'pk','MarkerFaceColor','g','MarkerSize',fs);
            title(LotNameFull+': Behavioural (BS) vs. Non-Behavioural Simulations (NBS)','FontSize',fst);
        subtitle('10070 model evaluations of '+TestVarNameFull+' ('+TestVarNameShort+') & '+Config.TargetVar.NameFull+...
            ' ('+Config.TargetVar.NameShort+')','FontSize',fsst);
            legendtext = [TestVarNameShort+' (all BS & NBS)',text2,text3,text4,...
                TestVarNameShort+' (Observations)',...
                Config.TargetVar.NameShort+' (all BS & NBS)',text7,text8,text9,...
                Config.TargetVar.NameShort+" (Observations)"];

%             legend([DummyLine1,Plot2(1),Plot3(1),Plot4(1),Plot5(1),...
%                 Plot6(1),Plot7(1),Plot8(1),Plot9(1),Plot10],...
%                 legendtext, 'Location','eastoutside','FontSize',fs);

%% Plot dummy lines with larger thickness for legend only:
    DummyLine1 = xline(-999,'k','linewidth',8);
    DummyLine2 = xline(-999,'Color',colors(1,:),'linewidth',8);
    DummyLine3 = xline(-999,'Color',colors(7,:),'linewidth',8);
    DummyLine4 = xline(-999,'Color',colors(4,:),'linewidth',8);

    legend([DummyLine1,DummyLine2,DummyLine3,DummyLine4,Plot5(1),...
        Plot6(1),Plot7(1),Plot8(1),Plot9(1),Plot10],...
        legendtext, 'Location','eastoutside','FontSize',fs);


            
            if Config.WriteFig == 'Y'
                Excel = actxserver('Excel.Application');
                Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file

                % Adjust figure dimensions (acc. to number of parameters N_Pars, but min = 13):
                % (spreadsheet-cell-dependent)
                fig_height = Config.OutputSheet.CellHeight * max(13,N_Pars + 8); % cells * cell height
                fig_width = Config.OutputSheet.CellWidth * 10; % cells * cell width
                fig_row = string(ceil((LotIdx - 1) * (2 *fig_height - 1)) + 1);
                fig_loc = append('A', fig_row);

                cd(Directory.vendor);
                set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])
                xlswritefig(gcf,FileName,"Graphical",fig_loc);
                %     string(fig_col+fig_row));
                clf(gcf); % Clear the figure for the next graph (otherwise Matlab
                %     keeps plotting all graphs into the same figure)
                cd(Directory.BASE_PATH);
            end
        end
        %% Test variables Predict. Limits

        figure;


        xlimit = ([MaxHarvestDay]);
        xticks(ceil(4*(size(TestVarDays,2)/(max(TestVarDays)-min(TestVarDays)+1))));
        plot(xlimit,0);


        hold on;
        ylabel(ylabel_text_left,'FontSize',fs);
        xlabel(xlabel_text,'FontSize',fs);
        ylim(ylimit);
        xlim([0,xlimit]);
        plot(0,0);
        hold on;

        ax = gca;
        ax.FontSize = fs;
        hold on;

        % Prediction limits towards test variable:
        Plot11 = plot(TestVarDays,[Ulim_TestFromTest],'--^','Color',colors(1,:),'LineWidth',3);hold on;
        Plot12 = plot(TestVarDays,[Llim_TestFromTest],'--v','Color',colors(1,:),'LineWidth',3);hold on;
        % Prediction limits towards target variable:
        Plot13 = plot(TestVarDays,[Ulim_TestFromTarget],'--<','Color',colors(2,:),'LineWidth',3);hold on;
        Plot14 = plot(TestVarDays,[Llim_TestFromTarget],'-->','Color',colors(2,:),'LineWidth',3);hold on;

        if any(~isnan(Ulim_TestFromTest))
            text11_12 = ['Upper Limit ('+TestVarNameShort+')', 'Lower Limit ('+TestVarNameShort+')'];
        end
        if any(~isnan(Ulim_TestFromTarget))

            text13_14 = ['Upper Limit ('+Config.TargetVar.NameShort+')', 'Lower Limit ('+Config.TargetVar.NameShort+')'];
        end


        Plot15 = plot(TestVarDays,TestVarObs,'ok','MarkerFaceColor','g','MarkerSize',14);

        title(LotNameFull+': Prediction limits','FontSize',fst);
        subtitle('10070 model evaluations of '+TestVarNameFull+' ('+TestVarNameShort+') & '+Config.TargetVar.NameFull+...
            ' ('+Config.TargetVar.NameShort+')','FontSize',fsst);
        legendtext2 = [text11_12,text13_14,...
            TestVarNameShort+" (Observations)"];
        legend([Plot11(1),Plot12(1),Plot13(1),Plot14(1),Plot15],...
            legendtext2, 'Location','eastoutside','FontSize',fs);

                MXeval = xline(-999,':b','linewidth',6,'HandleVisibility','off');

    end

end

cd(Directory.BASE_PATH);