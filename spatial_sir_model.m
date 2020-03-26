function spatial_sir_model(app)
Np = app.pop.Value;
Ni = app.inf.Value;
Nt = 2000;

k_i = app.ki.Value;     % infection rate
k_r = 0.001; % infection rate

k_v = app.v_sd.Value*ones(Np,1); % velocity of movement 
r = rand(Np,1);
k_v(r<app.eta.Value) = app.v_c.Value;

typ = zeros(Np,1);
typ(1:Ni) = 1;

x(1:Np,1:2) = rand(Np,2);
t = 2*pi*rand(Np,1);
dx = 0.002*[sin(t),cos(t)];

T_ar = [1:Nt];
S_t = 0*T_ar;S_t(1) = Np-Ni;
I_t = 0*T_ar;I_t(1) = Ni;
R_t = 0*T_ar;

for i = 2:Nt
    x = x + dx;
    rmat = pdist2(x,x,'euclidean');
    rmat(rmat==0) = NaN;
        
    %% interactions
    % 1) Infection
    I = find(min(rmat,[],'omitnan')<0.02);
    t(I) = 2*pi*randn(length(I),1);
    dx(I,:) = k_v(I).*[sin(t(I)),cos(t(I))];

    rmat2 = (rmat<0.02)&(~isnan(rmat));
    inf_neigh = k_i*rmat2*(typ==1);
    typ(typ==0&inf_neigh>0)=1;
    
    % 2) Recovery
    I = find(typ==1);
    sw = -log(rand(size(I)))/k_r>1;
    typ(I(~sw)) = 2;
    
    %% walls
    % outer left/right
    I = ((x(:,1)>0.97)&(dx(:,1)>0))|((x(:,1)<0.03)&(dx(:,1)<0));
    dx(I,1)=-dx(I,1);
    I = ((x(:,2)>0.97)&(dx(:,2)>0))|((x(:,2)<0.03)&(dx(:,2)<0));
    dx(I,2)=-dx(I,2);
    % middle
    gp = 0.2;
    I = ((x(:,1)<.5).*(x(:,1)>0.47)&(dx(:,1)>0))|((x(:,1)>0.5).*(x(:,1)<0.53)&(dx(:,1)<0));
    I = I&((x(:,2)<(.5-gp/2))|(x(:,2)>(.5+gp/2)));
    dx(I,1)=-dx(I,1);
    
    %%
    hold(app.spat_sim,'off')
    plot(app.spat_sim,x(typ==0,1),x(typ==0,2),'go','markerfacecolor','g','markersize',8);
    hold(app.spat_sim,'on')
    plot(app.spat_sim,x(typ==1,1),x(typ==1,2),'bo','markerfacecolor','b','markersize',8);
    plot(app.spat_sim,x(typ==2,1),x(typ==2,2),'ro','markerfacecolor','r','markersize',8);
    plot(app.spat_sim,[0,1,1,0,0],[0,0,1,1,0],'k',[0.5,0.5],[0,0.5-gp/2],'k',[0.5,0.5],[0.5+gp/2,1],'k','linewidth',8)
    
    set(app.spat_sim,'xlim',[0 1],'ylim',[0 1]);
    drawnow
    if sum(typ==0)==0||sum(typ==1)==0
        break
    end
    
    S_t(i) = sum(typ==0);
    I_t(i) = sum(typ==1);
    R_t(i) = sum(typ==2);
    plot(app.spat_sim_2,T_ar(1:i),S_t(1:i),'g',T_ar(1:i),I_t(1:i),'b',T_ar(1:i),R_t(1:i),'r','linewidth',4);
    xlim(app.spat_sim_2,[1,Nt])
end
