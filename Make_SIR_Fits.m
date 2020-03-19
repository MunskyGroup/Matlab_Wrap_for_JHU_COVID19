function Make_SIR_Fits(app)

%% Data
I = ismember(app.Countries,app.countries_2.Value);
inf_vs_t = sum(app.DATA(I,:),1);
dth_vs_t = sum(app.DATA_Deaths(I,:),1);
rcv_vs_t = sum(app.DATA_Recov(I,:),1);

%% SIR Model
S = [-1 1 0 0 0;...% inf 
    0 -1 0 1 0;...% recov 
    0 -1 1 0 0;...% become serious
    0 -1 0 1 0;...% recov
    0 0 -1 0 1]';% death 
% x0 = [app.sir_parameters.Data{6,2};...
%     app.sir_parameters.Data{7,2};...
%     app.sir_parameters.Data{8,2};...
%     app.sir_parameters.Data{9,2};...
%     app.sir_parameters.Data{10,2}];
x0 = [app.sir_parameters.Data{6,2};...
    1/2*max(1,inf_vs_t(1)-dth_vs_t(1)-rcv_vs_t(1));...
    1/2*max(1,inf_vs_t(1)-dth_vs_t(1)-rcv_vs_t(1));...    
    max(1,rcv_vs_t(1));max(1,dth_vs_t(1))];

prop = @(x)[app.sir_parameters.Data{1,2}*x(1)*(x(2)+x(3));...
    app.sir_parameters.Data{2,2}*x(2);...
    app.sir_parameters.Data{3,2}*x(2);...
    app.sir_parameters.Data{2,2}*x(3);...
    app.sir_parameters.Data{4,2}*x(3)];

TAarray = linspace(0,200,501);

fn = @(t,x)S*prop(x)*(t>app.sir_parameters.Data{5,2});
options = odeset('MaxStep',1);
[~,X_Array] = ode23s(fn,TAarray,x0);
X_Array = X_Array';

%%
hold(app.sir_plot,'off');
plot(app.sir_plot,inf_vs_t,'ro','markersize',12,'markerfacecolor','auto','linewidth',2)
hold(app.sir_plot,'on');
plot(app.sir_plot,dth_vs_t,'bo','markersize',12,'markerfacecolor','auto','linewidth',2)
plot(app.sir_plot,rcv_vs_t,'go','markersize',12,'markerfacecolor','auto','linewidth',2)
plot(app.sir_plot,TAarray,[0 1 1 1 1]*X_Array,'r','linewidth',3);
plot(app.sir_plot,TAarray,[0 0 0 0 1]*X_Array,'b','linewidth',3);
plot(app.sir_plot,TAarray,[0 0 0 1 0]*X_Array,'g','linewidth',3);
legend(app.sir_plot,{'Infected','Death','Recovered'},'Location','southeast')
set(app.sir_plot,'ylim',[0.9 max(X_Array(:))]);

if app.lin_2.Value
    set(app.sir_plot,'yscale','lin');
else
    set(app.sir_plot,'yscale','log');
end
grid(app.sir_plot,'on');

