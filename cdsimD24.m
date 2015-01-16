function [stats] = cdsimD24(par)

disp(par)

constants;

% Dependent on Matlab Version
s = RandStream(par.rand_stream, 'Seed', par.seed);
%RandStream.setGlobalStream(s);
RandStream.setDefaultStream(s);

 if (par.demand_model == ZIPF2)
        a=exp(-par.alpha .* log(1:par.nvids));
        zipfcdf = cumsum([0 a]);
        par.zipfcdf = zipfcdf/zipfcdf(end);
 end
 
 if (par.demand_model == BOX)
    a=exp(-par.alpha .* log(1:par.nvids));
    zipfcdf = cumsum([0 a]);
    par.zipfcdf = zipfcdf/zipfcdf(end);

    nrequests = par.tmax;
    
    % anzahl requests auswürfeln 
    vid = nan(1,nrequests);
    rnd = rand(1,nrequests);
    %par.AS = sum(~(ones(par.ASn,1)*rand(1,par.nuser)<zipfcdf'*ones(1,par.nuser)),1)+1
    for i=1:length(vid)
        vid(i) = sum((par.zipfcdf<rnd(i)))+1;
    end
    [nrequests,bin] = histc(vid,1:par.nvids);
    nrequests = nrequests(randperm(par.nvids));

    nrequests(nrequests == 0) = 1;
    
    % lifespan auswürfeln
    m = par.tmax/10;
    v = par.tmax;
    mu = log((m^2)/sqrt(v+m^2));
    sigma = sqrt(log(v/(m^2)+1));
    tau = lognrnd(mu, sigma, 1, par.nvids);

    % importzeitpunkt auswürfeln
    % TODO import frequenz
    vidimport = cumsum(exprnd(par.tmax/par.nvids, 1, par.nvids));

    viewt = nan(1, sum(nrequests));
    viewid = nan(1, sum(nrequests));
    offset = 1;
    for i=1:length(nrequests)
        viewt(offset:offset+nrequests(i)-1) = vidimport(i)+cumsum(exprnd(tau(i)/nrequests(i), 1, nrequests(i)));
        viewid(offset:offset+nrequests(i)-1) = i*ones(1,nrequests(i));
        offset = offset + nrequests(i);
    end

    [viewt, idx] = sort(viewt);
    viewid = viewid(idx);
    par.viewt = viewt;
    par.viewid = viewid;
 end

nusers = par.nuser;
nvids = par.nvids;

% array of all users with entry of as 
AS = par.AS;

% number of users in each AS
nASuser = histc(AS, 1:par.ASn);

%TODO all to 0 only pcacheUSER have capacity

%user die cache freigeben
iAScacheUSER = rand(1, nusers) < par.pcacheUSER; % return array with 0 and 1; 1 = cacheUSER
%nAScacheUSER = sum(iAScacheUSER);

%number of all cacheUSER
ncacheUSER = sum(iAScacheUSER);

% one cache per isp and shared caches of user
cache.AS = [1:par.ASn AS(iAScacheUSER)]'; %AS(iAScacheUSER) gibt die asnummer der leute die den cache freigegeben haben zurück            
%1 = isp-cache; 2=user-cache; spaltenvektor
cache.type = [ones(1,par.ASn) 2*ones(1,ncacheUSER)]';

%spaltenvektor mit kapazitäten als summe, zuerst isp kap, danach user kap
cache.capacity = [ceil(par.cachesizeAS*nvids*ones(1,par.ASn)) par.cachesizeUSER*ones(1,ncacheUSER)]';
%cache.capacity = [ceil(par.cachesizeAS*nASuser) par.cachesizeUSER*iAScacheUSER]';

%cache.items = cell(length(cache.capacity),1);
nitems = max(cache.capacity);
% for i=1:length(cache.capacity)
%     cache.items{i} = NaN(1,nitems);
% end

%cachespeicher für alle isp und hr caches
cache.items = sparse(length(cache.capacity), nitems);
%timestamp speicher
cache.score = sparse(length(cache.capacity), nitems);

%Initalisierung views mit 0en
stats.views = zeros(nvids,1);

stats.cache_access = zeros(length(cache.capacity),1);
stats.cache_hit = stats.cache_access;
stats.cache_serve = stats.cache_access;
%only for as caches
stats.AS_access = zeros(par.ASn,1);
stats.AS_hit = zeros(par.ASn,1);

%fill caches randomly at the beginning

for f=1:length(cache.capacity)
    for k=1:cache.capacity(f)
    cache.items(f,k) = random('unid',par.nvids,1);
    cache.score(f,k) = 0;
    end
end


%id für jeden request
maxID=1;
% qfid = fopen('q.txt', 'wt');

events.t = [];
events.type=[];
events.user=[];
events.id=[];
events.vid=[];

%TODO check user
events = addEvent(events, 0, par.tmax, WATCH, NaN, maxID, NaN);
tmax = par.tmax;
stats.watch = nan(1,tmax);
stats.uid = nan(1,tmax);
% stats.share = nan(1,tmax);
stats.t = nan(1,tmax);

warmup = 1;

t2 = 0;
while events.t(1) < par.tmax
    t = events.t(1); events.t(1)=[];
    type = events.type(1); events.type(1)=[];
    user = events.user(1); events.user(1)=[];
    id = events.id(1); events.id(1)=[];
    vid = events.vid(1); events.vid(1)=[];
    
    if (warmup && t>par.twarmup)
        warmup = 0;
        stats.watch = nan(1,tmax);
        stats.uid = nan(1,tmax);
%        stats.share = nan(1,tmax);
        stats.t = nan(1,tmax);
        stats.cache_access = zeros(length(cache.capacity),1);
        stats.cache_hit = stats.cache_access;
        stats.cache_serve = stats.cache_access;
        stats.AS_access = zeros(par.ASn,1);
        stats.AS_hit = zeros(par.ASn,1);
        stats.views = zeros(nvids,1);
    end
    
    t1 = floor(t);
    if (t1>t2 && mod(t1, round(par.tmax/100))==0)
        t2 = t1;
        disp(['Progress: ' num2str(100*(t1/par.tmax)) '%'])
    end
    
    switch type
        case WATCH
            
            %uid = getUserID(GF);
            if isnan(user)
                %user auswürfeln
                user = randi(nusers);
            end
            uid = user;
            %video auswürfeln, zipf verteilt
            if isnan(vid)
                vid = getVideo(uid, nvids, par, t, id); %, categories); % consider GV
            end
            %video view um ein erhöhen
            stats.views(vid) = stats.views(vid) + 1;
            
            stats.t(id) = t;
            stats.watch(id) = vid;
            stats.uid(id) = uid;
            %cid = cacheid von der das video geladen wird; 
            [cid, access, stats] = selectResource(cache, stats, AS, uid, vid, par, iAScacheUSER);
            %cid muss != 0 sein
             if (cid)
                 stats.cache_serve(cid) = stats.cache_serve(cid) + 1;
             end
             
             % update hit cache
             update = cid;
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
             
             
             
             
            %access enthält hr-caches oder isp-cache, die das video
            %besitzen sonst leer
            cache = updateCache(cache, stats, t, update, vid, par);
            %cache = updateCache(cache, stats, t, access, vid, par);
            % update local isp cache if video is popular
            %cache = updateCache(cache, stats, 1:par.ASn, vid, par.ISPcachingstrategy, par);
            
            dt = 1;%random(par.ia_demand_rnd, par.ia_demand_par);
           
            maxID = maxID+1;
            events = addEvent(events, t+dt, par.tmax, WATCH, NaN, maxID, NaN);

    end  
end
stats.AS = AS;
stats.icacheUSER = iAScacheUSER;
stats.cache = cache;

disp('Finished.')

%fclose(qfid);
end