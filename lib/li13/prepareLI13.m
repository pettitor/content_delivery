function li13 = prepareLI13(par)

li13.p = ones(1,par.nvids)/par.nvids;
li13.v = zeros(1,par.nvids);
li13.e = ones(1, par.nvids);
li13.ev = li13.e-li13.v;

end