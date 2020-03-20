function Make_Plot(app)
% Make_Plot(app)
% This function makes the plots of the JHU data for different countries or
% states depending upon user selections in the 'COVID19_Matlab_App' GUI
% (app).

% First we sort countries/states so that they are in alphabetic order
app.countries.Value = sort(app.countries.Value);
app.states.Value = sort(app.states.Value);

if app.all.Value  % All at once
    app.inf_vs_t = sum(app.DATA(:,10:end),1);
    app.dth_vs_t = sum(app.DATA_Deaths(:,10:end),1);
elseif app.specific.Value  % Specific Countries or states.
    if strcmp(app.states.Value,'ALL') % All states in chosen country/counties.
        app.inf_vs_t =[];app.dth_vs_t =[];
        for j=1:length(app.countries.Value) % separate out specific countries.
            I = ismember(app.Countries,app.countries.Value{j});
            app.inf_vs_t(j,:) = sum(app.DATA(I,:),1);
            app.dth_vs_t(j,:) = sum(app.DATA_Deaths(I,:),1);
        end
    else
        app.inf_vs_t=[];app.dth_vs_t =[];  % Separate out specific states/regions
        for j=1:length(app.states.Value)
            I = ismember(app.States,app.states.Value{j});
            app.inf_vs_t(j,:) = app.DATA(I,:);
            app.dth_vs_t(j,:) = app.DATA_Deaths(I,:);
        end
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