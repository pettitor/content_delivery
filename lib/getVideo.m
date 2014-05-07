function vid=getVideo(uid, views, par, t, H, wall, category)

ZIPF = 1;
WALL = 2;
YTSTATS = 3;
SNM = 4;


nvids = length(views);

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
            % for upload history H is nan, for re-share select video from
            % history
            
            % get videos with current interest category
            % cur_int -> cur_vid
            
            %TODO group of users
            
            %TODO put in function
            % interest selection category priority weights
            interests=[1 2 3 4];
            weights=[0.45 0.32 0.14 0.03];
            catorder = NaN(1,4);
            for i=1:length(interests)-1
                %choose the first category based on weigths
                catorder(i)=randsample(interests, 1, true,weights);

                %remove this category from next choices
                pos=(interests==catorder(i));
                interests(pos)=[];
                weights(pos)=[];
            end
            catorder(end)=interests;
            
            cur_int = category.user(uid, catorder);
            
            % go through categories in cur_int and see if there is potential video
           possible = [];
            while isempty(possible) && ~isempty(cur_int)
                possible = find(category.video == cur_int(1));
                cur_int(1) = [];
            end
            
            total = sum(views(possible));
            if (total > 0)
                poss_pop = views(possible)./total; 
            else
                poss_pop = ones(1, length(possible));
            end
            %if there is no possible video for this category
            if isempty(possible)
                vid=[];
            else%if there are possible videos
                vid=randsample(possible,1,true,poss_pop);
            end
            
        case SNM
            %http://www.sigcomm.org/sites/default/files/ccr/papers/2013/October/2541468-2541470.pdf
    end
    
end