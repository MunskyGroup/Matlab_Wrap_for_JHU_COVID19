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
    
    for i=1:max(I)
        geoshow(app.Lat(I==i),app.Long(I==i),'DisplayType', 'Point', 'Marker', 'o', 'Color', 'red','MarkerFaceColor', 'red','MarkerSize',i)
    end
    title(app.dates{j})
    drawnow
    currFrame = getframe(gcf);
    writeVideo(vidObj,currFrame);
end
close(vidObj);
 
