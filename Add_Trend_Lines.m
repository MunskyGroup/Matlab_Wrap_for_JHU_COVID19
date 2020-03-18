function Add_Trend_Lines(app)
N = length(app.inf_vs_t);
n = app.days_for_trend.Value;
X = [1:N+n];

Y = log(app.inf_vs_t(N-n:N))';
Q(:,1) = [0:n]'; Q(:,2)=1; M = Q\Y;
Z1 = exp(M(1)*(X+n-N)+M(2));

Y = log(app.dth_vs_t(N-n:N))';
Q(:,1) = [0:n]'; Q(:,2)=1; M = Q\Y;
Z2 = exp(M(1)*(X+n-N)+M(2));

plot(app.ax_infections,[1:length(app.inf_vs_t)],app.inf_vs_t,'rs',X,Z1,'b--')
plot(app.ax_deaths,[1:length(app.inf_vs_t)],app.dth_vs_t,'rs',X,Z2,'b--')
grid(app.ax_infections,'on')
grid(app.ax_deaths,'on')