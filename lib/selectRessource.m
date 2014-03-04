function uid = selectRessource(cache, AS, uid, vid, strategy, params)

    switch lower(strategy)
        case {'local'}
            % choose ressource in same AS if available
            local = AS == AS(uid);
            [row uid] = find(cache(:,local) == vid);
            
        case {'random'}
            % choose random ressource
    end

end

