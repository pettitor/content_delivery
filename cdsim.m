function [stats] = cdsim(par)

disp(par)

% event types
% caching strategies
%sim models
constants;

% Dependendt on Matlab Version
s = RandStream(par.rand_stream, 'Seed', par.seed);
%RandStream.setGlobalStream(s);
RandStream.setDefaultStream(s);


%rand('twister', par.seed)
nusers = par.nuser;
GV = sparse(par.nvids); % graph with video interest
nvids = par.nvids;
if isfield(par, 'historysize'); H  = NaN(nusers, par.historysize); else H = []; end% videos watched
if isfield(par, 'wallsize'); wall = NaN(nusers, par.wallsize); else wall = []; end% videos displayed on wall (based on friends shares and video interest)

stats.views = ones(nvids,1);
stats.tupload = nan(nvids,1);
stats.zipfp = diff(par.zipfcdf);
stats.zipfp = stats.zipfp(randperm(nvids));

% draw video categories according to probability in par.category
if isfield(par, 'categories')
category.video = randsample(length(par.categories),nvids,true,par.categories);
category.user = NaN(nusers, par.ncategories);
%TODO remove dublicate categories / use randsample?
for i=1:par.ncategories
    category.user(:,i) = sum(~(ones(length(par.categories),1)*rand(1,nusers)...
    <cumsum(par.categories)'*ones(1,nusers)))+1;
end
end

if isfield(par, 'preshare'); preshare = par.preshare; end
if isfield(par, 'pshare'); pshare = par.pshare; end

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

cache.capacity = [par.cachesizeAS*ones(1,par.ASn) par.cachesizeUSER*ones(1,nAScacheUSER)]';

cache.items = cell(length(cache.capacity),1);

cache.bwmean = [Inf*ones(1,par.ASn) par.uploadrate*ones(1,nAScacheUSER)]';
cache.bw = cache.bwmean;

cache.occupied = zeros(length(cache.capacity),1);

nitems = max(cache.capacity);
% for i=1:length(cache.capacity)
%     cache.items{i} = NaN(1,nitems);
% end
cache.items = sparse(length(cache.capacity), nitems);
for i=1:length(cache.capacity)
    perm = randperm(par.nvids);
    cache.items(i,1:cache.capacity(i)) = perm(1:cache.capacity(i));
end
cache.score = sparse(length(cache.capacity), nitems);
cache.score2 = sparse(length(cache.capacity), nitems);

if (any(par.cachingstrategy == SLWND))
    cache.wnd = sparse(length(cache.capacity), par.k);
end

% from paper characteristics of mobile youtube traffic

x_samp = [47 100 150 170 200 210 220 225 230 240 250 255 275 350];
    
y_samp = [0 0.03 0.09 0.1 0.14 0.16 0.2 0.5 0.7 0.8 0.88 0.94 0.97 1];

x_bitrate = [47:0.5:350];
cdf_bitrate = interp1(x_samp,y_samp,x_bitrate);

stats.cache_access = zeros(length(cache.capacity),1);
stats.cache_hit = stats.cache_access;
stats.cache_serve = stats.cache_access;
stats.AS_access = zeros(par.ASn,1);
stats.AS_hit = zeros(par.ASn,1);

% progress bar
%wait = waitbar(0,'Simulating... 0%');

maxID=1;
% qfid = fopen('q.txt', 'wt');

%snm specific data
snm = struct;
li13 = struct;
box = struct;
if (par.demand_model == SNM)
    snm = prepareSNM(par);
    stats.snm.classes = snm.videoClass;
elseif (par.demand_model == LI13 || par.demand_model == LI13Custom)
    li13 = prepareLI13(par);
elseif (par.demand_model == BOX)
    box = prepareBoxModel(par);
end

events.t = [];
events.type=[];
events.user=[];
events.id=[];
events.vid=[];


if (par.demand_model == LI13Custom && par.uploadEvents)
    %make sure UPLOAD is first in queue (otherwise no video acitve)
    events = addEvent(events, 0, par.tmax, UPLOAD, floor(rand()*nusers), 1, 1);
elseif (par.demand_model == MEME)
    %make sure UPLOAD is first in queue (otherwise no video acitve)
    events = addEvent(events, 0, par.tmax, UPLOAD, floor(rand()*nusers), 1, 1);
    u = floor(rand()*nusers);
    events = addEvent(events, 0, par.tmax, WATCH, u, 1, NaN);
elseif (par.demand_model == BOX)
    maxID = 1;
    u = floor(rand()*nusers);
    
    events = addEvent(events, box.viewt(box.idx), par.tmax, WATCH, u, maxID, box.viewid(box.idx));
    
    box.idx = box.idx + 1;
else
    %for i=1:maxID
    u = floor(rand()*nusers);
    events = addEvent(events, 0, par.tmax, WATCH, u, 1, NaN);
    %end
end

%profile on

if isfield(par, 'ticksPerDay')
dt = mean(par.ia_demand_par);
else
    dt = 1;
end
nrequests = par.tmax / dt;

% queue.active = [];

stats.upload = nan(1,2*nrequests);
stats.watch = nan(1,2*nrequests);
stats.uid = nan(1,2*nrequests);
stats.share = nan(1,2*nrequests);
stats.t = nan(1,2*nrequests);
stats.goodqoe = nan(1,2*nrequests);
stats.bitrate = nan(1,par.nvids);

% stats.numOfFriends = nan(1,6000000);
% stats.expViews = zeros(1,par.nvids);
% stats.snm.numActiveVids = [];
% stats.snm.time = [];

warmup = 1;

t2 = 0;
while ~isempty(events.t) && events.t(1) < (par.tmax)
    t = events.t(1); events.t(1)=[];
    type = events.type(1); events.type(1)=[];
    user = events.user(1); events.user(1)=[];
    id = events.id(1); events.id(1)=[];
    vid = events.vid(1); events.vid(1)=[];
    
    t1 = floor(t);
    if (t1>t2 && mod(t1, round(par.tmax/100))==0)
        t2 = t1;
        disp(['Progress: ' num2str(100*(t1/par.tmax)) '%'])
        %disp(['UNaDas occupied: ' num2str(100*sum(cache.occupied)/nAScacheUSER) '%'])
    end
    
    if (warmup && t>par.twarmup)
        warmup = 0;
        stats.upload = nan(1,2*nrequests);
        stats.watch = nan(1,2*nrequests);
        stats.uid = nan(1,2*nrequests);
        stats.share = nan(1,2*nrequests);
        stats.t = nan(1,2*nrequests);
        stats.goodqoe = nan(1,2*nrequests);
        %stats.bitrate = nan(1,par.nvids);
        
        %events.id = events.id-min(events.id)+1;
        %maxID = max(events.id);
        
        stats.cache_access = zeros(length(cache.capacity),1);
        stats.cache_hit = stats.cache_access;
        stats.cache_serve = stats.cache_access;
        stats.AS_access = zeros(par.ASn,1);
        stats.AS_hit = zeros(par.ASn,1);
        %stats.views = ones(nvids,1);
    end
    
    switch type
        case UPLOAD
            %add video to set of active videos
            %li13 = updateLI13(vid, UPLOAD, par, li13, t);
            u = floor(rand() * nusers); %pick a random user
            %maxID = maxID + 1;
            %events = addEvent(events, t, par.tmax, WATCH, user, maxID, vid);
            deltaT = exprnd(par.tmax/par.nvids);
            %deltaT = random(par.ia_video_rnd, par.tmax/par.nvids);
            maxID = maxID + 1;
            events = addEvent(events, t+deltaT, par.tmax, UPLOAD, floor(rand()*nusers), maxID, vid+1);
            
            stats.tupload(vid) = t;
            stats.t(id) = t;
            stats.upload(id) = vid;
            stats.uid(id) = user;
            
        case WATCH
            
            %uid = getUserID(GF);
            if isnan(user)
                %user auswürfeln
                user = randi(nusers);
            end
            uid = user;
            
            %http://www.sigcomm.org/sites/default/files/ccr/papers/2013/October/2541468-2541470.pdf
            %vid = getVideoSNM(par, snm, t, eventType);
            % note: don't try to model popularity cascades (observed in
            % geographically distributed user base)
            %vid = getVideoLI13(li13, eventType, t);
            %vid = getVideoLI13Custom(li13, eventType, t); 
            
            
            if isnan(vid)
                vid = getVideo(uid, nvids, par, t, id, stats, wall); %, categories); % consider GV
                if (par.demand_model == SNM)
                    snm = updateSNM(vid, snm, t);
                    stats.snm.numActiveVids = [stats.snm.numActiveVids length(snm.active)];
                    stats.snm.time = [stats.snm.time t];
                end
            end
            if isnan(stats.bitrate(vid))
                stats.bitrate(vid) = (find(rand()<cdf_bitrate, 1, 'first'));
            end
                     
            stats.views(vid) = stats.views(vid) + 1;
            
            stats.t(id) = t;
            stats.watch(id) = vid;
            stats.uid(id) = uid;
       
            %TODO
            GV = updateGV(GV, vid);
            
            cache.bw(~isinf(cache.bwmean)) = normrnd(cache.bwmean(~isinf(cache.bwmean)), 100);
            
            [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par, iAScacheUSER);
            
            if (cid)
                stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
            end
            
            if ~isempty(cid) && isfield(par, 'bitrate')
                 if (cache.type(cid)==2 && par.uploadrate > 0) % TODO
                     cache.occupied(cid) = cache.occupied(cid) + 1;
                     stats.goodqoe(id) = cache.bw(cid)/(cache.occupied(cid)) > 2*stats.bitrate(vid);
                     if (cache.occupied(cid)>1)
                     [events, ids, vids] = adjustServiceTimes(events, cid, t, par.tmax, ...
                        cache.occupied(cid)/(cache.occupied(cid)-1));
                        stats.goodqoe(ids) = cache.bw(cid)/(cache.occupied(cid)) > 2*stats.bitrate(vids);
                     end
                     if rand()<par.pHD; bitrate=par.bitrateHD; else bitrate = stats.bitrate(vid); end
                    maxID = maxID+1;
                    events = addEvent(events,...
                        t+realtosim(par,par.duration*bitrate/(cache.bw(cid)/cache.occupied(cid))),...
                        par.tmax, SERVE, cid, maxID, vid);
                 end
                 if (cache.type(cid)==1)
                     stats.goodqoe(id) = true;
                 end
            end
            
            update = cid;
             if par.Cstrat == LCD
             
             % leave copy down
             if (isempty(cid)) % update local ISP cache
                 update = find(cache.AS == AS(uid) & cache.type == 1);
             elseif (cache.type(cid) == 1) % update personal or random local hr
                 if (iAScacheUSER(uid)) % if personal cache
                    pid = find(find(iAScacheUSER) == uid,1,'first') + par.ASn;
                    update = union(update, pid);
                 else % else random local hr
                     local = find(cache.AS == AS(uid) & cache.type == 2);
                     if (any(local))
                         update = union(update, local(randi(length(local))));
                     end
                 end
             end % update hit local cache
             
             elseif par.Cstrat == LCE
             
             if par.resourceselection == TREE
                 update = access;
             else
             % leave copy everywhere
             if (isempty(cid)) % update local ISP cache
                 update = find(cache.AS == AS(uid) & cache.type == 1);
             end
             % update personal or random local hr
             if (isempty(cid) && iAScacheUSER(uid)) % if personal cache
                 pid = find(find(iAScacheUSER) == uid,1,'first') + par.ASn;
                 update = union(update, pid);
             else % else random local hr
                 local = find(cache.AS == AS(uid) & cache.type == 2);
                 if (any(local))
                     update = union(update, local(randi(length(local))));
                 end
             end % update hit local cache
             end
             end
             
            %access enthält hr-caches oder isp-cache, die das video
            %besitzen sonst leer
            cache = updateCache(cache, stats, t, update, vid, par);
            
            % add watch event
            if isfield(par, 'ticksPerDay')
            hourIndex = floor(mod(t,par.ticksPerDay)/(par.ticksPerDay/24))+1;
            dt = exprnd(par.ia_demand_par(hourIndex));
            else
                dt = 1;
            end
            %dt = random(par.ia_demand_rnd, par.ia_demand_par(hourIndex));
                
            if (par.demand_model ~= BOX)
                maxID = maxID+1;
                events = addEvent(events, t+dt, par.tmax, WATCH, NaN, maxID, NaN);
            else
                if (box.idx <= length(box.viewt))
                    maxID = maxID + 1;
                    events = addEvent(events, box.viewt(box.idx), par.tmax, WATCH, NaN, maxID, box.viewid(box.idx));

                    box.idx = box.idx + 1;
                end
            end

            switch par.sharing_model
                case WALL
                    r = rand();
                    reshare = any(wall(uid,:)==vid);
                    if ((~reshare && r < pshare) || (reshare && r < preshare))
                        % add (re)share event
    
                        dt = random(par.ia_share_rnd, ...
                            par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));
                        
                        maxID = maxID+1;
                        events = addEvent(events, t+dt, par.tmax, SHARE, user, maxID, vid);
                    end
                case YTSTATS
                    r = rand();
                    if (r < pshare)
                        h = getHistory(uid, stats);
                    else
                        h = NaN;
                    end
                    vid = getVideo(uid, stats.views, par, t, h, wall, SHARE, snm, li13, category);
                    
                    dt = random(par.ia_share_rnd, ...
                            par.ia_share_par(1), par.ia_share_par(2), par.ia_share_par(3));
                    
                    maxID = maxID+1;
                    events = addEvent(events, t+dt, par.tmax, SHARE, user, maxID, vid);
                    %TODO after lunch
            end
        
        case SHARE
            % update wall of friends
            % share random video according to interest
            if (isnan(vid))
                vid = getVideo(uid, nvids, par, t, H, wall, SHARE, category);
            end
            
            if (par.sharing_model == WALL)
                wall = updateWall(GF, wall, uid, vid);
            end
                       
            stats.share(id) = vid;
            stats.t(id) = t;
            
        case RESHARE % currently not used
            % update wall of friends
            wall = updateWall(GF, wall, stats.uid(id), stats.vid(id));
            
            if (par.demand_model == LI13 || par.demand_model == LI13Custom)
                li13 = updateLI13(vid, SHARE, par, li13, find(GF(uid,:)));
            end
            
            stats.share(id) = stats.vid(id);
            stats.t(id) = t;
        case SERVE
            %uid is used as cid
            cache.occupied(user) = cache.occupied(user) - 1;
            if (cache.occupied(user) > 0)
             if isempty(find(events.user == user,1))
                 disp 'bla'
             end
                events = adjustServiceTimes(events, user, t, par.tmax, ...
                    cache.occupied(user)/(cache.occupied(user)+1));
            end

    end  
end
stats.AS = AS;
stats.cache = cache;

disp('Finished.')

%fclose(qfid);
end
