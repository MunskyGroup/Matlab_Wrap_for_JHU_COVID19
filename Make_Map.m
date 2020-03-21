function Make_Map(app)
% Make_Map(app)
% This function makes a map of the JHU infection data for the 
% COVID19_Matlab_App (app).

close all
cla(app.map);
Nt = size(app.DATA,2);
j = round(app.TimeSlider.Value)+Nt;
DATA = app.DATA;
Lat = app.Lat;
Long = app.Long;

app.TimeSlider.MajorTicks = [-Nt+1:5:0];
app.TimeSlider.MinorTicks = [-Nt+1:1:0];
app.TimeSlider.MajorTickLabels = {app.dates{1:5:end}};


% Create base map for World, US, or Europe
switch app.RegionDropDown.Value
    case 'World'
        h = worldmap('World');  % Store the output handle!
        load coastlines
        plotm(coastlat, coastlon);
        geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    case 'US'
        h = usamap('conus');
        states = shaperead('usastatelo', 'UseGeoCoords', true,...
            'Selector',...
            {@(name) ~any(strcmp(name,{'Alaska','Hawaii'})), 'Name'});
        faceColors = makesymbolspec('Polygon',...
            {'INDEX', [1 numel(states)], 'FaceColor', ...
            polcmap(numel(states))}); %NOTE - colors are random
        geoshow(h, states, 'DisplayType', 'polygon', ...
            'SymbolSpec', faceColors)    
        J = strcmp(app.Countries,'US')&~strcmp(app.Countries,'Alaska')&~strcmp(app.Countries,'Hawaii')...
            &~contains(app.Countries,'Princess');
        DATA = DATA(J,:);
        Lat = Lat(J,:);
        Long = Long(J,:);
case 'Europe'
    h = worldmap('Europe');  % Store the output handle!
    load coastlines
    plotm(coastlat, coastlon);
    geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
end

% Bin data for plotting
I = floor(log2(DATA(:,j)));
mxI = log2(max(DATA(:)));
mksize = linspace(4,30,mxI);
app.TimeSlider.Limits = [-Nt+1,0];

%% change colormap
cmap = colormap('jet');
K = floor(linspace(1,size(cmap,1),floor(max(log2(DATA(:))))));

% Add points for all states/regions
for i=1:max(I)
    geoshow(Lat(I==i),Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color',cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',mksize(i))
end

copyobj(h.Children, app.map);  % Copy all of the axis' children to app axis
% delete(h.Parent) % get rid of the figure created by worldmap()
% Add colorbar for scale.
colormap(app.map,'jet')
hcb = colorbar(app.map,'southoutside');
set(get(hcb,'Xlabel'),'String','Size of infection')
set(hcb,'Ticks',linspace(0,1,length(K)),'TickLabels',2.^[1:length(K)])

app.map.Title.String = ['Map of Pandemic on ',app.dates{j}];

figure(2)
h=gca;
copyobj(app.map.Children,h);
colormap(app.map,'jet')
hcb2 = colorbar('southoutside');
set(get(hcb2,'Xlabel'),'String','Size of infection')
set(hcb2,'Ticks',linspace(0,1,length(K)),'TickLabels',2.^[1:length(K)])
title(['Map of Pandemic on ',app.dates{j}])
saveas(h,['screenshots/',app.RegionDropDown.Value],'png')

