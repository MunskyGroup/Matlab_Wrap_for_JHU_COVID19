function Make_Movie(app)
% Make_Movie(app)
% This function makes a movie of the spatial JHU data selected in the
% COVID19_Matlab_App (app).

Nt = size(app.DATA,2);

% Creates and opens a new movie file
k = 1;
while exist(['movies/',app.RegionDropDown.Value,'_',num2str(k),'.mp4'],'file')
    k=k+1;
end
vidObj = VideoWriter(['movies/',app.RegionDropDown.Value,'_',num2str(k),'.mp4'],'MPEG-4');
open(vidObj);

switch app.map_what.Value
    case 'Active'
        DATA_all = app.DATA - app.DATA_Deaths - app.DATA_Recov;
    case 'Deaths'
        DATA_all = app.DATA_Deaths;
    case 'Cumulative Infected'
        DATA_all = app.DATA;
    case 'Recent Infected'
        DATA_all(:,1:7) = app.DATA(:,1:7);
        DATA_all = [DATA_all, app.DATA(:,8:end) - app.DATA(:,1:end-7)];
end
Lat_all = app.Lat;
Long_all = app.Long;
Lat = Lat_all;
Long = Long_all;
DATA = DATA_all;

% Iterate through time
for j = Nt-30:Nt
    figure(1); clf;
    clear h
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
            DATA = DATA_all(J,:);
            Lat = Lat_all(J,:);
            Long = Long_all(J,:);
        case 'US Per 10k'
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
            DATA = DATA_all(J,:)./app.Pop_Data(J)*1e4;
            Lat = Lat_all(J,:);
            Long = Long_all(J,:);
        case 'Europe'
            h = worldmap('Europe');  % Store the output handle!
            load coastlines
            plotm(coastlat, coastlon);
            geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    end
    % Bin data for plotting
    cmap = colormap('jet');
    if ~strcmp(app.RegionDropDown.Value,'US Per 10k')
        I = floor(log2(DATA(:,j)));
        mxI = log2(max(DATA(:)));
        mksize = linspace(4,30,mxI);
        app.TimeSlider.Limits = [-Nt+1,0];
        K = floor(linspace(1,size(cmap,1),floor(max(log2(DATA(:))))));
        ticklabs = 2.^[1:length(K)];
        cblab = 'Size of infection';
    else
        I = floor(log2(DATA(:,j))+5);
        mxI = log2(max(DATA(:)))+5;
        mksize = linspace(4,30,mxI);
        app.TimeSlider.Limits = [-Nt+1,0];
        K = floor(linspace(1,size(cmap,1),floor(max(log2(DATA(:)))+5)));
        ticklabs = 2.^([1:length(K)]-5);
        cblab = 'Size of infection per 10k';
    end
    
    % Add points for all states/regions
    if max(I)>=1
        for i=1:max(I)
            geoshow(Lat(I==i),Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color', cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',mksize(i))
        end
    end
    
%     h2=figure(2); clf
%     copyobj(h,h2);
%     colormap('jet')
    hcb2 = colorbar('east');
    hcb2.Position([2,4]) = [0.6,0.3];
    set(get(hcb2,'Xlabel'),'String',cblab)
    set(hcb2,'Ticks',linspace(0,1,length(K)),'TickLabels',ticklabs)
    title(['Map of Pandemic (',app.map_what.Value,') on ',app.dates{j}]);

    drawnow
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);

