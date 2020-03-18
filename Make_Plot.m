function Make_Plot(app)
if app.all.Value
    app.inf_vs_t = sum(app.DATA(:,10:end),1);
    app.dth_vs_t = sum(app.DATA_Deaths(:,10:end),1);
elseif app.specific.Value
    app.Countries
    app.countries.Value
    I = ismember(app.Countries,app.countries.Value);
    app.inf_vs_t = sum(app.DATA(I,10:end),1);
    app.dth_vs_t = sum(app.DATA_Deaths(I,10:end),1);
end
plot(app.ax_infections,app.inf_vs_t,'rs')
plot(app.ax_deaths,app.dth_vs_t,'rs')

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