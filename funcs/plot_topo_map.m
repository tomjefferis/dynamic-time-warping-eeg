function plots = plot_topo_map(stat, start_time, end_time)

difference = linspace(start_time, end_time, 16); %amount of subplots in this

if isfield(stat, 'posclusters') || isfield(stat, 'negclusters')
    try
        posStat = stat.posclusters(1).prob;
    catch
        posStat = 100;
    end
    
    try
        negStat = stat.negclusters(1).prob;
    catch
        negStat = 100;
    end
    
    if posStat <= negStat
        polarity = "positive";
    else
        polarity = "negative";
    end
    
    if strcmp(polarity, "positive")
        clustermark = stat.posclusterslabelmat;
    else
        clustermark = stat.negclusterslabelmat;
    end
    
    clustermark(clustermark > 1) = 0;
    
    maxstat = max(max(stat.stat))/2;
    minstat = min(min(stat.stat))/2;
    
    %replacing nans with 0 to not break function
    stat.stat(isnan(stat.stat))=0;
    parameter = 'stat';
    parameter2 = 'on';
else
    polarity = "positive";
    clustermark = zeros(size(stat.avg));
    maxstat = max(max(stat.avg))/2;
    minstat = min(min(stat.avg))/2;
    parameter = 'avg';
    parameter2 = 'off';
end
figure;
set(gcf, 'Position',  [100, 100, 1600, 400]);

tiledlayout(2,8);

for i = 1:15
    nexttile;
    %finding time window from the closest times in the series to the inputs
    lower = interp1(stat.time, 1:length(stat.time), difference(i), 'nearest');
    upper = interp1(stat.time, 1:length(stat.time), difference(i + 1), 'nearest');
    
    if isnan(upper)
        upper = length(stat.time);
    end
    
    if isnan(lower)
        lower = length(stat.time) - 1;
    end
    highlight = clustermark(:, lower:upper) == 1;
    % sum to a single column
    highlight = sum(highlight, 2);
    % if highlight >1 set to 1
    highlight(highlight > 1) = 1;
    % if empty fill zeros
    if isempty(highlight)
        highlight = zeros(1, length(stat.label));
    end
    highlight = stat.label(highlight == 1);
    
    % cfg for plot
    cfg = [];
    cfg.xlim = [difference(i), difference(i + 1)];
    cfg.highlight = parameter2;
    cfg.highlightchannel = highlight;
    cfg.highlightcolor = [1 0 0];
    cfg.highlightsymbolseries = ['*', '*', '.', '.', '.'];
    cfg.highlightsize = 8;
    cfg.contournum = 0;
    cfg.alpha = 0.05;
    cfg.parameter = parameter;
    cfg.figure = 'gcf';
    cfg.zlim = [minstat,maxstat];
    
    %if i == 5
    %    cfg.colorbar = 'South'; % adds to every plot usually disabled, uness need figure with bar
    %end
    
    %cfg.parameter = 'stat';
    ft_topoplotER(cfg, stat);
    %t = title(strcat(string(round(difference(i),2)), " - ", string(round(difference(i+1),2)), "s"));
    %t_pos = get(t,'position');
    %set(t,'position',[t_pos(1) t_pos(2)/2 t_pos(3)])
    
end

cb = colorbar;
cb.Layout.Tile = 'east';
a=get(cb); %gets properties of colorbar
a =  a.Position; %gets the positon and size of the color bar
cb.Position = [a(1), a(2), a(3)/2, a(4)];
set(cb,'Position',[a(1), a(2), a(3)/2, a(4)])% To change size


results_fact = 'DTW';
imgname = strcat(results_fact, " ", string(start_time), "  topomap.png");

title_main = strcat("Topographic map of significant clusters ", results_fact);

imgname = strcat(polarity, " ", imgname);

save_dir_full = "Results/" + imgname;

plots = gcf;
sgtitle(title_main);
saveas(gcf, save_dir_full);
hold off;
end