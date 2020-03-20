function Add_Trend_Lines(app)
% Add_Trend_Lines(app)
% This function fits a simple exponential growth trend line to JHU data 
% selected in the COVID19_Matlab_App (app).

Nt = size(app.inf_vs_t,2);
Ns = size(app.inf_vs_t,1);
nf = app.days_for_trend.Value;
n0 = app.days_for_pred.Value;
mn_x = find(max(app.inf_vs_t,[],1)>0,1,'first');
X = [mn_x:Nt+5];
xf = [0:nf]';

hold(app.ax_infections,'off')
hold(app.ax_deaths,'off')

cmap = colormap('jet');
K = floor(linspace(1,size(cmap,1),Ns));

%% Regresion for infections
% Iterate through Ns regions.
for is = 1:Ns
    % Compute and plot trend line for infections
    [Z1,UB,LB,n] = compute_trend(xf,app.inf_vs_t(is,Nt-nf-n0:Nt-n0),X,Nt,nf,n0);
    make_trend_plot(app.ax_infections,X,app.inf_vs_t(is,:),Z1,UB,LB,Nt,n0,n,K,cmap,Ns,is)
    
    % Compute and plot trend line for deaths
    [Z1,UB,LB,n] = compute_trend(xf,app.dth_vs_t(is,Nt-nf-n0:Nt-n0),X,Nt,nf,n0);
    make_trend_plot(app.ax_deaths,X,app.dth_vs_t(is,:),Z1,UB,LB,Nt,n0,n,K,cmap,Ns,is)
end

% Make legends
if Ns>1
    if length(app.countries.Value)==1
        TMP(1:2:2*length(app.states.Value)) = app.states.Value;
        TMP(2:2:2*length(app.states.Value)) = app.states.Value;
    else
        TMP(1:2:2*length(app.countries.Value)) = app.countries.Value;
        TMP(2:2:2*length(app.countries.Value)) = app.countries.Value;
    end
    legend(app.ax_deaths,TMP);
    legend(app.ax_infections,TMP,'Location','eastoutside');
end
grid(app.ax_infections,'on')
grid(app.ax_deaths,'on')
end

function [Z1,UB,LB,n] = compute_trend(xf,yf,X,Nt,nf,n0)
% Compute the trend lines.
Y = log(yf)';
x = xf(isfinite(Y));
Y = Y(isfinite(Y));
n=length(Y);
sxy = sum((x-mean(x)).*(Y-mean(Y))); sxx = sum((x-mean(x)).^2); syy = sum((Y-mean(Y)).^2);
m = sxy/sxx; b = mean(Y)-m*mean(x);
z1 = m*(X+nf+n0-Nt)+b;
Z1 = exp(z1);
sr = sqrt((syy-m^2*sxx)/(n+2));
sy = sr*sqrt(1+1/n+(X+nf+n0-Nt-mean(x)).^2/sxx);
UB = exp(z1+sy)-exp(z1);
LB = -exp(z1-sy)+exp(z1);
end

function make_trend_plot(ax,X,Y,Z1,UB,LB,Nt,n0,n,K,cmap,Ns,is)
% Make plot of data and trend lines.
if Ns==1
    errorbar(ax,X,Z1,UB,LB,'b','linewidth',2)
    hold(ax,'on')
    plot(ax,[1:Nt],Y,'ro',...
        [Nt-n0+1:Nt],Y(end-n0+1:end),'ko',...
        [1:Nt-n-n0],Y(1:end-n-n0),'go',...
        'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
    legend(ax,{'Model +/- std','fit data','validation data'},'Location','NorthWest')
else
    plot(ax,X,Z1,'linewidth',2,'color',cmap(K(is),:))
    hold(ax,'on')
    plot(ax,[1:Nt],Y,'o','color',cmap(K(is),:),...
        'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
end
ym = get(ax,'ylim');
ym(1)=max(ym(1),1);
set(ax,'ylim',ym);

end
    

