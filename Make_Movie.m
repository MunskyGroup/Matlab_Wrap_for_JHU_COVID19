function Make_Movie(app)
% Make_Movie(app)
% This function makes a movie of the spatial JHU data selected in the 
% COVID19_Matlab_App (app).

Nt = size(app.DATA,2);

% Creates and opens a new movie file
k = 1;
while exist(['Pandemic_',num2str(k),'.avi'],'file')
    k=k+1;
end
vidObj = VideoWriter(['Pandemic_',num2str(k),'.avi']);
open(vidObj);

DATA = app.DATA;
Lat = app.Lat;
Long = app.Long;

% Define color map
cmap = colormap('jet');
K = floor(linspace(1,size(cmap,1),max(log2(DATA(:)))));
    
app.TimeSlider.Limits = [-Nt+1,0];

% Iterate through time
for j = 1:Nt
    figure(1); clf;
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
            rng(0)
            faceColors = makesymbolspec('Polygon',...
                {'INDEX', [1 numel(states)], 'FaceColor', ...
                polcmap(numel(states))}); %NOTE - colors are random
            geoshow(h, states, 'DisplayType', 'polygon', ...
                'SymbolSpec', faceColors)
            J = strcmp(app.Countries,'US')&~strcmp(app.Countries,'Alaska')&~strcmp(app.Countries,'Hawaii')...
                &~contains(app.Countries,'Princess');
            DATA = app.DATA(J,:);
            Lat = app.Lat(J,:);
            Long = app.Long(J,:);
        case 'Europe'
            h = worldmap('Europe');  % Store the output handle!
            load coastlines
            plotm(coastlat, coastlon);
            geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    end

    % Bin data for plotting
    I = floor(log2(DATA(:,j)));
    
    % Add points for all states/regions
    if max(I)>=1
        for i=1:max(I)
            geoshow(Lat(I==i),Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color', cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',i)
        end
    end
    
    % Add date to title.
    title(app.dates{j})
    
    % Add colorbar for scale.
    hcb = colorbar('southoutside');
    set(get(hcb,'Xlabel'),'String','Size of infection')
    set(hcb,'Ticks',linspace(0,1,length(K(1:2:end))),'TickLabels',2.^[1:2:length(K)])
    
    drawnow
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);

