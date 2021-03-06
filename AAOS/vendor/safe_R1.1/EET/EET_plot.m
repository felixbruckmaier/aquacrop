function EET_plot(mi,sigma,varargin)


%
% Plot the sensitivity indices computed by the Elementary Effects Test -
% mean (mi) of the EEs on the horizontal axis and standard deviation (sigma)
% of the EEs on the vertical axis.
% (see help of EET_indices for more details about the EET and references)
%
% Usage:
%
% EET_plot(mi,sigma)
% EET_plot(mi,sigma,labelinput)
% EET_plot(mi,sigma,labelinput,mi_lb,mi_ub,sigma_lb,sigma_ub)
%
%         mi = mean of the elementary effects               - vector (1,M)
%      sigma = standard deviation of the elementary effects - vector (1,M)
% labelinput = strings for the x-axis labels            - cell array (1,M)
%      mi_lb = lower bound of 'mi'                          - vector (1,M)
%      mi_ub = upper bound of 'mi'                          - vector (1,M)
%   sigma_lb = lower bound of 'sigma'                       - vector (1,M)
%   sigma_ub = upper bound of 'sigma'                       - vector (1,M)

% This function is part of the SAFE Toolbox by F. Pianosi, F. Sarrazin
% and T. Wagener at Bristol University (2015).
% SAFE is provided without any warranty and for non-commercial use only.
% For more details, see the Licence file included in the root directory
% of this distribution.
% For any comment and feedback, or to discuss a Licence agreement for
% commercial use, please contact: francesca.pianosi@bristol.ac.uk
% For details on how to cite SAFE in your publication, please see:
% bristol.ac.uk/cabot/resources/safe-toolbox/

% Options for the graphic:
fn = 'Helvetica' ; % font type of axes, labels, etc.
%fn = 'Courier' ;
fs = 11 ; % font size of axes, labels, etc. -- ORIG: 20
ms = 10 ; % marker size

% Options for the legend:
sorting   = 1  ; % If 1, inputs will be displayed in the legend
% according to their influence, i.e. from most sensitive to least sensitive
% (if 0 they will be displayed according to their original order)

