function Run_SSA_Sim(app)

S = [-1,1,0,0,0,0,0;...% inf
     0,-1,1,0,0,0,0;...% infectious
     0,0,-1,1,0,0,0;...% sympt
     0,0,-1,0,0,1,0;...% recover
     0,0,0,-1,1,0,0;...% hospital
     0,0,0,-1,0,1,0;...% recover -no hospital
     0,0,0,0,-1,1,0;...% recover hospital
     0,0,0,-1,0,0,1;...% death 
     0,0,0,0,-1,0,1;]';% death 
  
 x0 = [app.S_0.Value;0;app.IU_0.Value;app.ID_0.Value;0;0;0];

 ki = 0.001;
 n_pre = app.d_pre.Value;
 n_post = app.d_post.Value;
 M = ceil(app.M_Hosp.Value*sum(x0)/10000);
 ks = 1/app.T_vis.Value;
 kinf = 1/app.t_i.Value;
 kr = 1/app.t_r.Value;
 knh = 1/app.t_r_nohosp.Value;
 kh = 1/app.t_r_hosp.Value;
 kd = app.P_d.Value*knh;
 
 prop = @(x)[ki*x(1)*(n_pre*(x(3)/(n_pre+x(3)))+n_post*(x(4)/(n_post+x(4))));...
     kinf*x(2);...
     ks*x(3);...
     kr*x(3);...
     x(4)*(x(5)<M);...
     knh*x(4);...
     kh*x(5);...
     kd*x(4);...
     kd*x(5)]; 
 
 TAarray = linspace(0,500,501);
 [X_Array] = run_ssa(S,prop,x0,TAarray);
 
%  plot(app.ssa_results,TAarray,X_Array,'linewidth',3);
%  legend(app.ssa_results,{'susceptible','asymptomatic','symptomatic','hospitalized','recovered','deceased'}); 
 plot(app.ssa_results,TAarray,X_Array([2,3,4,5,7],:)/sum(x0),'linewidth',3);
 set(app.ssa_results,'ylim',[0,0.15])
 legend(app.ssa_results,{'nonifectuous','asymptomatic','symptomatic','hospitalized','deceased'});