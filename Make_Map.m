function Make_Map(app)

Nt = size(app.DATA,2);
j = round(app.TimeSlider.Value)+Nt;

h = worldmap('World');  % Store the output handle!
load coastlines
[latcells, loncells] = polysplit(coastlat, coastlon);
plotm(coastlat, coastlon);
geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])

I = floor(log2(app.DATA(:,j)));
app.TimeSlider.Limits = [-Nt+1,0];

%% change colormap
cmap = colormap('jet');
K = floor(linspace(1,size(cmap,1),floor(max(log2(app.DATA(:))))));


%%
for i=1:max(I)
    geoshow(app.Lat(I==i),app.Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color',cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',i)
end

copyobj(h.Children, app.map);  % Copy all of the axis' children to your app axis
delete(h.Parent) % get rid of the figure created by worldmap()

hcb = colorbar(app.map,'southoutside');
set(get(hcb,'Xlabel'),'String','Size of infection')
set(hcb,'Ticks',linspace(0,1,length(K(1:2:end))),'TickLabels',2.^[1:2:length(K)])