% Options for the colours:
% You can produce a coloured plot or a black and white one
% (printer-friendly). Furthermore, you can use matlab colourmaps or
% repeat 5 'easy-to-distinguish' colours (see http://colorbrewer2.org/).
% Option 1a - coloured using colorbrewer: uncomment the following line:
% col = [[228,26,28];[55,126,184];[77,175,74];[152,78,163];[255,127,0]]/256;  cc = 'k' ;
% Option 1b - coloured using matlab colormap: uncomment the following line:
% col=hsv(length(mi));   cc = 'k' ;
% Option 1a - B&W using matlab colorbrewer: uncomment the following line:
%col = [[37 37 37];[90 90 90];[150 150 150];[189 189 189];[217 217 217]]/256; cc = 'w' ;
% Option 1b - B&W using matlab colormap: uncomment the following line:
%col=gray(length(mi)); cc = 'w' ;

col = [[0 0.4470 0.7410]; [0.8500 0.3250 0.0980];...
    [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560];...
    [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330];...
    [0.6350 0.0780 0.1840]];  cc = 'k' ; % blue/orange/yellow/purple/green/cyan/red; see...
% https://www.mathworks.com/help/matlab/creating_plots/specify-plot-colors.html

%%%%%%%%%%%%%%
% Check inputs
%%%%%%%%%%%%%%



% sigma(1,sigma(1,:)=='NaN') = [];
nanCol = isnan(mi);
zeroCol = mi==0;
badCol = nanCol | zeroCol;
mi(:,badCol) = [];
sigma(:,badCol) = [];
if ~isnumeric(mi); error('''mi'' must be a vector of size (1,M)'); end
if ~isnumeric(sigma); error('''sigma'' must be a vector of size (1,M)'); end

[N,Msens] = size(mi)  ;
[n,msens] = size(sigma) ;
if N~=1; error('''mi'' must be a row vector'); end
if n~=1; error('''sigma'' must be a row vector'); end
if Msens~=msens; error('''mi'' and''sigma'' must have the same number of elements'); end


nb_legend = Msens  ; % number of input names that will be displayed in the legend-- ORIG: 5

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Recover and check optional inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Set optional arguments to their default values:
M_title = Msens + 1;
labelinput = cell(1,M_title); for i=1:M_title; labelinput{i}=['X' num2str(i)]; end
mi_lb    = zeros(1,Msens) ;
mi_ub    = zeros(1,Msens) ;
sigma_lb = zeros(1,Msens) ;
sigma_ub = zeros(1,Msens) ;

% Recover and update optional arguments:
if nargin > 2
    if ~isempty(varargin{1})
        disp(varargin{1});
        plottitle = varargin{1}(1);
        labelinput = varargin{1}(2:end);
        labelinput(:,badCol) = [];
        if ~iscell(labelinput); error('''labelinput'' must be a cell array'); end
        %         if length(labelinput)~=Msens; error('''labelinput'' must have M=%d components'); end
        for i=1:Msens; if ~ischar(labelinput{i}); error('all components of ''labelinput'' must be string'); end; end
    end
end
if nargin > 3
    if ~isempty(varargin{2})
        mi_lb = varargin{2} ;
        if ~isnumeric(mi_lb); error('''mi_lb'' must be a vector of size (1,M)'); end
        nanCol = isnan(mi_lb);
        zeroCol = mi_lb==0;
        badCol = nanCol | zeroCol;
        mi_lb(:,badCol) = [];
        [n,msens] = size(mi_lb) ;
        if n~=1; error('''mi_lb'' must be a row vector'); end
        if Msens~=msens; error('''mi'' and''mi_lb'' must have the same number of elements'); end
    end
end
if nargin > 4
    if ~isempty(varargin{3})
        mi_ub = varargin{3} ;
        if ~isnumeric(mi_ub); error('''mi_ub'' must be a vector of size (1,M)'); end
        nanCol = isnan(mi_ub);
        zeroCol = mi_ub==0;
        badCol = nanCol | zeroCol;
        mi_ub(:,badCol) = [];
        [n,msens] = size(mi_ub) ;
        if n~=1; error('''mi_ub'' must be a row vector'); end
        if Msens~=msens; error('''mi'' and''mi_ub'' must have the same number of elements'); end
    end
end
if nargin > 4
    if ~isempty(varargin{4})
        sigma_lb = varargin{4} ;
        if ~isnumeric(sigma_lb); error('''sigma_lb'' must be a vector of size (1,M)'); end
        nanCol = isnan(sigma_lb);
        zeroCol = sigma_lb==0;
        badCol = nanCol | zeroCol;
        sigma_lb(:,badCol) = [];
        [n,msens] = size(sigma_lb) ;
        if n~=1; error('''sigma_lb'' must be a row vector'); end
        if Msens~=msens; error('''sigma'' and''sigma_lb'' must have the same number of elements'); end
    end
end
if nargin > 5
    if ~isempty(varargin{5})
        sigma_ub = varargin{5} ;
        if ~isnumeric(sigma_ub); error('''sigma_ub'' must be a vector of size (1,M)'); end
        nanCol = isnan(sigma_ub);
        zeroCol = sigma_ub==0;
        badCol = nanCol | zeroCol;
        sigma_ub(:,badCol) = [];
        [n,msens] = size(sigma_ub) ;
        if n~=1; error('''sigma_ub'' must be a row vector'); end
        if Msens~=msens; error('''sigma'' and''sigma_ub'' must have the same number of elements'); end
    end
end
% if nargin > 6
%     if ~isempty(varargin{6})
%         plotvar_name = varargin{6} ;
%     end
% end


%%%%%%%%%%%%%%%%%%%
% Produce plot
%%%%%%%%%%%%%%%%%%%

[A,B]=size(col);
L=ceil(Msens/A);
clrs=repmat(col,L,1);

labelinput_new=cell(1,Msens);


idx_all = 1:Msens;
idx_outlier = [15,16];
idx_outlier = idx_all;
idx_delete = setdiff(idx_all,idx_outlier);
n_delete = size(idx_delete,2);
Msens  =Msens - n_delete;
sigma(:,idx_delete) = [];
sigma_lb(:,idx_delete) = [];
sigma_ub(:,idx_delete) = [];
mi(:,idx_delete) = [];
mi_lb(:,idx_delete) = [];
mi_ub(:,idx_delete) = [];
nb_legend=nb_legend-n_delete;
labelinput(idx_delete) = [];
labelinput_new(idx_delete) = [];


% % CREATE DISCONTINUOUS AXIS FOR OUTLIERS:
%
% % % Find outlier in mean array:
% Loc_mi_outlier = isoutlier(mi);
% % Find outlier in sigma array:
% Loc_sigma_outlier = isoutlier(sigma);
% % Determine which/ if parameter value is an outlier for at least 1 axis:
% Loc_outlier = max(Loc_mi_outlier, Loc_sigma_outlier);
%
% if any(Loc_outlier == 1)
% mi_outlier = mi(Loc_outlier);
% mi_lb_outlier = mi(Loc_outlier);
% mi_ub_outlier = mi(Loc_outlier);
% mi_lb(Loc_outlier) = [];
% mi_ub(Loc_outlier) = [];
% mi(Loc_outlier) = [];
%
% sigma_outlier = sigma(Loc_outlier);
% sigma_lb_outlier = sigma(Loc_outlier);
% sigma_ub_outlier = sigma(Loc_outlier);
% sigma_lb(Loc_outlier) = [];
% sigma_ub(Loc_outlier) = [];
% sigma(Loc_outlier) = [];
% Msens2 = size(mi_outlier,2);
% Msens1 = Msens - Msens2;
%
% if any(Loc_mi_outlier==1)
%     mi_ub_max = max(mi_ub);
%     t = tiledlayout(1,2,'TileSpacing','compact');
%     x_tick = mi_ub_max/5;
%     bgAx = axes(t,'XTick',[],'YTick',[],'Box','off');
%     bgAx.Layout.TileSpan = [1 2];
%     ax1 = axes(t);
%     xline(ax1,mi_ub_max,':');
%     ax1.Box = 'off';
%     xlim(ax1,[0 mi_ub_max+1/mi_ub_max])
%     xlabel(ax1, 'First Interval')
%
%     % Create second plot
%     mi_lb_min = min(mi_lb_outlier)
%     mi_lb_max = max(mi_ub_outlier)
%     ax2 = axes(t);
%     ax2.Layout.Tile = 2;
%     for i=1:Msens2
%         plot(ax2,mi_outlier(i),sigma_outlier(i),'ok','MarkerFaceColor',clrs(i,:),'MarkerSize',ms,'MarkerEdgeColor','k')
%     end
%     xline(ax2,45,':');
%     ax2.YAxis.Visible = 'off';
%     ax2.Box = 'off';
%     xlim(ax2,[mi_lb_min-5/mi_lb_min mi_lb_max+5/mi_lb_max])
%     xlabel(ax2,'Second Interval')
%
%     % Link the axes
%     linkaxes([ax1 ax2], 'y')
% else
%     t1 = tiledlayout(1,1,'TileSpacing','compact');
%     ax1 = axes(t1);
% end


if sorting
    [mi,Sidx]=sort(mi,'descend') ;
    mi_ub = mi_ub(Sidx) ;
    mi_lb = mi_lb(Sidx) ;
    sigma = sigma(Sidx) ;
    sigma_ub = sigma_ub(Sidx) ;
    sigma_lb = sigma_lb(Sidx) ;
    for i=1:Msens; labelinput_new{i} = labelinput{Sidx(i)} ;end;
end

if nb_legend<Msens
    labelinput_new=labelinput_new(1:nb_legend);
    labelinput_new{end}=[labelinput_new{end},'...'];
end



MarkerShapeAvail = ['o';'s';'d';'^';'v';'>';'<'];

MarkerShape = MarkerShapeAvail;

while size(MarkerShape,1) < Msens
    MarkerShapeAvail = MarkerShapeAvail([2:end 1]);
    MarkerShape(end+1 : end+size(MarkerShapeAvail,1)) = MarkerShapeAvail;
end

% First plot EEs mean & std as circles:
for i=1:Msens
    loglog(sigma(i),mi(i),'k','Marker',MarkerShape(i), 'MarkerFaceColor',clrs(i,:),'MarkerSize',ms,'MarkerEdgeColor','k')
    hold on;
end

title(plottitle,'FontSize',14);
subtitle('N (model evaluations) = 10070 | n (Bootstrapping) = 1000 | \alpha = 0.05')

%plot first the larger confidence areas
size_bounds=mi_ub-mi_lb;
[tmp,idx]=sort(size_bounds,'descend');

for i=1:Msens % add rectangular shade:
    h = fill([sigma_lb(idx(i)),sigma_ub(idx(i)),sigma_ub(idx(i)),sigma_lb(idx(i))],...
        [mi_lb(idx(i)),mi_lb(idx(i)),mi_ub(idx(i)),mi_ub(idx(i))],clrs(idx(i),:));
end

% Plot again the circles (in case some have been overriden by the rectangles
% representing confidence bounds)
for i=1:Msens
    loglog(sigma(i),mi(i),'k','Marker',MarkerShape(i),'MarkerFaceColor',clrs(i,:),'MarkerSize',ms,'MarkerEdgeColor',cc)
    hold on;
end
y_threshold = yline(0.25,'--r',{'Threshold = 0.25 t/ha'},'LineWidth',1.5,...
    'HandleVisibility','off');
y_threshold.LabelHorizontalAlignment = 'right';

% Create legend:


legend(labelinput_new, 'Location','eastoutside')

set(gca,'FontSize',fs,'FontName',fn)
xlabel('\sigma [t/ha]','FontSize',fs,'FontName',fn);
% xlimit = get(gca, 'XLim');
ylimit = get(gca, 'YLim');
ylim([10^-3 10^2]);
ylabel('\mu [t/ha]','FontSize',fs,'FontName',fn);
% labelv.Position(1) = labelv.Position(1)-0.1 * labelv.Position(1);
% labelh.Position(2) = -0.05 * ylimit(2);
grid on

box on


%% ADJUSTMENT:
%

% OUTLIERS
auto = 1;
if auto == 0
if auto == 1
    mi_all = [mi'; mi_lb'; mi_ub'];
    idx_Outlier = isoutlier(mi_all);

    Outliers = mi_all(idx_Outlier);
    if ~isempty(Outliers)



        Outliers = sort(Outliers);
        Diff = diff(Outliers);
        [BreakWidth, Loc_BreakLowEnd] = max(Diff);
        BreakLowEnd = Outliers(Loc_BreakLowEnd);

        startpoint = 1.15*(BreakLowEnd);
        endpoint = 0.95*(BreakLowEnd + BreakWidth);
        splitYLim = [startpoint endpoint];

        YTick_end = ceil(max(Outliers));
        YTick = YTick_end /10;

        % YTick1_end = floor(startpoint-0.1);
        YTick1_end = startpoint-0.5;
        if YTick1_end < YTick
            YTick1 = min(startpoint-0.1, YTick1_end * 0.5);
        else
            YTick1 = YTick;
        end
        %     YTick2_start = ceil(endpoint+0.1);
        YTick2_start = endpoint+0.5;
        YTick2 = YTick;
        if (YTick2_start + YTick) > YTick_end | YTick2 == 0
            YTick2 = (YTick_end - YTick2_start) * 0.5;
        end


        YTick1 = round(YTick1,1);
        YTick1_end = round(YTick1_end,1);
        YTick2 = round(YTick2,1);
        YTick2_start = round(YTick2_start,1);
        YTick_end = round(YTick_end,1);


    else
        splitYLim = [3.1 5.9];
        YTick1 = 0.75;
        YTick2_start = 6;

        YTick1_end = 4*YTick1;
        YTick_end = 12;
    end

    yticks([0:YTick1:YTick1_end ,...
        YTick2_start:YTick2:YTick_end]);
    %     for i = 1 :length(YTick)
    %         t(1)=text(-0.002,YTick(i),num2str(YTick(i)),'FontSize',5,'FontName','Arial','Interpreter','tex','VerticalAlignment','middle','HorizontalAlignment','right');
    %         hold on;
    %         plot([0,0.002],[YTick(i),YTick(i)],'k');
    %     end

    breakyaxis(splitYLim)
end
end

%% END ADJUSTMENT