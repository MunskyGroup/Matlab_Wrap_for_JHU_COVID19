
close all force
clear all
Np = 1000;
Nt = 1000;

x = 0.01*randn(Np,Nt,2); x(:,1,:) = randn(Np,2);
x = cumsum(x,2);
x = mod(x,2);

for i = 1:1:length(x)
    plot(x(:,i,1),x(:,i,2),'ro');
    set(gca,'xlim',[0 1],'ylim',[0 1]);
    drawnow
end


%%
clear all
Np = 100;
Nt = 2000;

typ = zeros(Np,1);
typ(1) = 1;

x(1:Np,1:2) = randn(Np,2);
t = 2*pi*rand(Np,1);

for i = 1:Nt
    dx = 0.002*[sin(t),cos(t)];
    x = x + dx;
    x = mod(x,1);
    rmat = pdist2(x,x,'euclidean');
    rmat(rmat==0) = NaN;
    I1 = find(min(rmat)<0.02);
    t(I1) = 2*pi*randn(length(I1),1);
    rmat2 = (rmat<0.02)&(~isnan(rmat));
    inf_neigh = rmat2*typ;

    typ(typ==0&inf_neigh>0)=1;
    
    clf
    plot(x(typ==0,1),x(typ==0,2),'go','markerfacecolor','g','markersize',8); 
    hold on
    plot(x(typ==1,1),x(typ==1,2),'bo','markerfacecolor','b','markersize',8);

    if mod(i,10)==0
        set(gca,'xlim',[0 1],'ylim',[0 1]);
        drawnow
        pause(0.1)
    end
end
