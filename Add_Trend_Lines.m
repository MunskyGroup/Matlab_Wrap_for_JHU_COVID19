function Add_Trend_Lines(app)
N = length(app.inf_vs_t);
n = app.days_for_trend.Value;
n0 = app.days_for_pred.Value;
X = [1:N+14];
x = [0:n]'; 

%% Regresion for infections
Y = log(app.inf_vs_t(N-n-n0:N-n0))';
sxy = sum((x-mean(x)).*(Y-mean(Y))); sxx = sum((x-mean(x)).^2); syy = sum((Y-mean(Y)).^2);
m = sxy/sxx; b = mean(Y)-m*mean(x);
z1 = m*(X+n+n0-N)+b;
Z1 = exp(z1);
sr = sqrt((syy-m^2*sxx)/(n+2));
sy = sr*sqrt(1+1/n+(X+n+n0-N-mean(x)).^2/sxx);
UB = exp(z1+sy)-exp(z1);
LB = -exp(z1-sy)+exp(z1);

hold(app.ax_infections,'off')
errorbar(app.ax_infections,X,Z1,UB,LB,'b','linewidth',2)
hold(app.ax_infections,'on')
plot(app.ax_infections,[1:N],app.inf_vs_t,'ro',...
    [N-n0+1:N],app.inf_vs_t(end-n0+1:end),'ko',...    
    [1:N-n-n0],app.inf_vs_t(1:end-n-n0),'go',...
    'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
legend(app.ax_infections,{'Model +/- std','fit data','validation data'},'Location','NorthWest')
%% Regression for deaths
Y = log(app.dth_vs_t(N-n-n0:N-n0))';
sxy = sum((x-mean(x)).*(Y-mean(Y))); sxx = sum((x-mean(x)).^2); syy = sum((Y-mean(Y)).^2);
m = sxy/sxx; b = mean(Y)-m*mean(x);
z2 = m*(X+n+n0-N)+b;
Z2 = exp(z2);
sr = sqrt((syy-m^2*sxx)/(n+2));
sy = sr*sqrt(1+1/n+(X+n+n0-N-mean(x)).^2/sxx);
UB = exp(z2+sy)-exp(z2);
LB = -exp(z2-sy)+exp(z2);

hold(app.ax_deaths,'off')
errorbar(app.ax_deaths,X,Z2,UB,LB,'b','linewidth',2)
hold(app.ax_deaths,'on')
plot(app.ax_deaths,[1:length(app.inf_vs_t)],app.dth_vs_t,'ro',...
    [N-n0+1:N],app.dth_vs_t(end-n0+1:end),'ko',...    
    [1:N-n-n0],app.dth_vs_t(1:end-n-n0),'go',...
    'MarkerSize',10,'MarkerFaceColor','auto','linewidth',3)
legend(app.ax_deaths,{'Model +/- std','fit data','validation data'},'Location','NorthWest')

grid(app.ax_infections,'on')
grid(app.ax_deaths,'on')