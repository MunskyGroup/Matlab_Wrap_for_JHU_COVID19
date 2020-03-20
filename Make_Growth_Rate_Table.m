function Make_Growth_Rate_Table(app) 
% Make_Growth_Rate_Table(app) 
% This function calculates and makes a table for the growth rates of the
% pandemic in each individual country or state.  Uses the JHU COVID-19 data
% as requested in the COVID19_Matlab_App GUI (app).

N = size(app.DATA,2);
nf = app.days_for_trend.Value;
xf = [0:nf]';

% Create lists of all (B) and selected (A) countries/states.
if app.CountryButton.Value
    ListA = app.countries.Items;
    ListB = app.Countries;
elseif app.RegionButton.Value
    ListB = app.States;
    ListA = app.States;
    ListA=ListA(~strcmp(ListA,''));
end
NC = length(ListA);
j = 0;

% Iterate through all selected states/countries and collect the
% corresponding data.
Data = {};
for i=1:NC
    I = ismember(ListB,ListA{i});
    inf_vs_t = sum(app.DATA(I,:),1);
    if inf_vs_t(end)>10   % Ignore regions with fewer than 10 infections.
        j=j+1;
        % Perform regression to find log-slope.
        Y = log(inf_vs_t(N-nf:N))';
        x = xf(isfinite(Y));
        Y = Y(isfinite(Y));
        Q=[]; Q(:,1) = x'; Q(:,2)=1; M = Q\Y;
        M(1) = max(M(1),0);
        Data(j,1:2) = {ListA{i},log(2)./M(1)};
    end
end
% Sort growth rates fastest to slowest.
[~,I] = sort([Data{:,2}],'ascend');
app.gr_table.Data = Data(I,:);

% Make Histogram of growth rates.
histogram(app.gr_hist,[app.gr_table.Data{:,2}],[0:10],'Normalization','probability');