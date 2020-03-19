function Make_Map(app)
close all
cla(app.map);
Nt = size(app.DATA,2);
j = round(app.TimeSlider.Value)+Nt;
DATA = app.DATA;
Lat = app.Lat;
Long = app.Long;
switch app.RegionDropDown.Value
    case 'World'
        h = worldmap('World');  % Store the output handle!
        load coastlines
%         [latcells, loncells] = polysplit(coastlat, coastlon);
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
    %         [latcells, loncells] = polysplit(coastlat, coastlon);
    plotm(coastlat, coastlon);
    geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
end

I = floor(log2(DATA(:,j)));
app.TimeSlider.Limits = [-Nt+1,0];

%% change colormap
cmap = colormap('hsv');
K = floor(linspace(1,size(cmap,1),floor(max(log2(DATA(:))))));

%%
for i=1:max(I)
    geoshow(Lat(I==i),Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color',cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',i)
end

copyobj(h.Children, app.map);  % Copy all of the axis' children to your app axis
delete(h.Parent) % get rid of the figure created by worldmap()

hcb = colorbar(app.map,'southoutside');
set(get(hcb,'Xlabel'),'String','Size of infection')
set(hcb,'Ticks',linspace(0,1,length(K(1:2:end))),'TickLabels',2.^[1:2:length(K)])



