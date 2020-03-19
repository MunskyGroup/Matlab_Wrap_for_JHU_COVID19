function Fit_to_data(app)
%% Data
I = ismember(app.Countries,app.countries_2.Value);
inf_vs_t = sum(app.DATA(I,:),1);
dth_vs_t = sum(app.DATA_Deaths(I,:),1);
rcv_vs_t = sum(app.DATA_Recov(I,:),1);

err_in_fit = @(x)get_err(10.^x,inf_vs_t,dth_vs_t,rcv_vs_t);
options = optimset('display','iter');
pars = fminsearch(err_in_fit,log10([app.sir_parameters.Data{:,2}]),options);
err_in_fit(pars)
app.sir_parameters.Data(:,2) = num2cell(10.^pars');

Make_SIR_Fits(app)

function err_in_fit = get_err(par,inf_vs_t,dth_vs_t,rcv_vs_t)
S = [-1 1 0 0 0;...% inf 
    0 -1 0 1 0;...% recov 
    0 -1 1 0 0;...% become serious
    0 -1 0 1 0;...% recov
    0 0 -1 0 1]';% death 
% x0 = par(6:10);
x0 = [par(6);1/2*max(1,inf_vs_t(1)-dth_vs_t(1)-rcv_vs_t(1));...
    1/2*max(1,inf_vs_t(1)-dth_vs_t(1)-rcv_vs_t(1));...
    max(1,rcv_vs_t(1));max(1,dth_vs_t(1))];

prop = @(x)[par(1)*x(1)*(x(2)+x(3));...
    par(2)*x(2);...
    par(3)*x(2);...
    par(2)*x(3);...
    par(4)*x(3)];

TAarray = [1:length(inf_vs_t)];
fn = @(t,x)S*prop(x)*(t>par(5));
options = odeset('MaxStep',1);
[~,X_Array] = ode23s(fn,TAarray,x0,options);
X_Array = X_Array';
y_inf = max(1,[0 1 1 1 1]*X_Array);
y_d = max(1,[0 0 0 0 1]*X_Array);
y_r = max(1,[0 0 0 1 0]*X_Array);
% err_in_fit = sum((y_inf-inf_vs_t).^2)+...
%     sum((y_r-rcv_vs_t).^2)+...
%     sum((y_d-dth_vs_t).^2);
 
inf_vs_t = max(1,inf_vs_t);
rcv_vs_t = max(1,rcv_vs_t);
dth_vs_t = max(1,dth_vs_t);

err_in_fit = sum(abs(log(y_inf)-log(inf_vs_t)))+...
    sum(abs(log(y_r)-log(rcv_vs_t)))+...
    sum(abs(log(y_d)-log(dth_vs_t)));
% err_in_fit = sum(abs(log(y_inf)-log(inf_vs_t)))+...
%     sum(abs(log(y_d)-log(dth_vs_t)));
    
    
