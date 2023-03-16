function [] = AAOS_GLUE_Graph_PlotAndWriteQuadrants...
    (Directory, GraphSizes, GraphColors,TargetVarNameFull, TargetVarNameShort,...
    ThreshTargetVar, ThreshTestVar,...
    VarIds_User, idcsBHS0 ,GLF0, N_Lots, N_Sim)

RowDim = N_Sim * N_Lots;
ColDim = numel(VarIds_User);

idcsBHS = reshape(idcsBHS0,RowDim,ColDim);
GLF = reshape(GLF0,RowDim,ColDim);

for VarIdx = VarIds_User(2:end) % loop through test variables = from index 2
    
    [TestVarNameFull,TestVarNameShort] = AAOS_SwitchTestVariable(VarIdx);
    
    fprintf(1,"... generating 4-Quadrant graph for '%s' & '%s'...\n",...
        string(TargetVarNameFull),string(TestVarNameFull));

    cd(Directory.SAFE_Plotting);

    % Define chart label text:

    text1 = "";
    text2 = "";
    text3 = "";
    text4 = "";

    % Classify simulations acc. to their performance in regard to current
    % test variable "idcsBHS(:,2)" and target variable "idcsBHS(:,1)"
    idx_GoodTestGoodTarget = and(idcsBHS(:,2)==1,idcsBHS(:,1)==1);
    idx_BadTestBadTarget = and(idcsBHS(:,2)==0,idcsBHS(:,1)==0);
    idx_BadTestGoodTarget = and(idcsBHS(:,2)==0,idcsBHS(:,1)==1);
    idx_GoodTestBadTarget = and(idcsBHS(:,2)==1,idcsBHS(:,1)==0);



    figure;
    matrix = [GLF(:,2), GLF(:,1)];
    x = matrix(:,1);
    y = matrix(:,2);

    Qall = size(x,1);

    if ~isempty(idx_BadTestBadTarget)
        Q1_x = matrix(idx_BadTestBadTarget,1);
        Q1_y = matrix(idx_BadTestBadTarget,2);
        Q1_p = round(numel(Q1_x) / Qall * 100, 0);
    end
    if ~isempty(idx_BadTestGoodTarget)
        Q2_x = matrix(idx_BadTestGoodTarget, 1);
        Q2_y = matrix(idx_BadTestGoodTarget, 2);
        Q2_p = round(numel(Q2_x) / Qall * 100, 0);
    end
    if ~isempty(idx_GoodTestGoodTarget)
        Q3_x = matrix(idx_GoodTestGoodTarget, 1);
        Q3_y = matrix(idx_GoodTestGoodTarget, 2);
        Q3_p = round(numel(Q3_x) / Qall * 100, 0);
    end
    if ~isempty(idx_GoodTestBadTarget)
        Q4_x = matrix(idx_GoodTestBadTarget, 1);
        Q4_y = matrix(idx_GoodTestBadTarget, 2);
        Q4_p = round(numel(Q4_x) / Qall * 100, 0);
    end



    if ~isnan(Q1_x); text1 = "N-Beh. (1. Quadrant) = "+string(Q1_p)+"%"; end
    if ~isnan(Q2_x); text2 = TargetVarNameShort+"-Beh. (2. Quadrant) = "+string(Q2_p)+"%"; end
    if ~isnan(Q3_x); text3 = TestVarNameShort+"- & "...
            +TargetVarNameShort+"-Beh. (3. Quadrant) = "+string(Q3_p)+"%"; end
    if ~isnan(Q4_x); text4 = TestVarNameShort+"-Beh. (4. Quadrant) = "+string(Q4_p)+"%"; end


    C1 = [0 0 0]; C4 = GraphColors(7,:); CB =  GraphColors(2,:);


    Xmax = max(GLF(:,2));
    Ymax = max(GLF(:,1));
    xticks([0:100:20]);
    yticks([0:100:20]);
    xlim([0,Xmax]);
    ylim([0,Ymax]);

    scatter(Q1_x,Q1_y,GraphSizes(6),'.','MarkerEdgeColor',C1);
    hold on;
    scatter(Q2_x,Q2_y,GraphSizes(6),'.','MarkerEdgeColor',GraphColors(1,:) );
    hold on;
    scatter(Q3_x,Q3_y,GraphSizes(6),'.','MarkerEdgeColor',GraphColors(7,:));
    hold on;
    scatter(Q4_x,Q4_y,GraphSizes(6),'.','MarkerEdgeColor',GraphColors(4,:));
    hold on;





    xline(ThreshTestVar,'--',{'Threshold','= '+string(ThreshTestVar)+"%"},'linewidth',GraphSizes(4),'Color',GraphColors(5,:),...
        'FontSize',GraphSizes(3));
    hold on;
    yline(ThreshTargetVar,'--',{'Threshold','= '+string(ThreshTargetVar)+"%"},'linewidth',GraphSizes(4),'Color',GraphColors(5,:),...
        'FontSize',GraphSizes(3));
    hold on;



    %     text(ThreshTestVar+ChartSizes(4)/4,25,string(Q1_p)+"%",'FontSize',ChartSizes(3)-2,'FontWeight','bold','BackgroundColor','w',...
    %         'Color',[0 0 0],'HorizontalAlignment','left');
    %     text(ThreshTestVar+ChartSizes(4)/4,7.5,string(Q4_p)+"%",'FontSize',ChartSizes(3)-2,'FontWeight','bold','BackgroundColor','w',...
    %         'Color',colors(7,:),'HorizontalAlignment','left');
    %     text(ThreshTestVar-ChartSizes(4)/4,25,string(Q2_p)+"%",'FontSize',ChartSizes(3)-2,'FontWeight','bold','BackgroundColor','w',...
    %         'Color',colors(1,:),'HorizontalAlignment','right');
    %     text(ThreshTestVar-ChartSizes(4)/4, 7.5,string(Q3_p)+"%",'FontSize',ChartSizes(3)-2,'FontWeight','bold','BackgroundColor','w',...
    %         'Color',colors(4,:),'HorizontalAlignment','right');

    N_Sim_All = N_Sim * N_Lots;
    TitleText = N_Lots+" Lot(s)/ "+N_Sim_All+" Samples: Behavioural (Beh.) vs. Non-Behavioural (N-Beh.) Simulations";




    SubTitleText = "for "+TestVarNameFull+" ("+TestVarNameShort+") & "...
        +TargetVarNameFull+" ("+TargetVarNameShort+")";
    [l, hobj, hout, mout] = legend([text1, text2, text3, text4],'FontSize',GraphSizes(3));
    % 'Location','eastoutside',
    M = findobj(hobj,'type','patch');
    set(M, 'MarkerSize',GraphSizes(6)*1.25);


    title(TitleText,'FontSize',GraphSizes(1));
    subtitle(SubTitleText,'FontSize',GraphSizes(2));

    xlabel('NRMSE ('+TestVarNameShort+") [%]", 'FontSize',GraphSizes(3));
    ylabel('ARE ('+TargetVarNameShort+") [%]",'FontSize',GraphSizes(3));
    ax = gca;
    ax.FontSize = GraphSizes(3);

    cd(Directory.BASE_PATH);
end