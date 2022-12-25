function [] = AAOS_GLUE_PlotGraphicalOutputTimeSeries...
    (LotAnalysisOut, LotNameFull, fs, fst, fsst, ms, lw, colors, ...
    TargetVarNameFull,TargetVarNameShort, HarvestDays, TargetVarObs,...
    TargetVarSim, TestVarNameFull, TestVarNameShort, TestVarDays, TestVarSim, TestVarObs,xlabel_text, N_Sim_txt)

% y axis right: Test variable (unit = fraction)
ylabel_text_left = TestVarNameShort +' [-]';

text2 = "N.A.";
text3 = "N.A.";
text4 = "N.A.";
text7 = "N.A.";
text8 = "N.A.";
text9 = "N.A.";

% y axis right: Target variable (unit = t/ha)
ylabel_text_right = TargetVarNameShort+' [t/ha]';


%% BEHAVIOURAL VS. NON-BEHAVIOURAL SIMULATIONS:
idx_GoodTarget = LotAnalysisOut.GLUE_Out.(TargetVarNameFull).idx_GoodTarget;
if isnan(TestVarNameFull)
    idx_GoodTest = nan;
    idx_GoodTestAndTarget = nan;
    idx_BadTestAndTarget = idx_GoodTarget==0;
else
    idx_GoodTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).idx_GoodTest;
    idx_GoodTestAndTarget = and(idx_GoodTest==1,idx_GoodTarget==1);
    idx_BadTestAndTarget = and(idx_GoodTest==0,idx_GoodTarget==0);
end



if TestVarNameShort == "CC"
    ylimit = [0,1];
elseif TestVarNameShort == "SWC"
    ylimit = [0,0.6];
end

%% Test variables simulations
figure;
xlabel(xlabel_text); xlimit = ([max(HarvestDays)+6]);
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
Plot6 = plot(-999,0,'pk','MarkerEdgeColor','k','MarkerSize',ms);
Plot7 = plot(-999,0,'pk','MarkerEdgeColor',colors(1,:),'MarkerSize',ms);
Plot8 = plot(-999,0,'pk','MarkerEdgeColor',colors(7,:),'MarkerSize',ms);
Plot9 = plot(-999,0,'pk','MarkerEdgeColor',colors(4,:),'MarkerSize',ms);


% All Simulations:
if any(idx_BadTestAndTarget==1);
    Plot1 = plot(TestVarDays,TestVarSim(idx_BadTestAndTarget, :),'-','MarkerFaceColor','k');
    hold on;
    %% Plot dummy lines with larger thickness for legend only:
    DummyLine1 = xline(-999,'k','linewidth',lw);
    hold on;
end
% Simulations behavioural towards test variable:
if any(idx_GoodTest==1); Plot2 = plot(TestVarDays,TestVarSim(idx_GoodTest,:)','-','Color',colors(1,:)); hold on;
    text2 = TestVarNameShort+' ('+TestVarNameShort+'-BS)'; hold on;
    DummyLine2 = xline(-999,'Color',colors(1,:),'linewidth',lw); hold on;
end
% Simulations behavioural towards target variable:
if any(idx_GoodTarget==1); Plot3 = plot(TestVarDays,TestVarSim(idx_GoodTarget,:)','-','Color',colors(7,:)); hold on;
    text3 = TestVarNameShort+' ('+TargetVarNameShort+'-BS)';
    DummyLine3 = xline(-999,'Color',colors(7,:),'linewidth',lw); hold on;
end
% Simulations behavioural towards target AND test variables:
if any(idx_GoodTestAndTarget==1); Plot4 = plot(TestVarDays,TestVarSim(idx_GoodTestAndTarget,:)','-','Color',colors(4,:)); hold on;
    text4 = TestVarNameShort+...
        ' ('+TestVarNameShort+'-&'+TargetVarNameShort+'-BS)';
    DummyLine4 = xline(-999,'Color',colors(4,:),'linewidth',lw); hold on;
end
% Observations:
Plot5 = plot(TestVarDays,TestVarObs,'ok','MarkerFaceColor','g','MarkerSize',14'); hold on

%% Target variable:
yyaxis right; ylabel(ylabel_text_right);hold on;
ylim([0,ceil(LotAnalysisOut.TargetVar.MaxValue+1)]); set(gca,'YColor','black');
% All Simulations:
if any(idx_BadTestAndTarget==1); hold on; Plot6 = plot(HarvestDays+2,TargetVarSim,'pk','MarkerEdgeColor','k','MarkerSize',ms); end
% Simulations behavioural towards test variable:
if any(idx_GoodTest==1); hold on; Plot7 = plot(HarvestDays+3,TargetVarSim(idx_GoodTest)','pk','MarkerEdgeColor',colors(1,:),'MarkerSize',ms);
    text7 = TargetVarNameShort+' ('+TestVarNameShort+'-BS)';
end
% Simulations behavioural towards target variable:
if any(idx_GoodTarget==1); hold on; Plot8 = plot(HarvestDays+4,TargetVarSim(idx_GoodTarget)','pk','MarkerEdgeColor',colors(7,:),'MarkerSize',ms);
    text8 = TargetVarNameShort+' ('+TargetVarNameShort+'-BS)';
end
% Simulations behavioural towards target AND test variable:
if any(idx_GoodTestAndTarget==1); hold on; Plot9 = plot(HarvestDays+5,TargetVarSim(idx_GoodTestAndTarget)','pk','MarkerEdgeColor',colors(4,:),'MarkerSize',ms);
    text9 = TargetVarNameShort+...
        ' ('+TestVarNameShort+'-&'+TargetVarNameShort+'-BS)';
end
% Observations:
Plot10 = plot(HarvestDays+6,TargetVarObs,'pk','MarkerFaceColor','g','MarkerSize',ms);
title(LotNameFull+': Behavioural (BS) vs. Non-Behavioural Simulations (NBS)','FontSize',fst);
subtitle(N_Sim_txt+' model evaluations of '+TestVarNameFull+' ('+TestVarNameShort+') & '+TargetVarNameFull+...
    ' ('+TargetVarNameShort+')','FontSize',fsst);
legendtext = [TestVarNameShort+' (all BS & NBS)',text2,text3,text4,...
    TestVarNameShort+' (Observations)',...
    TargetVarNameShort+' (all BS & NBS)',text7,text8,text9,...
    TargetVarNameShort+" (Observations)"];


%% Plot dummy lines with larger thickness for legend only:
DummyLine1 = xline(-999,'k','linewidth',8);
DummyLine2 = xline(-999,'Color',colors(1,:),'linewidth',8);
DummyLine3 = xline(-999,'Color',colors(7,:),'linewidth',8);
DummyLine4 = xline(-999,'Color',colors(4,:),'linewidth',8);

legend([DummyLine1,DummyLine2,DummyLine3,DummyLine4,Plot5(1),...
    Plot6(1),Plot7(1),Plot8(1),Plot9(1),Plot10],...
    legendtext, 'Location','eastoutside','FontSize',fs);
hold on;