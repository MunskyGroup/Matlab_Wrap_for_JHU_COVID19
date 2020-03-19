function Make_Plot(app)

app.countries.Value = sort(app.countries.Value);
app.states.Value = sort(app.states.Value);

if app.all.Value
    app.inf_vs_t = sum(app.DATA(:,10:end),1);
    app.dth_vs_t = sum(app.DATA_Deaths(:,10:end),1);
elseif app.specific.Value
    if strcmp(app.states.Value,'ALL')
        app.inf_vs_t =[];app.dth_vs_t =[];
        for j=1:length(app.countries.Value)
            I = ismember(app.Countries,app.countries.Value{j});
            app.inf_vs_t(j,:) = sum(app.DATA(I,:),1);
            app.dth_vs_t(j,:) = sum(app.DATA_Deaths(I,:),1);
        end
    else
        app.inf_vs_t=[];app.dth_vs_t =[];
        for j=1:length(app.states.Value)
            I = ismember(app.States,app.states.Value{j});
            app.inf_vs_t(j,:) = app.DATA(I,:);
            app.dth_vs_t(j,:) = app.DATA_Deaths(I,:);
        end
    end
end
hold(app.ax_infections,'off')
hold(app.ax_deaths,'off')
legend(app.ax_deaths,'off')
legend(app.ax_infections,'off')
plot(app.ax_infections,[1:size(app.inf_vs_t,2)],app.inf_vs_t','-s')
plot(app.ax_deaths,[1:size(app.inf_vs_t,2)],app.dth_vs_t','-s')
if app.specific.Value
    if ~strcmp(app.states.Value,'ALL')
        app.states.Value
        legend(app.ax_infections,app.states.Value,'Location','NorthWest')
        legend(app.ax_deaths,app.states.Value,'Location','NorthWest')
    end
end


if app.add_trend_lines.Value
    Add_Trend_Lines(app)
end

if app.lin.Value
    set(app.ax_infections,'yscale','lin');
    set(app.ax_deaths,'yscale','lin');
else
    set(app.ax_infections,'yscale','log');
    set(app.ax_deaths,'yscale','log');
end