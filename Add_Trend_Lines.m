function Add_Trend_Lines(app)
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
for is = 1:Ns
    Y = log(app.inf_vs_t(is,Nt-nf-n0:Nt-n0))';
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
    
    if Ns==1
        errorbar(app.ax_infections,X,Z1,UB,LB,'b','linewidth',2)
        hold(app.ax_infections,'on')
        plot(app.ax_infections,[1:Nt],app.inf_vs_t(is,:),'ro',...
            [Nt-n0+1:Nt],app.inf_vs_t(is,end-n0+1:end),'ko',...
            [1:Nt-n-n0],app.inf_vs_t(is,1:end-n-n0),'go',...
            'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
        legend(app.ax_infections,{'Model +/- std','fit data','validation data'},'Location','NorthWest')
    else
        plot(app.ax_infections,X,Z1,'linewidth',2,'color',cmap(K(is),:))
        hold(app.ax_infections,'on')
        plot(app.ax_infections,[1:Nt],app.inf_vs_t(is,:),'o','color',cmap(K(is),:),...
            'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
    end
    
    %% Regression for deaths
    Y = log(app.dth_vs_t(is,Nt-nf-n0:Nt-n0))';
    x = xf(isfinite(Y));
    Y = Y(isfinite(Y));
    n=length(Y);
    sxy = sum((x-mean(x)).*(Y-mean(Y))); sxx = sum((x-mean(x)).^2); syy = sum((Y-mean(Y)).^2);
    m = sxy/sxx; b = mean(Y)-m*mean(x);
    z2 = m*(X+nf+n0-Nt)+b;
    Z2 = exp(z2);
    sr = sqrt((syy-m^2*sxx)/(n+2));
    sy = sr*sqrt(1+1/n+(X+nf+n0-Nt-mean(x)).^2/sxx);
    UB = exp(z2+sy)-exp(z2);
    LB = -exp(z2-sy)+exp(z2);
    
    if Ns ==1
        errorbar(app.ax_deaths,X,Z2,UB,LB,'b','linewidth',2)
        hold(app.ax_deaths,'on')
        plot(app.ax_deaths,[1:Nt],app.dth_vs_t(is,:),'ro',...
            [Nt-n0+1:Nt],app.dth_vs_t(is,end-n0+1:end),'ko',...
            [1:Nt-n-n0],app.dth_vs_t(is,1:end-n-n0),'go',...
            'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
        legend(app.ax_deaths,{'Model +/- std','fit data','validation data'},'Location','NorthWest')
    else
        plot(app.ax_deaths,X,Z2,'color',cmap(K(is),:));
        hold(app.ax_deaths,'on')
        plot(app.ax_deaths,[1:Nt],app.dth_vs_t(is,:),'o','color',cmap(K(is),:),...
            'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
    end
    hold(app.ax_deaths,'on')
end
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