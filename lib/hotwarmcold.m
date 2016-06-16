function X = hotwarmcold(p,s,lb,ur,factor)

if nargin < 5, factor = 1; end

lambda = p*lb;

mu = ur*ones(size(lambda)); %TODO video bit rate and stream rate ...

a = lambda./mu;

X=false(length(p),length(s));

cnt = 0;
tot = sum(s);

% for i=1:length(p)
%     for j=1:ceil(factor*a(i))
%         if cnt >= tot; break; end
%         cind = find(~X(i,:) & sum(X) < s, 1, 'first');
%         if ~isempty(cind)
%             X(i,cind) = true;
%             cnt = cnt + 1;
%         end
%     end
% end
cs = zeros(size(s));
for i=1:length(p)
    if cnt >= tot; break; end
    cind = find(~X(i,:) & cs < s, max(1,min(ceil(factor*a(i)), tot-cnt)), 'first');
    
    X(i,cind) = true;
    cnt = cnt + length(cind);
    cs(cind) = cs(cind) + 1;
end

end