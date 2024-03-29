function Make_Plot(app)
% Make_Plot(app)
% This function makes the plots of the JHU data for different countries or
% states depending upon user selections in the 'COVID19_Matlab_App' GUI
% (app).

if app.abs.Value
    DATA = app.DATA;
    DATA_Deaths = app.DATA_Deaths;
    DATA_Recov = app.DATA_Recov;
    DATA_pt = app.DATA_pt;
    app.ax_infections.YLabel.String = 'Infections (absolute number)';
    app.ax_deaths.YLabel.String = 'Deaths (absolute number)';
    countries = app.Countries;
    states = app.States;
else
    DATA = app.Pop_Data.DATA;
    DATA_Deaths = app.Pop_Data.DATA_Deaths;
    DATA_Recov = app.Pop_Data.DATA_Recov;
    DATA_pt = app.Pop_Data.DATA_pt;
    app.ax_infections.YLabel.String = 'Infections (per 10k individuals)';
    app.ax_deaths.YLabel.String = 'Deaths (per 10k individuals)';
    countries = app.Pop_Data.Country_Names;
    states = app.Pop_Data.State;
end

% First we sort countries/states so that they are in alphabetic order
app.countries.Value = sort(app.countries.Value);
app.states.Value = sort(app.states.Value);
% if app.act.Value
%     DATA_all = DATA - DATA_Deaths - DATA_Recov;
%     app.ax_infections.YLabel.String = 'Actively Infected';
%     app.ax_infections.Title.String = 'Actively infected over time';
% else
if app.rec.Value
    dr = app.days_rec_inf.Value;
    DATA_all(:,1:dr) = DATA(:,1:dr);
    DATA_all = [DATA_all, DATA(:,dr+1:end) - DATA(:,1:end-dr)]/dr;
    app.ax_infections.YLabel.String = 'Recently Infected';
    app.ax_infections.Title.String = 'Recently infected over time';
elseif app.cum.Value
    DATA_all = DATA;
    app.ax_infections.YLabel.String = 'Cummulative Infected';
    app.ax_infections.Title.String = 'Cummulative infected over time';
elseif app.pt.Value
    DATA_all = DATA_pt;
    app.ax_infections.YLabel.String = 'People Tested';
    app.ax_infections.Title.String = 'People Tested over time';
elseif app.rpt.Value
    app.ax_infections.YLabel.String = 'People Recently Tested';
    app.ax_infections.Title.String = 'People Recently Tested over time';
    dr = app.days_rec_inf.Value;
    DATA_all(:,1:dr) = DATA_pt(:,1:dr);
    DATA_all = [DATA_all, DATA_pt(:,dr+1:end) - DATA_pt(:,1:end-dr)]/dr;
elseif app.inf_p_test.Value
    app.ax_infections.YLabel.String = 'Fraction of Tests Positive';
    app.ax_infections.Title.String = 'People Infected per Test';
    dr = app.days_rec_inf.Value;
    tmp(:,1:dr) = DATA(:,1:dr);
    tmp = [tmp, DATA(:,dr+1:end) - DATA(:,1:end-dr)]/dr;
    tmp2(:,1:dr) = DATA_pt(:,1:dr);
    tmp2 = [tmp2, DATA_pt(:,dr+1:end) - DATA_pt(:,1:end-dr)]/dr;    
    DATA_all = tmp./tmp2;
end

if app.abs.Value
    app.ax_infections.YLabel.String = [app.ax_infections.YLabel.String,' (absolute number)'];
    app.ax_deaths.YLabel.String = 'Deaths (absolute number)';
else
    app.ax_infections.YLabel.String = [app.ax_infections.YLabel.String,' (per 10k individuals)'];
    app.ax_deaths.YLabel.String = 'Deaths (per 10k individuals)';
end

if app.all.Value  % All at once
    if app.abs.Value
        app.inf_vs_t = sum(DATA_all,1);
        app.dth_vs_t = sum(DATA_Deaths,1);
    else
        app.inf_vs_t = sum(DATA_all.*app.Pop_Data.Pops,1)/sum(app.Pop_Data.Pops);
        app.dth_vs_t = sum(DATA_Deaths.*app.Pop_Data.Pops,1)/sum(app.Pop_Data.Pops);
    end
    app.abs.Value=1;
elseif app.specific.Value  % Specific Countries or states.
    if strcmp(app.states.Value,'ALL') % All states in chosen country/counties.
        app.inf_vs_t =[];app.dth_vs_t =[];
        for j=1:length(app.countries.Value) % separate out specific countries.
            I = ismember(countries,app.countries.Value{j});
            if app.abs.Value
                app.inf_vs_t(j,:) = sum(DATA_all(I,:),1);
                app.dth_vs_t(j,:) = sum(DATA_Deaths(I,:),1);
            else
                app.inf_vs_t(j,:) = sum(DATA_all(I,:).*app.Pop_Data.Pops(I),1)/sum(app.Pop_Data.Pops(I));
                app.dth_vs_t(j,:) = sum(DATA_Deaths(I,:).*app.Pop_Data.Pops(I),1)/sum(app.Pop_Data.Pops(I));
            end
        end
    else
        app.inf_vs_t=[];app.dth_vs_t =[];  % Separate out specific states/regions
        for j=1:length(app.states.Value)
            I = ismember(states,app.states.Value{j});
            app.inf_vs_t(j,:) = DATA_all(I,:);
            app.dth_vs_t(j,:) = DATA_Deaths(I,:);
        end
    end
end

% if app.abs.Value
%     if min(app.inf_vs_t(:,end))<10
%         app.abs_date.Value = 1;
%         app.PeopleDropDown.Items = {'1'};
%     else
%         for i=1:log10(min(app.inf_vs_t(:,end)))
%             app.PeopleDropDown.Items{i} = num2str(10^i);
%         end
%         app.PeopleDropDown.Items = app.PeopleDropDown.Items(1:i);
%         app.PeopleLabel.Text = 'People';
%     end
% else
%     if min(app.inf_vs_t(:,end))<1e-3
%         app.abs_date.Value = 1;
%         app.PeopleDropDown.Items = {'0.001'};
%     else
%         for i=-3:log10(min(app.inf_vs_t(:,end)))
%             app.PeopleDropDown.Items{i+4} = num2str(10^i);
%         end
%         app.PeopleDropDown.Items = app.PeopleDropDown.Items(1:i+4);
%         app.PeopleLabel.Text = 'per 10k People';
%     end
% end

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
if app.add_trend_lines.Value && ~app.inf_p_test.Value
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

% Put dates on x-axis
jMIN = find(strcmp(app.RealDates,char(app.InitlalDateForPlotDatePicker.Value)));
if isempty(jMIN); jMIN=1; end
jMIN = max(1,jMIN);

app.ax_infections.XTickMode = 'auto';
app.ax_infections.XLim = [jMIN,size(app.inf_vs_t,2)];
app.ax_infections.XTick(end) = size(app.inf_vs_t,2);
app.ax_infections.XTickLabel = {app.RealDates{app.ax_infections.XTick}};
app.ax_infections.XTickLabelRotation = 30;
app.ax_deaths.XLim = [jMIN,size(app.inf_vs_t,2)];
app.ax_deaths.XTick(end) = size(app.inf_vs_t,2);
app.ax_deaths.XTickLabel = {app.RealDates{app.ax_infections.XTick}};
app.ax_deaths.XTickLabelRotation = 30;