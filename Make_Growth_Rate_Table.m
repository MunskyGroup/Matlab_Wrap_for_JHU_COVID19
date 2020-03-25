function [gr_rate,kept_states] = Make_Growth_Rate_Table(app,nf,DATA) 
% Make_Growth_Rate_Table(app) 
% This function calculates and makes a table for the growth rates of the
% pandemic in each individual country or state.  Uses the JHU COVID-19 data
% as requested in the COVID19_Matlab_App GUI (app).

% Create lists of all (B) and selected (A) countries/states.
if app.CountryButton.Value
    ListA = app.countries.Items;
    ListB = app.Countries;
elseif app.RegionButton.Value
    ListB = app.States;
    ListA = app.States;
    ListA=ListA(~strcmp(ListA,''));
end

if nargin<2
    nf = app.days_for_trend.Value;
    DATA = app.DATA;
elseif nargout>=1
    for i = 1:size(DATA,1)
        ListA(i) = {num2str(i)};
        ListB(i) = {num2str(i)};
    end
    kept_states = zeros(size(DATA,1),1,'logical');
end
NC = length(ListA);
N = size(DATA,2);
xf = [0:nf]';

j = 0;

if app.abs_2.Value
    cut_off_for_trend = 10;
else
    cut_off_for_trend = 0.01;
end

% Iterate through all selected states/countries and collect the
% corresponding data.
Data = {};
for i=1:NC
    I = ismember(ListB,ListA{i});
    inf_vs_t = sum(DATA(I,:),1);
    if inf_vs_t(end)>cut_off_for_trend   % Ignore regions with too few infections.
        j=j+1;
        % Perform regression to find log-slope.
        Y = log(inf_vs_t(N-nf:N))';
        x = xf(isfinite(Y));
        Y = Y(isfinite(Y));
        Q=[]; Q(:,1) = x'; Q(:,2)=1; M = Q\Y;
        M(1) = max(M(1),0);
        Data(i,1:2) = {ListA{i},log(2)./M(1)};
        kept_states(i) = 1;
    else
        kept_states(i) = 0;
        Data(i,1:2) = {ListA{i},inf};
    end
end
Data = Data(kept_states,:);
if nargout>=1
    gr_rate = [Data{:,2}]';
    return
end

% Sort growth rates fastest to slowest.
[~,I] = sort([Data{:,2}],'ascend');
app.gr_table.Data = Data(I,:);

% Make Histogram of growth rates.
histogram(app.gr_hist,[app.gr_table.Data{:,2}],[0:10],'Normalization','probability');