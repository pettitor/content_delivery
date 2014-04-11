function [stats] = cdsim(par)

disp(par)

% event types
WATCH=1;
SHARE=2;
RESHARE=3;
CACHE=4;

% caching strategies
LRU = 1;
LFU = 2;

SLWND = 5;

% Dependendt on Matlab Version
s = RandStream(par.rand_stream, 'Seed', par.seed);
RandStream.setDefaultStream(s);

%rand('twister', par.seed)


GF = par.GF; % graph with friend relations
nnodes = par.nuser;
GV = sparse(par.nvids); % graph with video interest
nvids = par.nvids;
H  = NaN(nnodes, par.historysize); % videos watched
wall = NaN(nnodes, par.wallsize); % videos displayed on wall (based on friends shares and video interest)

%categories = NaN(nnodes, par.ncategories);
%TODO draw random categories accodring to distribution

preshare = par.preshare;
pshare = par.pshare;

% draw ASnumbers of end user according to probability in par.ASp
AS = sum(~(ones(par.ASn,1)*rand(1,nnodes)<cumsum(par.ASp)'*ones(1,nnodes)))+1;

% number of users in each AS
nASuser = histc(AS, 1:par.ASn);

iAScacheUSER = rand(1, length(AS)) < par.pcacheUSER;
nAScacheUSER = sum(iAScacheUSER);

% one cache per isp and end user
cache.AS = [1:par.ASn AS(iAScacheUSER)]';

cache.type = [ones(1,par.ASn) 2*ones(1,nAScacheUSER)]';

% cache.strategy = NaN(size(cache.type));
% for i=1:length(par.cachingstrategy);
%     cache.strategy(cache.type == i) = par.cachingstrategy(i);
% end

cache.capacity = [ceil(par.cachesizeAS*nASuser) par.cachesizeUSER*ones(1,nAScacheUSER)]';

cache.items = cell(length(cache.capacity),1);
nitems = max(cache.capacity);
% for i=1:length(cache.capacity)
%     cache.items{i} = NaN(1,nitems);
% end
cache.items = sparse(length(cache.capacity), nitems);

cache.score = sparse(length(cache.capacity), nitems);

if (any(par.cachingstrategy == SLWND))
    cache.wnd = sparse(length(cache.capacity), par.k);
end

stats.cache_access = zeros(length(cache.capacity),1);
stats.cache_hit = stats.cache_access;
stats.cache_serve = stats.cache_access;

% progress bar
%wait = waitbar(0,'Simulating... 0%');

maxID=nnodes;
% qfid = fopen('q.txt', 'wt');

events.t = [];
events.type=[];
events.user=[];
events.id=[];
events.vid=[];

for i=1:maxID
    events = addEvent(events, 0, WATCH, i, i, NaN);
end

% queue.active = [];

stats.watch = nan(1,60000);
stats.uid = nan(1,60000);
stats.share = nan(1,60000);
stats.t = nan(1,60000);

t2 = 0;
while events.t(1) < par.tmax
    t = events.t(1); events.t(1)=[];
    type = events.type(1); events.type(1)=[];
    user = events.user(1); events.user(1)=[];
    id = events.id(1); events.id(1)=[];
    vid = events.vid(1); events.vid(1)=[];
    
    t1 = floor(t);
    if (t1>t2 && mod(t1, round(par.tmax/100))==0)
        t2 = t1;
        disp(['Progress: ' num2str(100*(t1/par.tmax)) '%'])
    end
    
    switch type
        case WATCH
            
            %uid = getUserID(GF);
            uid = user;
            if isnan(vid)
                vid = getVideo(uid, nvids, par, t, H, wall, categories); % consider GV
            end
            
            stats.t(id) = t;
            stats.watch(id) = vid;
            stats.uid(id) = uid;

            %TODO
            GV = updateGV(GV, vid);

            [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par.resourceselection);
                        
            % Event necessary?
            %events = addEvent(events, t, CACHE, user, id);

            %TODO update only caches which were accessed
            % update user cache
            cache = updateCache(cache, stats, t, access, vid, par);
            % update local isp cache if video is popular
            %cache = updateCache(cache, stats, 1:par.ASn, vid, par.ISPcachingstrategy, par);
            
            r = rand();
            reshare = any(wall(uid,:)==vid);
            if ((~reshare && r < pshare) || (reshare && r < preshare))
                % add (re)share event
                
                dt = random(par.ia_share_rnd, ...
                    par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));
                
                events = addEvent(events, t+dt, SHARE, user, id, vid);
            end

            % add watch event
            dt = random(par.ia_demand_rnd, ...
                    par.ia_demand_par(1));
                
            maxID = maxID+1;
            
            events = addEvent(events, t+dt, WATCH, user, maxID, NaN);
        
        case SHARE
            % update wall of friends
            % share random video according to interest
            if (isnan(vid))
                vid = getVideo(uid, GV, H, wall);
            end
            wall = updateWall(GF, wall, uid, vid);
            stats.share(id) = vid;
            stats.t(id) = t;
        case RESHARE % currently not used
            % update wall of friends
            wall = updateWall(GF, wall, stats.uid(id), stats.vid(id));
            stats.share(id) = stats.vid(id);
            stats.t(id) = t;
            
        %case CACHE

    end  
end
stats.AS = AS;
stats.cache = cache;

disp('Finished.')

%fclose(qfid);
end
