function [X_Array] = run_ssa(S,prop,x0,TArray)
NTimes = size(TArray,2); % get number of times.
NSpec = size(x0,1); % get number of species.
X_Array = zeros(NSpec,NTimes);  % Preallocate trajectory.
x = x0;  %initial condition.
t = TArray(1);  %initial time.
tstop = TArray(NTimes);

iTime_Count = 1;
while t<tstop  
    w = prop(x);  
    w0 = sum(w); %% Compute the sum of the prop. functions    
    t = t+1/w0*log(1/rand); %% Update time of next reaction   
    if t<=tstop       
        while t>TArray(iTime_Count)
            X_Array(:,iTime_Count) = x;
            iTime_Count = iTime_Count+1;
        end       
        r2w0=rand*w0; %% generate second random number and multiply by prop. sum        
        i=1; %% initialize reaction counter
        sw = w(1);
        while sw<r2w0 % increment counter until sum(w(1:i)) exceeds r2w0
            i=i+1;
            try
            sw=sw+w(i);
            catch
                disp('here');
            end
        end
        x = x+S(:,i); % update the configuration
    end
end
X_Array(:,iTime_Count:end) = repmat(x,1,NTimes-(iTime_Count-1));