    % Determine user-defined test variables:

        units = ["(Growing Degree Days)^-1","Calendar Days","fr","Calendar Days",...
        "Calendar Days","Calendar Days","No. of Plants / ha","cm^2","%","mm",...
        "mm / day", "m","m","Calendar Days","m^3 / m^3","m^3 / m^3","m^3 / m^3","fr"];
for TestVarIdx = 1:2

N_SamplesDefault = size(DefaultSamples,1);
AllPlotLabels = repmat({'Default'},N_SamplesDefault,1);
AllPlotLabelsViolin{1} = char("Default | N="+string(N_SamplesDefault));
end



  %% Parameter Boxplots
  % Retrieve parameter specifications for violin graphs:
% Retrieve names & transform certain signs to avoid legend auto-formatting:
    ParNames = AnalysisOut.("Lot"+LotNames(LotIdx)).SamplingOut.ParameterNames;
    ParNames = replace(ParNames,"_","-");
    ParNames = replace(ParNames,"0","o");
    N_Pars = size(ParNames,1);
    AllSamplesLot_j = AnalysisOut.("Lot"+LotNames(LotIdx)).SamplingOut.Values(6:end, 1:N_Pars);
    DefaultSamples = AllSamplesLot_j;
    a = 1;
    if all(idx_GoodTestAndTarget==0) & a == 0;
        AllSamplesLot_j = zeros(2,N_Pars);
    else
        AllSamplesLot_j(idx_GoodTarget==0, :) = [];
    end
    AllSamplesAllLots = [AllSamplesAllLots; AllSamplesLot_j];
    Samples = AnalysisOut.("Lot"+LotNames(LotIdx)).GLUE_Out.Samples;
    Samples_All = [Samples_All; Samples];


    % VIOLIN PLOT
    for idx_Par1 = 1:N_Pars
        % AllPlotLabelsViolin = [];
        % x = [];
        %     x = [DefaultSamples(:,idx); ParValuesBehavAllLots(:,idx)];
        %     x(isnan(x)) = [];
        %
        %     for LotIdx2 = Idcs_Lots
        %         LotName = char(strcat("Lot", string(LotNames(LotIdx2))));
        %     LotPlotLabel = repmat({LotName},N_BehavSamples(LotIdx2),1);
        %     AllPlotLabels = [AllPlotLabels; LotPlotLabel];
        %     end
        % figure
        % subplot(2,1,1)
        % boxplot(x,AllPlotLabels)


        ParameterSamplesAllLots{:, 1} = DefaultSamples(:,idx_Par1);
        for LotIdx3 = Idcs_Lots
            ParameterSamplesAllLots{:,1+LotIdx3} = AllSamplesAllLots{LotIdx3, 1}(:,idx_Par1);
            n_Samples = size(AllSamplesAllLots{LotIdx3, 1}(:,idx_Par1), 1);
%             if LotIdx3 == 6 && n_Samples == 2
%                 n_Samples = 0;
%             end
            AllPlotLabelsViolin{1+LotIdx3} = char("Lot"+LotNames(LotIdx3)+" | N="+string(n_Samples));
        end
        cd(Directory.vendor);
        figure;
        if idx_Par1 == 11
            set(gca, 'YScale', 'log');
        end
        [h,L,MX,MED,bw] = violin(ParameterSamplesAllLots,'xlabel',AllPlotLabelsViolin,'edgecolor','b',...
            'mc','b:',...
            'medc','g--');
            set(gca,'XtickLabel',AllPlotLabelsViolin)

        set(gca(),'FontSize',fs-2);
xtickangle(90)

        ylabel(string(ParNames(idx_Par1)+" ["+units(idx_Par1)+"]"),'FontSize',fs);
        MXeval = xline(-999,':b','linewidth',6,'HandleVisibility','off');
        MEDeval = xline(-999,'--g','linewidth',6,'HandleVisibility','off');
        MXdef = yline(MX(1),':r','linewidth',6,'HandleVisibility','off');
        MEDdef = yline(MED(1),'--k','linewidth',6,'HandleVisibility','off');
        legend([MXdef MEDdef MXeval MEDeval],'Mean (Default)','Median (Default)','Mean (Evaluated)','Median (Evaluated)',...
            'Location','eastoutside');

        MED_AllLots(idx_Par1,:) = MED;
        MX_AllLots(idx_Par1,:) = MX;

        title(string("Parameter Value Distribution: '"+ParNames(idx_Par1))+"'",'FontSize',fst);
        subtitle("                   Default vs. Biomass-behavioural simulations (N)",'FontSize',fsst)
        subtitle("Default vs. Biomass-behavioural simulations (N)",'FontSize',fsst)
        cd(Directory.SAFE_Plotting);
        % 'facecolor',[1 1 0;0 1 0;.3 .3 .3;0 0.3 0.1]
    end