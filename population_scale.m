function population_scale(app)

Y = importdata('data/Population_Data.csv');
Country_Names = Y.textdata(2:end,1);
Country_Pops = Y.data(2:end,end-1);

Y = importdata('data/states_populations.csv');
State_Names = Y.textdata(2:end,1);
State_Pops = Y.data(:,end);

for i=1:length(State_Names)
    if strcmp(State_Names{i}(1),'.')
        State_Names(i)={State_Names{i}(2:end)};
    end
end

POP = NaN*ones(length(app.States),1);
for i = 1:length(app.States)
    if ~isempty(app.States{i})
        [is,n] = ismember(app.States{i},State_Names);
        if is
            POP(i) = State_Pops(n);
        end
    else
        [is,n] = ismember(app.Countries{i},Country_Names);
        if is
            POP(i) = Country_Pops(n);
        end
    end
end
app.Pop_Data = POP;