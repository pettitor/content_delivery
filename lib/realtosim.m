function tsim = realtosim(par, treal)
    tsim = treal*par.ticksPerSecond;
end