function [stats] = content_placement_sim(par)

disp(par)

% event types
WATCH=1;
SHARE=2;
RESHARE=3;
CACHE=4;

s = RandStream('mt19937ar','Seed', par.seed);
RandStream.setDefaultStream(s);

GF = par.GF; % graph with friend relations
nnodes = size(GF,1);
GV = zeros(par.nvids); % graph with video interest
H  = NaN(par.historysize, nnodes); % videos watched
wall = NaN(par.wallsize, nnodes); % videos displayed on wall (based on friends shares and video interest)

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
    events.t = [events.t 0];
    events.type = [events.type WATCH];
    events.user = [events.user i];
    events.id = [events.id i];
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

            updateGV(vid);

            events.t = [events.t(1:(index-1)) t events.t(index:end)];
            events.type = [events.type(1:(index-1)) CACHE events.type(index:end)];
            events.user = [events.user(1:(index-1)) user events.user(index:end)];
            events.id = [events.id(1:(index-1)) id events.id(index:end)];
            
            r = rand();
            reshare = any(wall(:,uid)==vid);
            if ((~reshare && r < pshare) || (reshare && r < preshare))
                % add (re)share event
                index = find(events.t > t, 1, 'first'); if (isempty(index)) index = length(events.t)+1; end
                
                timelag = floor(gprnd(par.betatimelag,1,0));
                
                events.t = [events.t(1:(index-1)) t+timelag events.t(index:end)];
                
                events.type = [events.type(1:(index-1)) SHARE events.type(index:end)];

                events.user = [events.user(1:(index-1)) user events.user(index:end)];
                events.id = [events.id(1:(index-1)) id events.id(index:end)];
            end

            % add watch event
            T = t+1;
            maxID = maxID+1;
            index = find(events.t > T, 1, 'first'); if (isempty(index)) index = length(events.t)+1; end
            events.t = [events.t(1:(index-1)) T events.t(index:end)];
            events.type = [events.type(1:(index-1)) WATCH events.type(index:end)];
            events.user = [events.user(1:(index-1)) user events.user(index:end)];
            events.id = [events.id(1:(index-1)) maxID+1 events.id(index:end)];    
        
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
            cache = updateCache(cache, stats.AS, stats.uid(id), stats.vid(id), '');
            
    end  
end
%fclose(qfid);
end
