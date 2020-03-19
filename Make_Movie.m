function Make_Movie(app)

Nt = size(app.DATA,2);

figure(1); clf;
k = 1;
while exist(['Pandemic_',num2str(k),'.avi'],'file')
    k=k+1;
end

vidObj = VideoWriter(['Pandemic_',num2str(k),'.avi']);
open(vidObj);

for j = 1:Nt
    clf;
    
    worldmap('World');  % Store the output handle!
    load coastlines
    [latcells, loncells] = polysplit(coastlat, coastlon);
    plotm(coastlat, coastlon);
    geoshow('landareas.shp', 'FaceColor', [0.15 0.5 0.15])
    
    I = floor(log2(app.DATA(:,j)));
    app.TimeSlider.Limits = [-Nt+1,0];
    
    cmap = colormap('hsv');
    K = floor(linspace(1,size(cmap,1),max(log2(app.DATA(:)))));
    for i=1:max(I)
        geoshow(app.Lat(I==i),app.Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color',cmap(K(i),:),'MarkerFaceColor',cmap(K(i),:),'MarkerSize',i)
    end
    
    title(app.dates{j})
    
    hcb = colorbar('southoutside');
    set(get(hcb,'Xlabel'),'String','Size of infection')
    set(hcb,'Ticks',linspace(0,1,length(K(1:2:end))),'TickLabels',2.^[1:2:length(K)])
    
    drawnow
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);
 
