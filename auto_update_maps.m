%% Auto-Update Maps
close all force
try
    A = COVID19_Matlab_App;
    TMP = {'US','World','Europe'};
    for i=1:3
        A.RegionDropDown.Value = TMP{i};
        cb = get(eval('A.RegionDropDown'),'ValueChangedFcn'); cb(A,[]);
        cb = get(eval('A.GenerateMovieButton'),'ButtonPushedFcn'); cb(A,[]);
    end
catch ME
    ME
    disp('Map Update Failed');
end

%% Test Country Comparisons
try
    close all force
    A = COVID19_Matlab_App;
    
    A.countries.Value = {'US','France','Italy','Spain'};
    cb = get(eval(['A.countries']),'ValueChangedFcn'); cb(A,[]);
    
    A.abs.Value = 1;
    cb = get(eval(['A.nmrl']),'SelectionChangedFcn'); cb(A,[]);
    
    A.rel_date.Value = 1;
    cb = get(eval(['A.nmrl_2']),'SelectionChangedFcn'); cb(A,[]);
    
    A.PeopleDropDown.Value = '100';
    cb = get(eval(['A.PeopleDropDown']),'ValueChangedFcn'); cb(A,[]);
    
    ylim(A.ax_infections,[50,1e5])
    xlim(A.ax_infections,[-10,30])
    xlim(A.ax_deaths,[-10,30]);
catch ME
    ME
end
%% Test State-by-State Comparisons
% try
    close all force
    A = COVID19_Matlab_App;
    
    A.countries.Value = 'US';
    cb = get(eval(['A.countries']),'ValueChangedFcn'); cb(A,[]);
    
    A.states.Value = {'Colorado','New York','California','Florida','Louisiana'};
    cb = get(eval(['A.states']),'ValueChangedFcn'); cb(A,[]);
    
    A.rel.Value = 1;
    cb = get(eval(['A.nmrl']),'SelectionChangedFcn'); cb(A,[]);
    
    A.rel_date.Value = 1;
    cb = get(eval(['A.nmrl_2']),'SelectionChangedFcn'); cb(A,[]);
    
    A.PeopleDropDown.Value = '0.1';
    cb = get(eval(['A.PeopleDropDown']),'ValueChangedFcn'); cb(A,[]);
    
    ylim(A.ax_infections,[1e-2,1e1]);
    xlim(A.ax_infections,[-5,15]);
    xlim(A.ax_deaths,[-5,15]);
    ylim(A.ax_deaths,[1e-4,1e-1]);
% catch ME
%     ME
% end
