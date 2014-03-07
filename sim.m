function [stats] = content_placement_sim(par)

disp(par)

% event types
WATCH=1;
SHARE=2;
RESHARE=3;
CACHE=4;

% Dependendt on Matlab Version
%s = RandStream(par.rand_stream, 'Seed', par.seed);
%RandStream.setDefaultStream(s);

rand('twister', par.seed)


GF = par.GF; % graph with friend relations
nnodes = size(GF,1);
GV = zeros(par.nvids); % graph with video interest
H  = NaN(nnodes, par.historysize); % videos watched
wall = NaN(nnodes, par.wallsize); % videos displayed on wall (based on friends shares and video interest)
cache = NaN(nnodes, par.cachesize);

preshare = par.preshare;
pshare = par.pshare;

% draw ASnumbers according to probability in par.ASp
stats.AS = sum(~(ones(par.ASn,1)*rand(1,nnodes)<cumsum(par.ASp)'*ones(1,nnodes)))+1;

% progress bar
%wait = waitbar(0,'Simulating... 0%');

maxID=nnodes;
% qfid = fopen('q.txt', 'wt');

events.t = [];
events.type=[];
events.user=[];
events.id=[];

for i=1:maxID
    events = addEvent(events, 0, WATCH, i, i);
end

% queue.active = [];

stats.watch = nan(1,60000);
stats.uid = nan(1,60000);
stats.vid = nan(1,60000);
stats.share = nan(1,60000);

%while events.user(1) <= par.k*par.n %events.t(1)<par.tmax
while events.t(1) < par.tmax
    t = events.t(1); events.t(1)=[];
    type = events.type(1); events.type(1)=[];
    user = events.user(1); events.user(1)=[];
    id = events.id(1); events.id(1)=[];
    
    switch type
        case WATCH
            stats.watch(id) = t;

            %uid = getUserID(GF);
            uid = user;
            vid = getVid(uid, GV, H, wall);

            stats.uid(id) = uid;
            stats.vid(id) = vid;

            GV = updateGV(GV, vid);

            % Event necessary?
            events = addEvent(events, t, CACHE, user, id);
            
            r = rand();
            reshare = any(wall(uid,:)==vid);
            if ((~reshare && r < pshare) || (reshare && r < preshare))
                % add (re)share event
                
                dt = random(par.ia_share_rnd, ...
                    par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));
                
                events = addEvent(events, t+dt, SHARE, user, id);
            end

            % add watch event
            dt = random(par.ia_demand_rnd, ...
                    par.ia_demand_par(1));
                
            maxID = maxID+1;
            
            events = addEvent(events, t+dt, WATCH, user, maxID);
        
        case SHARE
            % update wall of friends
            % share random video according to interest
            if (isnan(stats.vid(id)))
                vid = getVid(stats.uid(id), GV, H, wall);
            else
                vid = stats.vid(id);
            end
            wall = updateWall(GF, wall, stats.uid(id), vid);
            stats.share(id) = vid;
        case RESHARE % currently not used
            % update wall of friends
            wall = updateWall(GF, wall, stats.uid(id), stats.vid(id));
            stats.share(id) = stats.vid(id);
            
        case CACHE
            cache = updateCache(cache, stats.AS, stats.uid(id), stats.vid(id), 'lru');
            
    end  
end
%fclose(qfid);
end
