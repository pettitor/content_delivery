function [vid ]= zipfRand(par)
%ZIPF Summary of this function goes here
%   Detailed explanation goes here

  zuf=rand();

  vid=find(par.zipfvert.cdf>zuf,1,'first')-1;


end
