function Make_Growth_Rate_Table(app) 
N = size(app.DATA,2);
nf = app.days_for_trend.Value;
xf = [0:nf]';

if app.CountryButton.Value
    ListA = app.countries.Items;
    ListB = app.Countries;
elseif app.RegionButton.Value
%     ListA = app.states.Items;
    ListB = app.States;
    ListA = app.States;
    ListA=ListA(~strcmp(ListA,''));
end
NC = length(ListA);
j = 0;

Data = {};
for i=1:NC
    I = ismember(ListB,ListA{i});
    inf_vs_t = sum(app.DATA(I,:),1);
    if inf_vs_t(end)>10
        j=j+1;
        Y = log(inf_vs_t(N-nf:N))';
        x = xf(isfinite(Y));
        Y = Y(isfinite(Y));
        Q=[]; Q(:,1) = x'; Q(:,2)=1; M = Q\Y;
        M(1) = max(M(1),0);
        Data(j,1:2) = {ListA{i},log(2)./M(1)};
    end
end
[~,I] = sort([Data{:,2}],'ascend');
app.gr_table.Data = Data(I,:);

histogram(app.gr_hist,[app.gr_table.Data{:,2}],[0:10],'Normalization','probability');