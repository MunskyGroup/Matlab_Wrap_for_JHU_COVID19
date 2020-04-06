function population_scale(app)

Y = importdata('data/Population_Data.csv');
Country_Names = Y.textdata(2:end,1);
Country_Pops = Y.data(2:end,end-1);

Y = importdata('data/states_populations.csv');
State_Names_withpops = Y.textdata(2:end,1);
State_Pops = Y.data(:,end);

for i=1:length(State_Names_withpops)
    if strcmp(State_Names_withpops{i}(1),'.')
        State_Names_withpops(i)={State_Names_withpops{i}(2:end)};
    end
end

I_pop = ones(length(app.States),1,'logical');
POP = NaN*ones(length(app.States),1);
for i = 1:length(app.States)
    if ~isempty(app.States{i}) % If state or province.
        [is,n] = ismember(app.States{i},State_Names_withpops);
        if is  % If state population is known
            POP(i) = State_Pops(n);
        else
            [is,n] = ismember(app.Countries{i},Country_Names);
            % If state population iss not know, assume all states equal
            % size and use country population.
            if is
                n_states = sum(strcmp(Country_Names{n},app.Countries{i}));
                POP(i) = Country_Pops(n)/n_states;
            else
                I_pop(i)=0;
            end
        end
    else % If country.
        [is,n] = ismember(app.Countries{i},Country_Names);
        if is
            POP(i) = Country_Pops(n);
        else
            I_pop(i)=0;
        end
    end
end
app.Pop_Data.Pops = POP(I_pop);
app.Pop_Data.DATA = app.DATA(I_pop,:)./repmat(POP(I_pop),1,size(app.DATA,2))*1e4;
app.Pop_Data.DATA_Deaths = app.DATA_Deaths(I_pop,:)./repmat(POP(I_pop),1,size(app.DATA,2))*1e4;
app.Pop_Data.DATA_Recov = app.DATA_Recov(I_pop,:)./repmat(POP(I_pop),1,size(app.DATA,2))*1e4;
app.Pop_Data.Long = app.Long(I_pop);
app.Pop_Data.Lat = app.Lat(I_pop);
app.Pop_Data.Country_Names = app.Countries(I_pop);
app.Pop_Data.State =app.States(I_pop);
return