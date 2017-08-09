function [stats] = cdsim(par, seed)

if nargin > 1, par.seed = seed; end

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
if par.demand_model ~= TRACE
    stats.zipfp = diff(par.zipfcdf);
    stats.zipfp = stats.zipfp(randperm(nvids));
end

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
%AS = sum(~(ones(par.ASn,1)*rand(1,nusers)<cumsum(par.ASp)'*ones(1,nusers)),1)+1;
cdf = cumsum(par.ASp);
AS = nan(1, par.nuser);
for i=1:par.nuser
    AS(i) = sum(rand()>cdf)+1;
end


% number of users in each AS
nASuser = histc(AS, 1:par.ASn);

%TODO all to 0 only pcacheUSER have capacity


if isfield(par, 'nHR')
    iAScacheUSER = ismember(randperm(length(AS)), 1:par.nHR);
else
    iAScacheUSER = rand(1, length(AS)) < par.pcacheUSER;
end
nAScacheUSER = sum(iAScacheUSER);

iAScache = nASuser > par.cachenuser;
AScache = find(iAScache);
par.nAScache = length(AScache);

cache.user = [NaN*ones(1,par.nAScache) find(iAScacheUSER)]';

% one cache per isp and end user
cache.AS = [AScache AS(iAScacheUSER)]';

cache.type = [ones(1,par.nAScache) 2*ones(1,nAScacheUSER)]';

% cache.strategy = NaN(size(cache.type));
% for i=1:length(par.cachingstrategy);
%     cache.strategy(cache.type == i) = par.cachingstrategy(i);
% end

cache.capacity = [par.cachesizeAS*ones(1,par.nAScache) par.cachesizeUSER*ones(1,nAScacheUSER)]';

%cache.items = cell(length(cache.capacity),1);

cache.bwmean = [Inf*ones(1,par.nAScache) par.uploadrate*ones(1,nAScacheUSER)]';
cache.bw = cache.bwmean;

cache.occupied = zeros(length(cache.capacity),1);

nitems = max(cache.capacity);
% for i=1:length(cache.capacity)
%     cache.items{i} = NaN(1,nitems);
% end
cache.items = sparse(length(cache.capacity), nitems);
perm = randperm(par.nvids);
index = randi(par.nvids, length(cache.capacity));
for i=1:length(cache.capacity)
    items = perm(index(i):min(index(i)+cache.capacity(i)-1, length(perm)));
    if length(items) < cache.capacity(i)
        left = cache.capacity(i) - length(items);
        items = [items perm(1:left)];
    end
    cache.items(i,1:cache.capacity(i)) = items;
end
cache.score = sparse(length(cache.capacity), nitems);
cache.score(cache.items > 0) = -1;
%cache.score2 = sparse(length(cache.capacity), nitems);

if par.cachingstrategy == KLRU
    cache.items2 = cache.items;
    cache.score2 = cache.score;
end

if any(par.cachingstrategy == LRL)
    cache2 = cache;
end

if par.cachingstrategy(2) == OPT
    if (isfield(par, 'ia_demand_par'))
        ia = mean(par.ia_demand_par);
    else
        ia = 1;
    end
    if isfield(par, 'factor')
        [row,col] = find(hotwarmcold(diff(par.zipfcdf), par.cachesizeUSER*ones(1,sum(cache.type==2)),1/ia,...
        (par.uploadrate/par.bitrate/par.duration), par.factor)');
        for i=2:length(cache.capacity)
            items = col(row==(i-1));
            cache.items(i,1:length(items)) = items;
        end
    else
    cache.items(:,2:end) = hotwarmcold(diff(par.zipfcdf), par.cachesizeUSER*ones(1,sum(cache.type==2)),1/ia,...
        (par.uploadrate/par.bitrate/par.duration))';
    end
end

% if par.cachingstrategy(2) == PPP
%     % throw one slot of cache to content i with prob ai p*lambda/(n*mu) = p*lambda/(n*(ur/br*d))
%     a = (diff(par.zipfcdf)/mean(par.ia_demand_par))/(sum(cache.type==2)*par.uploadrate/par.bitrate/par.duration);
%     cp = cumsum(a(cumsum(a)<1*4));
%     cp = cp/cp(end);
%     for i=2:length(cache.capacity)
%         items = ones(1,cache.capacity(i));
%         while length(unique(items)) < cache.capacity(i)
%         for j=1:cache.capacity(i)
%             items(j) = find(rand()<cp,1,'first');
%         end
%         end
%         cache.items(i,1:cache.capacity(i)) = items;
%     end
% end

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
    if isfield(par.box,'box')
        box = par.box.box;
    else
        box = prepareBoxModel(par); 
    end
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
    u = randi(nusers);
    events = addEvent(events, 0, par.tmax, WATCH, u, 1, NaN);
elseif (par.demand_model == BOX)
    maxID = 1;
    u = randi(nusers);
    
    events = addEvent(events, box.viewt(box.idx), par.tmax, WATCH, u, maxID, box.viewid(box.idx));
    
    box.idx = box.idx + 1;
elseif (par.demand_model == TRACE)
    maxID = 1;
    u = par.trace(1,1);
    t = par.trace(1,2);
    viewid = par.trace(1,3);
    
    events = addEvent(events, t, par.tmax, WATCH, u, maxID, viewid);
else
    maxID = 1;
    u = randi(nusers);
    events = addEvent(events, 0, par.tmax, WATCH, u, maxID, NaN);
    if (isfield(par,'updaterate'))
    maxID = maxID+1;
    events = addEvent(events, 0+1/par.updaterate, par.tmax, CACHE, NaN, maxID, NaN);
    end
    %end
end

%profile on

if isfield(par, 'ticksPerDay')
dt = mean(par.ia_demand_par);
else
    dt = 1;
end
nrequests = par.tmax / dt;
if(par.demand_model == TRACE)
    nrequests = size(par.trace,1);
end

% queue.active = [];
nrequests = ceil(nrequests);

stats.upload = nan(1,2*nrequests);
stats.watch = nan(1,2*nrequests);
stats.uid = nan(1,2*nrequests);
stats.share = nan(1,2*nrequests);
stats.t = nan(1,2*nrequests);
stats.traffic = nan(1,2*nrequests);
stats.goodqoe = nan(1,2*nrequests);
stats.bitrate = nan(1,par.nvids);
stats.loss = zeros(1,par.nvids);

if isfield(par, 'slwk')
    slwnd = randi(par.nvids,1,par.slwk);
    slwcnt = histc(slwnd,1:par.nvids);
    [~, slwrank] = sort(slwcnt,'descend');
end

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
    if (t1>t2 && mod(t1, round(par.tmax/10))==0)
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
        stats.traffic = nan(1,2*nrequests);
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
       
            if isfield(par, 'slwk')
                slwcnt(vid) = slwcnt(vid) + 1;
                slwcnt(slwnd(end)) = slwcnt(slwnd(end)) - 1;
                vididx = slwrank == vid;
                gtidx = slwcnt(slwrank) > slwcnt(vid);
                slwrank = [slwrank(gtidx) vid slwrank(~(gtidx | vididx))];
                endidx = slwrank == slwnd(end);
                gtidx = slwcnt(slwrank) > slwcnt(slwnd(end));
                slwrank = [slwrank(gtidx) slwnd(end) slwrank(~(gtidx | endidx))];
                slwnd(2:end) = slwnd(1:end-1);
                slwnd(1) = vid;
            end
            
            %TODO
            GV = updateGV(GV, vid);
            
            cache.bw(~isinf(cache.bwmean)) = normrnd(cache.bwmean(~isinf(cache.bwmean)), 100);
            cache.bw(cache.bw < 1) = 1;
            
            [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par, iAScacheUSER);
            
            if (cid)
                stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
            end
            
            if isfield(par, 'peer')
            if (cid)
                if cid == find(find(iAScacheUSER) == uid,1,'first') + par.nAScache;
                    stats.traffic(id) = 0;
                elseif (cache.AS(cid) == AS(uid)) %local
                   stats.traffic(id) = 1;
               else
                   if par.peer(AS(uid), cache.AS(cid))
                       stats.traffic(id) = 2;
                   elseif par.customer(AS(uid), cache.AS(cid))
                       stats.traffic(id) = 3;
                   end
               end
            else % content provider
                stats.traffic(id) = 4;
            end
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
            update = [];
            % IMPORTANT CONSIDER!!! Don't update others people caches
            if isfield(par, 'manipulate') && par.manipulate
                if (~isempty(cid))
                    update = cid;
                end
            else
                if (~isempty(cid) && (cache.type(cid) == 1 || cache.user(cid) == uid))
                    update = cid;
                end
            end
             if par.Cstrat == LCD
             
                 % leave copy down
                 if (isempty(cid)) % update local ISP cache
                     update = find(cache.AS == AS(uid) & cache.type == 1);
                 elseif (cache.type(cid) == 1) % update personal or random local hr
                     if (iAScacheUSER(uid)) % if personal cache
                        pid = find(find(iAScacheUSER) == uid,1,'first') + par.nAScache;
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
                     %update = cid;
                     % leave copy everywhere
                     if (isempty(cid)) % update local ISP cache
                         update = find(cache.AS == AS(uid) & cache.type == 1);
                     end
                     % update personal or random local hr
                     if (isempty(cid) && iAScacheUSER(uid)) % if personal cache
                         pid = find(find(iAScacheUSER) == uid,1,'first') + par.nAScache;
                         update = union(update, pid);
                     else % else random local hr
                         local = find(cache.AS == AS(uid) & cache.type == 2);
                         if (any(local))
                             update = union(update, local(randi(length(local))));
                         end
                     end % update hit local cache
                 end
             end
             
            % TODO consider only caches for eviction that do not contain video
            if (par.cachingstrategy(2) == LRL)
                update(cache.type(update)==2) = [];
                if (isempty(cid) || cache.type(cid) == 1)
                    stats.loss(vid) = t;
                    [~,updatel] = min(min(stats.loss(cache.items(2:end,1:par.cachesizeUSER)),[],2));
                    updatel = updatel + 1;
                    %update = min(stats.)
                    cache.score(updatel,1:cache.capacity(updatel)) = stats.loss(cache.items(updatel,1:cache.capacity(updatel)));
                    
                end
                if (rand() < par.q)
                %if any(cache2.items(id,:) == vid)
                    update(end+1) = updatel;
                end
                %cache2 = updateCache(cache2, stats, t, updatel, vid, par);
            end
             
            %access enthält hr-caches oder isp-cache, die das video
            %besitzen sonst leer
            
            if ~isempty(update)
                cache = updateCache(cache, stats, t, update, vid, par);
%                 for i=1:length(update)
%                     maxID = maxID+1;
%                     events = addEvent(events, t, par.tmax, CACHE, update(i), maxID, vid);
%                 end
            end
            
            % add watch event
            if (isfield(par, 'ticksPerDay') && par.demand_model ~= BOX)
            hourIndex = floor(mod(t,par.ticksPerDay)/(par.ticksPerDay/24))+1;
            dt = exprnd(par.ia_demand_par(hourIndex));
            else
                dt = 1;
            end
            %dt = random(par.ia_demand_rnd, par.ia_demand_par(hourIndex));
                
            if (par.demand_model ~= BOX && par.demand_model ~= TRACE)
                maxID = maxID+1;
                events = addEvent(events, t+dt, par.tmax, WATCH, NaN, maxID, NaN);
            elseif (par.demand_model == TRACE)
                maxID = maxID+1;
                events = addEvent(events, par.trace(maxID,2), par.tmax, WATCH, par.trace(maxID,1), maxID, par.trace(maxID,3));
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
        
            
        case CACHE
            %cache = updateCache(cache, stats, t, user, vid, par);
            [row,col] = find(hotwarmcold(slwcnt/sum(slwcnt), par.cachesizeUSER*ones(1,sum(cache.type==2)),...
                1/mean(par.ia_demand_par), (par.uploadrate/par.bitrate/par.duration), par.factor)');
            for i=2:length(cache.capacity)
                items = col(row==(i-1));
                cache.items(i,1:length(items)) = items;
            end
            maxID = maxID+1;
            events = addEvent(events, t+1/par.updaterate, par.tmax, CACHE, NaN, maxID, NaN);
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
