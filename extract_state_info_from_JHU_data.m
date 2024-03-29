warning('off')
addpath('../COVID-19/csse_covid_19_data/csse_covid_19_time_series/')
W = importdata('time_series_covid19_confirmed_global.csv');
dates = W.textdata(1,5:end);

X = importdata('data/states_populations.csv');
us_state_names = X.textdata(2:end,1);
for i=1:length(us_state_names)
    if strcmp(us_state_names{i}(1),'.')
        us_state_names(i)={us_state_names{i}(2:end)};
    end
end

for id = length(dates):-1:1
    d_txt = dates{id};
    if d_txt(2)=='/'; d_txt = ['0',d_txt];end
    if d_txt(5)=='/'; d_txt = [d_txt(1:3),'0',d_txt(4:end)];end
    d_txt = [d_txt(1:6),'20',d_txt(7:8)];
    Z_DATA_DATES{id} = d_txt;
    d_txt(d_txt=='/')='-';
        
        
%     d_txt = ['0',dates{id},'20']; d_txt(d_txt=='/') = '-';
%     if d_txt(5)=='-'
%         d_txt = [d_txt(1:3),'0',d_txt(4:end)];
%     end
    pt = 0;
    try
        Z = readtable(['../COVID-19/csse_covid_19_data/csse_covid_19_daily_reports_us/',d_txt,'.csv']);
        pt = 1;
    catch
        Z = readtable(['../COVID-19/csse_covid_19_data/csse_covid_19_daily_reports/',d_txt,'.csv']);
    end
 
    heads = Z.Properties.VariableNames;    
    i_cn = find(strcmp(heads,'Country_Region')|strcmp(heads,'Country/Region'));
    i_st = find(strcmp(heads,'Province/State')|strcmp(heads,'Province_State'));
    i_co = find(strcmp(heads,'Confirmed'));
    i_de = find(strcmp(heads,'Deaths'));
    i_re = find(strcmp(heads,'Recovered'));
    if pt==1; i_pt = find(strcmp(heads,'People_Tested')|strcmp(heads,'Total_Test_Results')); end
    if id==length(dates)
        i_la = find(strcmp(heads,'Lat'));
        i_lo = find(strcmp(heads,'Long_'));
    end
    
    for i=length(us_state_names):-1:1
        J = strcmp([Z{:,i_st}],us_state_names{i});
        if id==length(dates)
            Z([Z{:,i_la}]==0|[Z{:,i_lo}]==0,[i_la,i_lo]) = {NaN};
            Z_DATA(i,[1:4,id+4]) = {us_state_names{i},'US',mean([Z{J,i_la}],'omitnan'),mean([Z{J,i_lo}],'omitnan'),sum([Z{J,i_co}])};
            Z_DATA_Deaths(i,[1:4,id+4]) = {us_state_names{i},'US',mean([Z{J,i_la}],'omitnan'),mean([Z{J,i_lo}],'omitnan'),sum([Z{J,i_de}])};
            Z_DATA_Recov(i,[1:4,id+4]) = {us_state_names{i},'US',mean([Z{J,i_la}],'omitnan'),mean([Z{J,i_lo}],'omitnan'),sum([Z{J,i_re}])};
            if pt==1 
                Z_DATA_Tested(i,[1:4,id+4]) = {us_state_names{i},'US',mean([Z{J,i_la}],'omitnan'),mean([Z{J,i_lo}],'omitnan'),sum([Z{J,i_pt}])};
            else
                Z_DATA_Tested(i,[1:4,id+4]) = {us_state_names{i},'US',mean([Z{J,i_la}],'omitnan'),mean([Z{J,i_lo}],'omitnan'),0};
            end
                
        else
            Z_DATA(i,id+4) = {sum([Z{J,i_co}])};
            Z_DATA_Deaths(i,id+4) = {sum([Z{J,i_de}])};
            Z_DATA_Recov(i,id+4) = {sum([Z{J,i_re}])};
            if pt==1
                Z_DATA_Tested(i,id+4) = {sum([Z{J,i_pt}])};
            else
                Z_DATA_Tested(i,id+4) = {0};
            end
        end
    end
end
save('data/state_data.mat','Z_D*');

