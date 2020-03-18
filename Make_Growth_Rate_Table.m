function Make_Growth_Rate_Table(app) 
N = length(app.inf_vs_t);
n = app.days_for_trend.Value;
X = [1:N+n];

NC = length(app.countries.Items);
j = 0;

Data = {};
for i=1:NC
    I = ismember(app.Countries,app.countries.Items{i});
    inf_vs_t = sum(app.DATA(I,10:end),1);
    if inf_vs_t(end)>100
        j=j+1;
        Y = log(inf_vs_t(N-n:N))';
        Q(:,1) = [0:n]'; Q(:,2)=1; M = Q\Y;
        M(1) = max(M(1),0);
        Data(j,1:2) = {app.countries.Items{i},log(2)./M(1)};
    end
end
[~,I] = sort([Data{:,2}],'ascend');
app.gr_table.Data = Data(I,:);

histogram(app.gr_hist,[app.gr_table.Data{:,2}],[0:10],'Normalization','probability');