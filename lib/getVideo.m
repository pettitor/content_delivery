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
            %Percentage of videos - lifeSpan (days) - NumberOfRequests
            % class 1: 3.6025 - 1.0825 - 78.15
            % class 2: 5.3325 - 3.3575 - 45.975
            % class 3: 3.3175 - 6.395 - 57
            % class 4: 5.305 - 10.665 - 38.45
            % class 5: 82.4525 - 24.17 - 26.225
    end
    
end