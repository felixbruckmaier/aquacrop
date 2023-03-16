function [] = AAOS_EE_PlotAndWriteGraphicalOutput(Config, Directory, SA_Output)

% Derive name of output file:
FileName = AAOS_DeriveOutputFileName(Config, Directory);

[N_Lots,~] = AAOS_GetLotNumberAndName(Config, 0);
for LotIdx = 1:N_Lots

    % Get Lot Name:
    [~,LotNameFull] = AAOS_GetLotNumberAndName(Config, LotIdx);

    fprintf(1,"... generating graphical EE output for lot '%s' (#%s/%s)...\n",...
        string(LotName),string(LotIdx),string(N_Lots));

    % Define title of graphical output plot:
    X_labels(1) = cellstr("Season "+Config.season+"/ Plot #"+...
        LotNameFull+"/ "+string(Config.TargetVar.NameFull)+": Elementary Effects (EE)");
    % Remove underscore sign from parameter names (plot function forces characters into lowercase)
    SampledParNames = cellstr(replace(string(SA_Output.(LotNameFull).ParameterNames),'_','-'));
    M_new = size(SampledParNames,1);
    % Define legend for sampled parameters:
    X_labels(2:M_new+1) = SampledParNames;

    SampleSizes = SA_Output.(LotNameFull).SampleSizes;
    n_rep = numel(SA_Output.(LotNameFull).SampleSizes);
    sigma = SA_Output.(LotNameFull).Values(n_rep+2,1:end-1);
    m_r = SA_Output.(LotNameFull).Values(2:n_rep+1,1:end-1);
    mi = m_r(n_rep, 1:end);


    % Plot results in the plane (mean(EE),std(EE)):
    cd(Directory.SAFE_Morris);
    EET_plot(mi,sigma,X_labels);

    if Config.RUN_type == "UQ"
        set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])

        histogram(Y);
        if extrainput.season == "2018"
            xlim([0,14]);
        elseif extrainput.season == "2019"
            xlim([0,10]);
        end
        hold on;
        finalvar_mean = mean(Y);
        finalvar_std = round(std(Y),2);
        line([finalvar_mean,finalvar_mean],ylim,'LineWidth',2,'Color','c');
        % finalvar_color = ['g','b','r','m']; % obs - def - cal1 - cal2
        legendtext = [extrainput.FinalVarNameAbbr+" (UQ - all; std = "+finalvar_std+")",...
            extrainput.FinalVarNameAbbr+" (UQ - mean) = "+round(finalvar_mean,2)];
        title("Season "+extrainput.season+"/ Plot #"+extrainput.PlotIdxAll...
            +": All Parameters on "+string(extrainput.FinalVarName)+...
            " ("+string(extrainput.FinalVarNameAbbr)+") - Single Runs & UQ");
        legend(legendtext,'Orientation','horizontal','Location','southoutside',...
            'NumColumns',3);
        xlabel(extrainput.FinalVarNameAbbr+'[t/ha]');
        ylabel('UQ: No. of runs');
        xlswritefig(gcf,extrainput.OutputFileName,1,string("H"+fig_row));
        clf(gcf);
    end

    if Config.WriteFig == 'Y'
        Excel = actxserver('Excel.Application');
        Excel.DisplayAlerts = false; % Suppress Excel warning popups, e.g. when overwriting a file

        % Adjust figure dimensions (acc. to number of parameters M, but min = 13):
        % (spreadsheet-cell-dependent)
        fig_height = Config.OutputSheet.CellHeight * max(13,M_new + 8); % cells * cell height
        fig_width = Config.OutputSheet.CellWidth * 8; % cells * cell width
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

    % Plot the sensitivity measure (mean of elementary effects) as a function
    % of model evaluations:
    X_labels(1) = [];


    if m_r(1:end-1,:) >= 0
        cd(Directory.SAFE_Plotting);
        figure; plot_convergence(m_r,SampleSizes,[],[],[],...
            'no of model evaluations','mean of EEs',X_labels)
    end

    if Config.WriteFig == 'Y'
        cd(Directory.vendor);
        fig_loc = append('K', fig_row);
        set(gcf, 'units','centimeters','position', [0,0,fig_width,fig_height])
        xlswritefig(gcf,FileName,"Graphical",fig_loc);
        %     string(fig_col+fig_row));
        clf(gcf); % Clear the figure for the next graph (otherwise Matlab
        %     keeps plotting all graphs into the same figure)
        cd(Directory.BASE_PATH);
    end

end