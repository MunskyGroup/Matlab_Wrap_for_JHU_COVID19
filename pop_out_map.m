function [h,cblab,ticklabs,K] = pop_out_map(app,j_time_to_plot,max_j,min_j)

if nargin<3
    max_j = j_time_to_plot;
end
if nargin<4
    min_j = j_time_to_plot;
end

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
    statesNames = app.States;
else
    DATA = app.Pop_Data.DATA;
    DATA_Deaths = app.Pop_Data.DATA_Deaths;
    DATA_Recov = app.Pop_Data.DATA_Recov;
    app.ax_infections.YLabel.String = 'Infections (per 10k individuals)';
    app.ax_deaths.YLabel.String = 'Deaths (per 10k individuals)';
    Lat = app.Pop_Data.Lat;
    Long = app.Pop_Data.Long;
    countries = app.Pop_Data.Country_Names;
    statesNames = app.Pop_Data.State;
end

switch app.map_what.Value
    case 'Active'
        DATA = max(0,DATA - DATA_Deaths - DATA_Recov);
    case 'Recovered'
        DATA = max(0,DATA_Recov);
    case 'Deaths'
        DATA = DATA_Deaths;
    case 'Cumulative Infected'
        DATA = DATA;
    case 'Recent Infected'
        Nwin = 10;
        DATA = max(0,[DATA(:,1:Nwin), DATA(:,Nwin+1:end) - DATA(:,1:end-Nwin)]);
end

% Create base map for World, US, or Europe
J = ones(size(DATA,1),1,'logical');
switch app.RegionDropDown.Value
    case {'World'}
    case {'US'}
        J = strcmp(countries,'US')&~strcmp(statesNames,'Alaska')...
            &~strcmp(statesNames,'Puerto Rico')...
            &~strcmp(statesNames,'Hawaii')...
            &~contains(statesNames,'Princess');
    case {'Europe'}
end

DATA = DATA(J,:);
% Lat = Lat(J);
% Long = Long(J);

% Bin data for plotting
cmap = colormap('jet');
DD = DATA(:,min_j:max_j);
DD(DD==0)=min(DD(DD~=0));
mnI = log2(min(DD(:)));
mxI = log2(max(DD(:)));
DD = DATA(:,j_time_to_plot);
l2D = log2(DD);
I = floor(12*(l2D-mnI)/(mxI-mnI));
K = 0:12;
KK = floor(linspace(1,size(cmap,1),13));
if app.abs_2.Value
    ticklabs = round(2.^(mnI+K.*(mxI-mnI)/12),-2);
    cblab = 'Size of infection';
else
    ticklabs = round(2.^(mnI+K.*(mxI-mnI)/12),0);
    cblab = 'Size of infection per 10k';
end

COLS = repmat(cmap(KK(1),:),length(I),1);
for i=1:max(I)
    COLS(I==i,:) = repmat(cmap(KK(i),:),sum(I==i),1);
end

% Create base map for World, US, or Europe
switch app.RegionDropDown.Value
    case {'World'}
        h = worldmap('World');  % Store the output handle!
        load coastlines
        plotm(coastlat, coastlon);
        geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    case {'US'}
        h = usamap('conus');
        states = shaperead('usastatelo', 'UseGeoCoords', true,...
            'Selector',...
            {@(name) any(strcmp(name,statesNames(J))), 'Name'});
        INDS = zeros(size(states,1),1);
        for jS = 1:size(states,1)
            INDS(jS) = find(strcmp(statesNames(J),states(jS).Name));
        end
        
        faceColors = makesymbolspec('Polygon',...
            {'INDEX', [1 numel(states)], 'FaceColor', ...
            COLS(INDS,:)}); %NOTE - colors are random
        geoshow(h, states, 'DisplayType', 'polygon', ...
            'SymbolSpec', faceColors)
        J = strcmp(countries,'US')&~strcmp(countries,'Alaska')&~strcmp(countries,'Hawaii')...
            &~contains(countries,'Princess');
    case {'Europe'}
        h = worldmap('Europe');  % Store the output handle!
        load coastlines
        plotm(coastlat, coastlon);
        geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
end

