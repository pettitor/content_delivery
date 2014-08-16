function li13 = prepareLI13(par)

constants;

if (par.demand_model == LI13)
    li13.p = ones(1,par.nvids)/par.nvids;
elseif (par.demand_model == LI13Custom)
    li13.p = zeros(1,par.nvids);
end

li13.v = zeros(1,par.nvids);
li13.e = ones(1, par.nvids);
li13.ev = li13.e-li13.v;
%TODO used to determine if a video should be shared or not
li13.shr = sum(exprnd(par.li13.SHRm/par.li13.SHRk,par.li13.SHRk,par.nvids));

li13.lastShare = ones(1,par.nvids)/par.nvids;
li13.initialView = ones(1,par.nvids)/par.nvids;

%temporal attenuation
li13.tmpAttenuationExp = par.tmpAttenuationExp;
li13.shareAttenuation = par.shareAttenuation;
li13.viewAttenuation = par.viewAttenuation;

end