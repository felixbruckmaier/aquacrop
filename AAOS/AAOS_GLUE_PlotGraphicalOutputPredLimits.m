function [] = AAOS_GLUE_PlotGraphicalOutputPredLimits...
    (LotAnalysisOut,LotNameFull, fs, fst, fsst, colors,TargetVarNameFull,TargetVarNameShort,...
    TestVarNameFull,TestVarNameShort,HarvestDays,TestVarDays,TestVarObs,xlabel_text, N_Sim_txt)

%% Test variables Prediction Limits


Llim_TestFromTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTest;
Ulim_TestFromTest = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTest;
Llim_TestFromTarget = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Llim_TestFromTarget;
Ulim_TestFromTarget = LotAnalysisOut.GLUE_Out.(TestVarNameFull).Ulim_TestFromTarget;
text1 = ["N.A.","N.A."];
text2 = ["N.A.","N.A."];

figure;

% y axis right: Test variable (unit = fraction)
ylabel_text_left = TestVarNameShort +' [-]';
if TestVarNameShort == "CC"
    ylimit = [0,1];
elseif TestVarNameShort == "SWC"
    ylimit = [0,0.6];
end

xlimit = ([max(HarvestDays)]);
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
    text1 = ['Upper Limit ('+TestVarNameShort+')', 'Lower Limit ('+TestVarNameShort+')'];
end
if any(~isnan(Ulim_TestFromTarget))

    text2 = ['Upper Limit ('+TargetVarNameShort+')', 'Lower Limit ('+TargetVarNameShort+')'];
end


Plot15 = plot(TestVarDays,TestVarObs,'ok','MarkerFaceColor','g','MarkerSize',14);

title(LotNameFull+': Prediction limits','FontSize',fst);
subtitle(N_Sim_txt+' model evaluations of '+TestVarNameFull+' ('+TestVarNameShort+') & '+TargetVarNameFull+...
    ' ('+TargetVarNameShort+')','FontSize',fsst);
legendtext2 = [text1,text2,...
    TestVarNameShort+" (Observations)"];
legend([Plot11(1),Plot12(1),Plot13(1),Plot14(1),Plot15],...
    legendtext2, 'Location','eastoutside','FontSize',fs);

MXeval = xline(-999,':b','linewidth',6,'HandleVisibility','off');
hold on;