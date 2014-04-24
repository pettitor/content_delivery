function vid=getVideo(uid, nvids, par, t, H, wall, categories)

ZIPF = 1;
WALL = 2;
YTSTATS = 3;
SNM = 4;

    % TODO
    % niche - popular
    % propagation size dependent on clustering coefficient ~ 150*exp(-5*x)
    % TODO recency
    switch par.demand_model
        case WALL
            ind = min(geornd(0.25), size(wall,2));
            if (ind == 0 || isnan(wall(uid,ind)))
                vid = random('unif', 1, nvids); %randi(size(GV,1));
            else
                vid = wall(uid,ind);
            end
        case ZIPF
            vid = nvids + 1;
            while vid > nvids
                % TODO check correct value for alpha
                vid = randraw('zeta', par.alpha, 1);
            end
        case YTSTATS
            % George you can implement your model here
        case SNM    
            %http://www.sigcomm.org/sites/default/files/ccr/papers/2013/October/2541468-2541470.pdf
            
            %TODO list of videos, as long they are alive (-> content life
            %span) possible to get new views
            %TODO when to introduce new videos in the system?
            % present from start of sim?
            %  as soon as they got a hit their life time is tracked?
            % new contents become available according to homogeneous Poisson process of rate
            %  i.e., time instants {tau_m}_m form standard Poisson process
            
            % TODO ?!
            % upon arrival of each new content m, independently for each content, we randomly 
            % choose the pair of parameters (Vm, lm) from a given assigned joint distribution
            % -> generate life-span from number of requests
            
            % TODO contradiction to our model?! -> number of requests
            % assign at introduction of content
            
            %Perc requests - Perc videos - lifeSpan (days) - NumberOfRequests
            % class 0: ? - ? - ? - <10 -> IRM approach
            % class 1: 9.1025 - 3.6025 - 1.0825 - 78.15
            % class 2: 8.005 - 5.3325 - 3.3575 - 45.975
            % class 3: 5.945 - 3.3175 - 6.395 - 57
            % class 4: 6.615 - 5.305 - 10.665 - 38.45
            % class 5: 70.33 - 82.4525 - 24.17 - 26.225
            
            % V_m: number of request for content
            % tau_m: Introduction time (of content in system)
            % lambda_m: popularity profile -> simple first-order approach
            %  (arbitrarily reasonable function lambda_m(t) with an assigned lifespan) l_m
            % l_m: content life-span
            
            % request process described by timeinhomogeneous Poisson
            % process (instantaneous rate at time t given by: V_mlambda_m(t - tau_m))
            
            % note: don't try to model popularity cascades (observed in
            % geographically distributed user base)
    end
    
end