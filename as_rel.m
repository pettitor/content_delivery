addpath('lib/matlab_bgl')

fid = fopen('data/20150101.as-rel.txt');
C = textscan(fid, '%f %f %f', 'delimiter', '|', 'CommentStyle', '#');
fclose(fid);

ipeers = C{3}==0;
icustomer = C{3}==-1;

n = max([C{1};C{2}]);

peer = sparse(C{1}(ipeers),C{2}(ipeers), ones(1,sum(ipeers)), n, n);
customer = sparse(C{1}(icustomer),C{2}(icustomer), ones(1,sum(icustomer)), n, n);

stub = ~any(customer,2);

customerc = customer(~stub,~stub);

%[D, P] = all_shortest_paths(customerc,struct('algname','floyd_warshall'));
%%
%function p = aspath(from, to)
from=2;
if stub(from)
   i = customer(:,from); 
end
j=3;
p=[]; while j~=0, p(end+1)=j; j=P(i,j); end; p=fliplr(p);
%find(shortest_paths(customer, 680))




%end