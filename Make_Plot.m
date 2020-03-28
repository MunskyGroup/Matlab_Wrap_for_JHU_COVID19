function Make_Plot(app)
% Make_Plot(app)
% This function makes the plots of the JHU data for different countries or
% states depending upon user selections in the 'COVID19_Matlab_App' GUI
% (app).

if app.abs.Value
    DATA = app.DATA;
    DATA_Deaths = app.DATA_Deaths;
    DATA_Recov = app.DATA_Recov;
    app.ax_infections.YLabel.String = 'Infections (absolute number)';
    app.ax_deaths.YLabel.String = 'Deaths (absolute number)';
    countries = app.Countries;
else
    DATA = app.Pop_Data.DATA;
    DATA_Deaths = app.Pop_Data.DATA_Deaths;
    DATA_Recov = app.Pop_Data.DATA_Recov;
    app.ax_infections.YLabel.String = 'Infections (per 10k individuals)';
    app.ax_deaths.YLabel.String = 'Deaths (per 10k individuals)';
    countries = app.Pop_Data.Country_Names;
end

% First we sort countries/states so that they are in alphabetic order
app.countries.Value = sort(app.countries.Value);
app.states.Value = sort(app.states.Value);
if app.act.Value
        DATA_all = DATA - DATA_Deaths - DATA_Recov;
elseif app.rec.Value
        DATA_all(:,1:7) = DATA(:,1:7);
        DATA_all = [DATA_all, DATA(:,8:end) - DATA(:,1:end-7)];
elseif app.cum.Value
        DATA_all = DATA;
end

if app.all.Value  % All at once
    app.inf_vs_t = sum(DATA_all(:,10:end),1);
    app.dth_vs_t = sum(DATA_Deaths(:,10:end),1);
    app.abs.Value=1;
elseif app.specific.Value  % Specific Countries or states.
    if strcmp(app.states.Value,'ALL') % All states in chosen country/counties.
        app.inf_vs_t =[];app.dth_vs_t =[];
        for j=1:length(app.countries.Value) % separate out specific countries.
            I = ismember(countries,app.countries.Value{j});
            app.inf_vs_t(j,:) = sum(DATA_all(I,:),1);
            app.dth_vs_t(j,:) = sum(DATA_Deaths(I,:),1);
        end
    else
        app.inf_vs_t=[];app.dth_vs_t =[];  % Separate out specific states/regions
        for j=1:length(app.states.Value)
            I = ismember(app.States,app.states.Value{j});
            app.inf_vs_t(j,:) = DATA_all(I,:);
            app.dth_vs_t(j,:) = DATA_Deaths(I,:);
        end
    end
end

% User selection of time to treat as t=0;
if app.abs.Value
    if min(app.inf_vs_t(:,end))<10
        app.abs_date.Value = 1;
        app.PeopleDropDown.Items = {'1'};
    else
        for i=1:log10(min(app.inf_vs_t(:,end)))
            app.PeopleDropDown.Items{i} = num2str(10^i);
        end
        app.PeopleDropDown.Items = app.PeopleDropDown.Items(1:i);
        app.PeopleLabel.Text = 'People';
    end
else
    if min(app.inf_vs_t(:,end))<1e-3
        app.abs_date.Value = 1;
        app.PeopleDropDown.Items = {'0.001'};
    else
        for i=-3:log10(min(app.inf_vs_t(:,end)))
            app.PeopleDropDown.Items{i+4} = num2str(10^i);
        end
        app.PeopleDropDown.Items = app.PeopleDropDown.Items(1:i+4);
        app.PeopleLabel.Text = 'per 10k People';
    end
end


% Clear and make new plots of data versus time.
hold(app.ax_infections,'off'); hold(app.ax_deaths,'off')
legend(app.ax_deaths,'off'); legend(app.ax_infections,'off')
plot(app.ax_infections,[1:size(app.inf_vs_t,2)],app.inf_vs_t','-s')
plot(app.ax_deaths,[1:size(app.inf_vs_t,2)],app.dth_vs_t','-s')
if app.specific.Value
    if ~strcmp(app.states.Value,'ALL') % Add legend
        legend(app.ax_infections,app.states.Value,'Location','NorthWest')
        legend(app.ax_deaths,app.states.Value,'Location','NorthWest')
    end
end

% Call function to add trend lines if requested.
if app.add_trend_lines.Value
    Add_Trend_Lines(app)
end

% Change some axes properties.
if app.lin.Value
    set(app.ax_infections,'yscale','lin');
    set(app.ax_deaths,'yscale','lin');
else
    set(app.ax_infections,'yscale','log');
    set(app.ax_deaths,'yscale','log');
end