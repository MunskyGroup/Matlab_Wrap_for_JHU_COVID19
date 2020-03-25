function [h,cblab,ticklabs,K] = pop_out_map(app,j_time_to_plot)

figure(314); clf;

if app.abs_2.Value
    DATA = app.DATA;
    DATA_Deaths = app.DATA_Deaths;
    DATA_Recov = app.DATA_Recov;
    app.ax_infections.YLabel.String = 'Infections (absolute number)';
    app.ax_deaths.YLabel.String = 'Deaths (absolute number)';
    Lat = app.Lat;
    Long = app.Long;
    countries = app.Countries;
else
    DATA = app.Pop_Data.DATA;
    DATA_Deaths = app.Pop_Data.DATA_Deaths;
    DATA_Recov = app.Pop_Data.DATA_Recov;
    app.ax_infections.YLabel.String = 'Infections (per 10k individuals)';
    app.ax_deaths.YLabel.String = 'Deaths (per 10k individuals)';
    Lat = app.Pop_Data.Lat;
    Long = app.Pop_Data.Long;
    countries = app.Pop_Data.Country_Names;
end

switch app.map_what.Value
    case 'Active'
        DATA = DATA - DATA_Deaths - DATA_Recov;
    case 'Deaths'
        DATA = DATA_Deaths;
    case 'Cumulative Infected'
        DATA = DATA;
    case 'Recent Infected'
        DATA = max(0,[DATA(:,1:3), DATA(:,4:end) - DATA(:,1:end-3)]);
end

% Create base map for World, US, or Europe
J = ones(size(DATA,1),1,'logical');
switch app.RegionDropDown.Value
    case {'World','World per 10k'}
        h = worldmap('World');  % Store the output handle!
        load coastlines
        plotm(coastlat, coastlon);
        geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    case {'US','US per 10k'}
        h = usamap('conus');
        states = shaperead('usastatelo', 'UseGeoCoords', true,...
            'Selector',...
            {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
        faceColors = makesymbolspec('Polygon',...
            {'INDEX', [1 numel(states)], 'FaceColor', ...
            polcmap(numel(states))}); %NOTE - colors are random
        geoshow(h, states, 'DisplayType', 'polygon', ...
            'SymbolSpec', faceColors)
        J = strcmp(countries,'US')&~strcmp(countries,'Alaska')&~strcmp(countries,'Hawaii')...
            &~contains(countries,'Princess');
    case {'Europe','Europe per 10k'}
        h = worldmap('Europe');  % Store the output handle!
        load coastlines
        plotm(coastlat, coastlon);
        geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
end

DATA = DATA(J,:);
Lat = Lat(J);
Long = Long(J);

% Extrapolate for future dates.
Nt = size(DATA,2);
if j_time_to_plot>Nt
    nf = 5;
    [gr_rate,kept_states] = Make_Growth_Rate_Table(app,nf,DATA);
    for jt = Nt+1:j_time_to_plot
        DATA(kept_states,jt) = DATA(kept_states,jt-1).*(2.^(1./gr_rate));
        DATA(~kept_states,jt) = DATA(~kept_states,jt-1);
    end
end

% Bin data for plotting
cmap = colormap('jet');
if app.abs_2.Value
    I = floor(log2(DATA(:,j_time_to_plot)));
    mxI = log2(max(DATA(:)));
    mksize = linspace(4,30,mxI);
    K = floor(linspace(1,size(cmap,1),floor(log2(max(DATA(:))))));
    ticklabs = 2.^[1:length(K)];
    cblab = 'Size of infection';
else
    nb = 7;
    I = floor(log2(DATA(:,j_time_to_plot))+nb);
    mxI = log2(max(DATA(:)))+nb;
    mksize = linspace(4,30,mxI);
    K = floor(linspace(1,size(cmap,1),floor(log2(max(DATA(:)))+nb)));    
    ticklabs = 2.^([1:length(K)]-nb);
    cblab = 'Size of infection per 10k';
end

% Add points for all states/regions
for i=1:max(I)
    geoshow(Lat(I==i),Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color',cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',mksize(i))
end