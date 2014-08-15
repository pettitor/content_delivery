function [stats] = cdsim(par)

disp(par)

% event types
WATCH=1;
SHARE=2;
RESHARE=3;
CACHE=4;
UPLOAD=5;

% caching strategies
LRU = 1;
LFU = 2;

SLWND = 5;

%sim models
ZIPF = 1;
WALL = 2;
YTSTATS = 3;
SNM = 4;
LI13 = 5;
ZIPF2 = 6;
LI13Custom = 7;

% Dependendt on Matlab Version
s = RandStream(par.rand_stream, 'Seed', par.seed);
RandStream.setGlobalStream(s);
%RandStream.setDefaultStream(s);


%rand('twister', par.seed)
GF = par.GF; % graph with friend relations
nusers = par.nuser;
GV = sparse(par.nvids); % graph with video interest
nvids = par.nvids;
H  = NaN(nusers, par.historysize); % videos watched
wall = NaN(nusers, par.wallsize); % videos displayed on wall (based on friends shares and video interest)

stats.views = zeros(nvids,1);

% draw video categories according to probability in par.category
category.video = randsample(length(par.categories),nvids,true,par.categories);

category.user = NaN(nusers, par.ncategories);
%TODO remove dublicate categories / use randsample?
for i=1:par.ncategories
    category.user(:,i) = sum(~(ones(length(par.categories),1)*rand(1,nusers)...
    <cumsum(par.categories)'*ones(1,nusers)))+1;
end

preshare = par.preshare;
pshare = par.pshare;

% draw ASnumbers of end user according to probability in par.ASp
AS = sum(~(ones(par.ASn,1)*rand(1,nusers)<cumsum(par.ASp)'*ones(1,nusers)),1)+1;

% number of users in each AS
nASuser = histc(AS, 1:par.ASn);

%TODO all to 0 only pcacheUSER have capacity

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
stats.AS_access = zeros(par.ASn,1);
stats.AS_hit = zeros(par.ASn,1);

% progress bar
%wait = waitbar(0,'Simulating... 0%');

maxID=nusers;
% qfid = fopen('q.txt', 'wt');

%snm specific data
snm = struct;
li13 = prepareLI13(par);

events.t = [];
events.type=[];
events.user=[];
events.id=[];
events.vid=[];

    %for i=1:maxID
    u = floor(rand()*nusers);
        events = addEvent(events, 0, par.tmax, WATCH, u, 1, NaN);
    %end

% queue.active = [];

stats.upload = nan(1,3000000);
stats.watch = nan(1,3000000);
stats.uid = nan(1,3000000);
stats.share = nan(1,3000000);
stats.t = nan(1,3000000);
stats.snm.numActiveVids = [];
stats.snm.time = [];

t2 = 0;
while ~isempty(events.t) && events.t(1) < par.tmax
    t = events.t(1); events.t(1)=[];
    type = events.type(1); events.type(1)=[];
    user = events.user(1); events.user(1)=[];
    id = events.id(1); events.id(1)=[];
    vid = events.vid(1); events.vid(1)=[];
    
    t1 = floor(t);
    if (t1>t2 && mod(t1, round(par.tmax/100))==0)
        t2 = t1;
        disp(['Progress: ' num2str(100*(t1/par.tmax)) '% '  num2str(length(events.t))])
        if 100*(t1/par.tmax) == 13
           disp('slow') 
        end
    end
    
    switch type
        case WATCH
            uid = user;
            if isnan(vid)
                vid = getVideo(uid, nvids, par, t, H, wall, WATCH, snm, li13);
                li13 = updateLI13(vid, WATCH, par, li13, t);
            else
                li13 = updateLI13(vid, WATCH, par, li13, t);
            end
            stats.views(vid) = stats.views(vid) + 1;
            
            stats.t(id) = t;
            stats.watch(id) = vid;
            stats.uid(id) = uid;
       
            %TODO
            GV = updateGV(GV, vid);
            
            [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par, iAScacheUSER);
            
             if (cid)
                 stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
             end               
            
             % remove caches without capacity
             %access = setdiff(access, noc);
             
            % Event necessary?
            %events = addEvent(events, t, par.tmax, CACHE, user, id);

            %TODO update only caches which were accessed
            % update user cache
            cache = updateCache(cache, stats, t, access, vid, par);
            % update local isp cache if video is popular
            %cache = updateCache(cache, stats, 1:par.ASn, vid, par.ISPcachingstrategy, par);
            

            vid = getVideoLI13(li13, SHARE, t, vid);

            if (~isnan(vid))
                dt = random(par.ia_share_rnd, ...
                    par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));

                maxID = maxID+1;
                events = addEvent(events, t+dt, par.tmax, SHARE, user, maxID, vid);
            end

            hourIndex = floor(mod(t,par.ticksPerDay)/(par.ticksPerDay/24))+1;
            
            % add watch event
            dt = exprnd(par.ia_demand_par(hourIndex));
            %dt = random(par.ia_demand_rnd, par.ia_demand_par(hourIndex));
                
            maxID = maxID+1;
            events = addEvent(events, t+dt, par.tmax, WATCH, user, maxID, NaN);
        
        case SHARE
            % update wall of friends
            % share random video according to interest
            if (isnan(vid))
                vid = getVideo(uid, nvids, par, t, H, wall, SHARE, snm, li13, category);
            end
            wall = updateWall(GF, wall, uid, vid);
            
            %find 'last': id 4897 returns several entries, should fix that
            li13 = updateLI13(vid, SHARE, par, li13, t, find(GF(uid,:), 1, 'last' ));
            
            stats.share(id) = vid;
            stats.t(id) = t;
    end  
end
stats.AS = AS;
stats.cache = cache;

disp('Finished.')

%fclose(qfid);
end